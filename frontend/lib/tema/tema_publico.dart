import 'package:flutter/material.dart';

/// Paleta fija de la vista pública (catálogo y detalle): es una portada de
/// marca para quien todavía no tiene cuenta institucional, y no sigue el
/// tema claro/oscuro del sistema o de la app.
class ColoresPublico {
  const ColoresPublico._();

  static const fondoPagina = Color(0xFFF5F7FA);
  static const fondoTarjeta = Colors.white;
  static const textoPrimario = Color(0xFF12161C);
  static const textoSecundario = Color(0xFF5B6472);
  static const borde = Color(0xFFE3E7ED);
  static const heroAcento = Color(0xFF5FD8E3);
  static const heroSubtexto = Color(0xFFC8DBEC);
  static const heroStatLabel = Color(0xFFA9C4DA);
  static const heroGradiente = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF0B2C4A), Color(0xFF16507E), Color(0xFF0E7E92)],
    stops: [0.0, 0.55, 1.0],
  );
}
