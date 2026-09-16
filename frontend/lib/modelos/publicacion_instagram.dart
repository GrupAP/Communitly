import 'lectura_json.dart';

/// Una publicación de Instagram curada a mano para el carrusel de
/// "actividad reciente" del detalle público. `imagenUrl` puede venir vacío
/// (el gestor no cargó una miniatura propia, o el post es el "spotlight" de
/// una persona y se prefirió no reutilizar su foto): en ese caso la interfaz
/// cae al embed en vivo de Instagram en vez de la imagen.
class PublicacionInstagram {
  final String url;
  final String titulo;
  final String imagenUrl;

  const PublicacionInstagram({
    required this.url,
    this.titulo = '',
    this.imagenUrl = '',
  });

  factory PublicacionInstagram.desdeJson(Map<String, dynamic> json) {
    return PublicacionInstagram(
      url: json.texto('url'),
      titulo: json.texto('titulo'),
      imagenUrl: json.texto('imagen'),
    );
  }
}
