import 'package:url_launcher/url_launcher.dart';

/// Abre la IA con un prompt inicial sobre el tema indicado.
/// Devuelve false si no se pudo abrir el enlace.
Future<bool> openAiHelp(String topic) {
  final prompt =
      "Hola, estoy estudiando algoritmos y este es mi tema actual: '$topic'. Tengo una duda relacionada:";
  final url = Uri.parse(
    'https://gemini.google.com/app?q=${Uri.encodeComponent(prompt)}',
  );
  return launchUrl(url, mode: LaunchMode.externalApplication);
}
