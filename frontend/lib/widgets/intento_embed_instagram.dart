// Intenta mostrar el embed en vivo de Instagram encogido al tamaño de una
// miniatura. `dart:html`/`dart:js_interop` solo existen compilando para web,
// así que fuera de ahí (p. ej. `flutter test`) se usa un stub que no ocupa
// espacio ni hace nada.
export 'intento_embed_instagram_stub.dart'
    if (dart.library.html) 'intento_embed_instagram_web.dart';
