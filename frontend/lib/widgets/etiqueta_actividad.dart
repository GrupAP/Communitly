import 'package:flutter/material.dart';

import '../tema/tema.dart';

/// Señal visual de qué tan activo está un club en redes sociales.
///
/// Pensada para el catálogo público (RF-01): a un estudiante de colegio que
/// explora los clubes le importa saber si siguen vigentes, no solo su
/// descripción. Los clubes con nivel 'sin_verificar' no muestran nada, en vez
/// de afirmar una actividad que no se pudo comprobar.
class EtiquetaActividad extends StatelessWidget {
  final String nivel;

  const EtiquetaActividad({super.key, required this.nivel});

  static const _colores = {
    'activo': AppColores.turquesa,
    'poco_activo': Color(0xFFB8860B),
    'inactivo': Color(0xFFB3261E),
  };

  static const _textos = {
    'activo': 'Activo en redes',
    'poco_activo': 'Poco activo',
    'inactivo': 'Inactivo',
  };

  @override
  Widget build(BuildContext context) {
    final color = _colores[nivel];
    final texto = _textos[nivel];
    if (color == null || texto == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        texto,
        style: context.textos.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
