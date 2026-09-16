import 'package:flutter/material.dart';

/// Versión sin navegador (p. ej. corriendo `flutter test` en la VM): no hay
/// forma real de incrustar el post, así que no ocupa espacio en vez de
/// fallar al compilar.
class InstagramEmbed extends StatelessWidget {
  final String url;

  const InstagramEmbed({super.key, required this.url});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
