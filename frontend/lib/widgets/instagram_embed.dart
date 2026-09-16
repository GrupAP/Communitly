// Incrusta una publicación pública de Instagram con su widget de embed
// oficial. `dart:html`/`dart:js_interop` solo existen compilando para web,
// así que fuera de ahí (p. ej. `flutter test`, que corre en la VM de Dart)
// se usa un stub que no ocupa espacio.
export 'instagram_embed_stub.dart' if (dart.library.html) 'instagram_embed_web.dart';
