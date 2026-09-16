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
          Expanded(child: _marca(compacto: compacto)),
          const SizedBox(width: 12),
          _botonLogin(context, compacto: compacto),
        ],
      ),
    );
  }

  /// En un teléfono de 320-390 px "ESPOL Comunidades" + el botón de entrar no
  /// caben en una sola fila: en compacto se acorta a "ESPOL" (con elipsis de
  /// respaldo si aun así no cupiera) y se cede el espacio sobrante al botón.
  Widget _marca({required bool compacto}) {
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
        Flexible(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(children: [
              const TextSpan(
                text: 'ESPOL ',
                style: TextStyle(
                  color: AppColores.azulEspol,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              if (!compacto)
                const TextSpan(
                  text: 'Comunidades',
                  style: TextStyle(color: ColoresPublico.textoSecundario, fontSize: 18),
                ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _botonLogin(BuildContext context, {required bool compacto}) {
    return FilledButton.icon(
      onPressed: () => context.go(Rutas.login),
      style: FilledButton.styleFrom(
        backgroundColor: AppColores.azulEspol,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: compacto ? 12 : 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Icons.login, size: 16),
      label: Text(compacto ? 'Entrar' : 'Iniciar sesión'),
    );
  }
}
