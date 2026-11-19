const http = require('http');
const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawn } = require('child_process');

const PORT = 3001;
const MAX_BYTES = 2 * 1024 * 1024; // 2 MB

function findMatlab() {
  const env = process.env.MATLAB_CMD;
  if (env && fs.existsSync(env)) return env;

  const root = 'C:\\Program Files\\MATLAB';
  if (fs.existsSync(root)) {
    const versions = fs.readdirSync(root).sort().reverse(); // la más nueva primero
    for (const v of versions) {
      const exe = path.join(root, v, 'bin', 'matlab.exe');
      if (fs.existsSync(exe)) return exe;
    }
  }
  return 'matlab'; // último recurso: que esté en el PATH
}

function launchMatlab(args) {
  return new Promise((resolve, reject) => {
    const exe = findMatlab();
    const useShell = exe === 'matlab';
    const finalArgs = useShell ? args.map((a) => `"${a}"`) : args;
    const child = spawn(exe, finalArgs, {
      detached: true,
      stdio: 'ignore',
      shell: useShell,
    });
    child.once('error', () => reject(new Error('No pude abrir MATLAB. Verifica que esté instalado o define MATLAB_CMD.')));
    child.once('spawn', () => {
      child.unref();
      resolve();
    });
  });
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let size = 0;
    const chunks = [];
    req.on('data', (c) => {
      size += c.length;
      if (size > MAX_BYTES * 2) {
        reject(new Error('El archivo es demasiado grande.'));
        req.destroy();
        return;
      }
      chunks.push(c);
    });
    req.on('end', () => resolve(Buffer.concat(chunks).toString('utf8')));
    req.on('error', reject);
  });
}

function send(res, status, obj) {
  res.writeHead(status, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(obj));
}

const server = http.createServer(async (req, res) => {
  // CORS: permite que la app en Chrome (otro puerto) llame al servidor
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    return res.end();
  }

  try {
    if (req.method === 'GET' && req.url === '/estado') {
      return send(res, 200, { ok: true });
    }

    if (req.method === 'POST' && req.url === '/abrir-matlab') {
      await launchMatlab([]);
      return send(res, 200, { ok: true });
    }

    if (req.method === 'POST' && req.url === '/abrir-fuzzy') {
      await launchMatlab(['-r', 'fuzzy']);
      return send(res, 200, { ok: true });
    }

    if (req.method === 'POST' && req.url === '/abrir-fis') {
      const { base64 } = JSON.parse(await readBody(req));
      if (!base64) return send(res, 400, { error: 'No llegó ningún archivo.' });

      const buf = Buffer.from(base64, 'base64');
      if (buf.length > MAX_BYTES) {
        return send(res, 400, { error: 'El archivo supera los 2 MB.' });
      }

      const file = path.join(os.tmpdir(), `fuzzy-${Date.now()}.fis`);
      fs.writeFileSync(file, buf);
      const safe = file.replace(/\\/g, '/').replace(/'/g, "''");
      await launchMatlab(['-r', `fuzzy('${safe}')`]);
      return send(res, 200, { ok: true });
    }

    send(res, 404, { error: 'Ruta no encontrada.' });
  } catch (e) {
    send(res, 500, { error: e.message || 'Error en el servidor.' });
  }
});

server.listen(PORT, () => {
  console.log(`Servidor MATLAB listo en http://localhost:${PORT}`);
});