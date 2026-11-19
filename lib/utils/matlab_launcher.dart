import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class MatlabLauncher {
  static const String _base = 'http://localhost:3001';
  static const int maxBytes = 2 * 1024 * 1024;

  static const String _noService =
      'El servicio local no está disponible. Inicia el servidor MATLAB '
      '(node matlabServer.js) y vuelve a intentarlo.';

  /// Devuelve null si salió bien, o un mensaje de error.
  static Future<String?> _post(
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    http.Response res;
    try {
      res = await http
          .post(
            Uri.parse('$_base$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body ?? {}),
          )
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      return _noService;
    }
    if (res.statusCode == 200) return null;
    try {
      return (jsonDecode(res.body)['error'] as String?) ?? 'Error inesperado.';
    } catch (_) {
      return 'Error inesperado.';
    }
  }

  static Future<bool> isAvailable() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/estado'))
          .timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> openMatlab() => _post('/abrir-matlab');

  static Future<String?> openFuzzyDesigner() => _post('/abrir-fuzzy');

  static Future<String?> openFis(Uint8List bytes) {
    if (bytes.length > maxBytes) {
      return Future.value('El archivo supera los 2 MB.');
    }
    return _post('/abrir-fis', {'base64': base64Encode(bytes)});
  }
}
