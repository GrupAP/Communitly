import 'lectura_json.dart';
import 'publicacion_instagram.dart';

class Comunidad {
  final int id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final String facultad;
  final String facultadDescripcion;
  final String contacto;
  final String logo;
  final String instagram;

  /// 'activo', 'poco_activo', 'inactivo' o 'sin_verificar'. Ver
  /// [EtiquetaActividad] para su representación visual.
  final String nivelActividad;
  final int seguidores;
  final bool siguiendo;

  // Ficha informativa opcional (solo viene en el detalle, RF-01 público): no
  // todos los clubes la tienen, así que cada campo puede llegar vacío y la
  // interfaz oculta esa fila en vez de inventar un dato.
  final String carrera;
  final String fundado;
  final String reuniones;
  final String lugarReuniones;
  final String membresia;

  /// Publicaciones de Instagram curadas a mano para el detalle público
  /// (Instagram no deja traer las de una cuenta ajena sin OAuth).
  final List<PublicacionInstagram> publicacionesInstagram;

  /// Estado de la solicitud del usuario conectado en esta comunidad
  /// ('pendiente', 'aprobada', ...). Queda vacío cuando el backend no lo
  /// incluye, y en ese caso la interfaz lo averigua con una petición aparte.
  final String estadoMiSolicitud;

  const Comunidad({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.contacto,
    this.logo = '',
    required this.seguidores,
    required this.siguiendo,
    this.facultad = '',
    this.facultadDescripcion = '',
    this.instagram = '',
    this.nivelActividad = 'sin_verificar',
    this.estadoMiSolicitud = '',
    this.carrera = '',
    this.fundado = '',
    this.reuniones = '',
    this.lugarReuniones = '',
    this.membresia = '',
    this.publicacionesInstagram = const [],
  });

  /// Si el detalle ya trae el estado, no hace falta pedir todas las solicitudes
  /// del estudiante solo para saber qué botón mostrar.
  bool get conoceMiSolicitud => estadoMiSolicitud.isNotEmpty;

  factory Comunidad.desdeJson(Map<String, dynamic> json) {
    final miSolicitud = json['mi_solicitud'];

    return Comunidad(
      id: json.entero('id'),
      nombre: json.texto('nombre'),
      descripcion: json.texto('descripcion'),
      categoria: json.texto('categoria'),
      facultad: json.texto('facultad'),
      facultadDescripcion: json.texto('facultad_descripcion'),
      contacto: json.texto('contacto'),
      logo: json.texto('logo'),
      instagram: json.texto('instagram'),
      nivelActividad: json.texto('nivel_actividad', porDefecto: 'sin_verificar'),
      seguidores: json.entero('seguidores'),
      siguiendo: json.booleano('siguiendo'),
      carrera: json.texto('carrera'),
      fundado: json.texto('fundado'),
      reuniones: json.texto('reuniones'),
      lugarReuniones: json.texto('lugar_reuniones'),
      membresia: json.texto('membresia'),
      publicacionesInstagram: json
          .objetos('publicaciones_instagram')
          .map(PublicacionInstagram.desdeJson)
          .toList(),
      // El backend puede mandarlo como objeto o como texto suelto; los dos se
      // aceptan, y si no viene queda vacío.
      estadoMiSolicitud: switch (miSolicitud) {
        final Map<String, dynamic> objeto => objeto.texto('estado'),
        final String texto => texto,
        _ => '',
      },
    );
  }
}
