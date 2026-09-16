import 'package:flutter/material.dart';

/// Versión sin navegador (p. ej. corriendo `flutter test` en la VM): no hay
/// forma real de intentar el embed, así que no ocupa espacio.
class IntentoEmbedInstagram extends StatelessWidget {
  final String url;
  final double lado;

  const IntentoEmbedInstagram({super.key, required this.url, required this.lado});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
