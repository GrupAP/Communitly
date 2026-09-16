// Abre una URL externa en una pestaña nueva. `dart:html` solo existe
// compilando para web, así que fuera de ahí (p. ej. `flutter test`, que
// corre en la VM de Dart) se usa un stub que no hace nada.
export 'abrir_url_stub.dart' if (dart.library.html) 'abrir_url_web.dart';
