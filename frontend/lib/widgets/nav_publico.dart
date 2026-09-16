import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../rutas/rutas.dart';
import '../tema/tema.dart';
import '../tema/tema_publico.dart';

/// Barra superior de la vista pública (catálogo y detalle): marca + botón de
/// inicio de sesión. Sin enlaces de navegación ni selector de tema, para
/// mantenerla igual de simple en toda la vista pública.
class NavPublico extends StatelessWidget {
  const NavPublico({super.key});

  @override
  Widget build(BuildContext context) {
    final compacto = MediaQuery.sizeOf(context).width < 760;

    return Container(
      decoration: const BoxDecoration(
        color: ColoresPublico.fondoTarjeta,
        border: Border(bottom: BorderSide(color: ColoresPublico.borde)),
      ),
      padding: EdgeInsets.symmetric(horizontal: compacto ? 16 : 32, vertical: 14),
      child: Row(
        children: [
          _marca(),
          const Spacer(),
          _botonLogin(context),
        ],
      ),
    );
  }

  Widget _marca() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColores.turquesa, AppColores.azulEspol],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.groups_rounded, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 10),
        RichText(
          text: const TextSpan(children: [
            TextSpan(
              text: 'ESPOL ',
              style: TextStyle(
                color: AppColores.azulEspol,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            TextSpan(
              text: 'Comunidades',
              style: TextStyle(color: ColoresPublico.textoSecundario, fontSize: 18),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _botonLogin(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => context.go(Rutas.login),
      style: FilledButton.styleFrom(
        backgroundColor: AppColores.azulEspol,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Icons.login, size: 16),
      label: const Text('Iniciar sesión'),
    );
  }
}
