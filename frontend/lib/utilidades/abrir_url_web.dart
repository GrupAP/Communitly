import 'dart:html' as html;

/// Abre una URL externa en una pestaña nueva. Solo para web: este proyecto
/// no tiene destino móvil, así que no hace falta el paquete url_launcher.
void abrirUrl(String url) {
  html.window.open(url, '_blank');
}
