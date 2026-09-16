import 'package:flutter/material.dart';

import '../modelos/publicacion_instagram.dart';
import '../tema/tema.dart';
import '../tema/tema_publico.dart';
import '../utilidades/abrir_url.dart';
import 'intento_embed_instagram.dart';

/// Tarjeta de "actividad reciente": miniatura propia + título + link al post
/// original. Si la publicación no tiene una miniatura curada (el gestor no
/// subió una, o se prefirió no reutilizar la foto de una persona), se muestra
/// un marcador compacto del mismo tamaño en su lugar.
///
/// Encima, en segundo plano, [IntentoEmbedInstagram] intenta el embed oficial
/// en vivo por si el navegador de quien mira lo permite (la mayoría lo
/// bloquea por defecto). Si carga, se ve encima de la miniatura, encogido al
/// mismo tamaño; si no, la miniatura/marcador de abajo sigue siendo lo único
/// visible y no hay ningún parpadeo ni espacio en blanco.
class TarjetaActividad extends StatelessWidget {
  final PublicacionInstagram publicacion;

  const TarjetaActividad({super.key, required this.publicacion});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => abrirUrl(publicacion.url),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: ColoresPublico.borde),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: LayoutBuilder(
                builder: (context, restricciones) => Stack(
                  children: [
                    Positioned.fill(
                      child: publicacion.imagenUrl.isEmpty
                          ? const _MarcadorSinImagen()
                          : Image.network(
                              publicacion.imagenUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const _MarcadorSinImagen(),
                            ),
                    ),
                    Positioned.fill(
                      child: IntentoEmbedInstagram(
                        url: publicacion.url,
                        lado: restricciones.maxWidth,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (publicacion.titulo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        publicacion.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ColoresPublico.textoPrimario,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.open_in_new, size: 14, color: ColoresPublico.textoSecundario),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MarcadorSinImagen extends StatelessWidget {
  const _MarcadorSinImagen();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: ColoresPublico.fondoPagina,
      child: Center(
        child: Icon(Icons.camera_alt_outlined, color: AppColores.turquesa, size: 28),
      ),
    );
  }
}
