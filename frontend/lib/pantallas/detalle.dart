import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../estado/estado_async.dart';
import '../modelos/comunidad.dart';
import '../rutas/rutas.dart';
import '../servicios/api.dart';
import '../servicios/sesion.dart';
import '../tema/tema.dart';
import '../tema/tema_publico.dart';
import '../utilidades/abrir_url.dart';
import '../widgets/esqueletos.dart';
import '../widgets/etiqueta_actividad.dart';
import '../widgets/instagram_embed.dart';
import '../widgets/monograma_club.dart';
import '../widgets/nav_publico.dart';
import '../widgets/vista_async.dart';
import 'eventos.dart';
import 'solicitudes_widgets.dart';

class PantallaDetalle extends StatefulWidget {
  final int comunidadId;

  /// Vista pública (sin sesión): solo la información de la comunidad, sin
  /// seguir, solicitudes ni eventos.
  final bool publico;

  const PantallaDetalle({
    super.key,
    required this.comunidadId,
    this.publico = false,
  });

  @override
  State<PantallaDetalle> createState() => _PantallaDetalleState();
}

class _PantallaDetalleState extends State<PantallaDetalle> {
  Estado<Comunidad> _estado = const Cargando();
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    if (mounted) setState(() => _estado = const Cargando());

    try {
      final comunidad = await Api.detalleComunidad(widget.comunidadId);
      if (!mounted) return;
      setState(() => _estado = ConDatos(comunidad));
    } catch (error) {
      if (!mounted) return;
      setState(() => _estado = ConError.desde(error));
    }
  }

  Future<void> _alternarSeguimiento(Comunidad comunidad) async {
    setState(() => _procesando = true);

    try {
      final mensaje = comunidad.siguiendo
          ? await Api.dejarDeSeguir(comunidad.id)
          : await Api.seguir(comunidad.id);
      await _cargar();
      if (mounted) mostrarAviso(context, mensaje);
    } catch (error) {
      if (mounted) {
        mostrarAviso(context, mensajeDeFalla(error), esError: true);
      }
    }

    if (!mounted) return;
    setState(() => _procesando = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.publico) return _buildPublico(context);

    final comunidad = _estado.datosONulo;

    return Scaffold(
      appBar: AppBar(title: Text(comunidad?.nombre ?? 'Comunidad')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: VistaAsync<Comunidad>(
              estado: _estado,
              cargando: const _EsqueletoDetalle(),
              alReintentar: _cargar,
              constructor: _contenido,
            ),
          ),
        ),
      ),
    );
  }

  Widget _contenido(BuildContext context, Comunidad comunidad) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En pantallas estrechas el título y el botón no caben en una fila, así
        // que el Wrap los apila en lugar de desbordarse. El ancho infinito es
        // necesario para que `spaceBetween` tenga espacio que repartir: sin él
        // el Wrap encoge hasta sus hijos y arrastra a toda la columna.
        SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    comunidad.nombre,
                    style: context.textos.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [
                      comunidad.categoria,
                      if (comunidad.facultad.isNotEmpty) comunidad.facultad,
                      '${comunidad.seguidores} seguidores',
                    ].join(' · '),
                    style: context.textos.bodyLarge
                        ?.copyWith(color: context.textoSecundario),
                  ),
                  if (comunidad.facultadDescripcion.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      comunidad.facultadDescripcion,
                      style: context.textos.bodySmall
                          ?.copyWith(color: context.textoSecundario),
                    ),
                  ],
                  if (comunidad.nivelActividad != 'sin_verificar') ...[
                    const SizedBox(height: 8),
                    EtiquetaActividad(nivel: comunidad.nivelActividad),
                  ],
                ],
              ),
              _botonSeguir(comunidad),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Las dos acciones de comunidad, en un Wrap para que no se desborden
        // en pantallas estrechas.
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _accionesSolicitud(comunidad),
            // RF-03: eventos de esta comunidad.
            OutlinedButton.icon(
              onPressed: () => unawaited(Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => PantallaEventos(
                    comunidadId: comunidad.id,
                    comunidadNombre: comunidad.nombre,
                  ),
                ),
              )),
              icon: const Icon(Icons.event),
              label: const Text('Ver eventos de esta comunidad'),
            ),
          ],
        ),
        const SizedBox(height: 36),
        Text('Acerca de la comunidad', style: context.textos.titleLarge),
        const SizedBox(height: 8),
        Text(comunidad.descripcion, style: const TextStyle(height: 1.5)),
        if (comunidad.instagram.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text('Instagram', style: context.textos.titleLarge),
          const SizedBox(height: 8),
          SelectableText(comunidad.instagram),
        ],
        if (comunidad.contacto.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text('Contacto', style: context.textos.titleLarge),
          const SizedBox(height: 8),
          SelectableText(comunidad.contacto),
        ],
      ],
    );
  }

  /// RF-06: la acción depende del rol. El gestor de esta comunidad revisa las
  /// solicitudes recibidas; cualquier otro usuario postula. El backend vuelve a
  /// comprobar el permiso en cada operación.
  Widget _accionesSolicitud(Comunidad comunidad) {
    if (Sesion.gestiona(comunidad.id)) {
      return FilledButton.icon(
        onPressed: () => context.push(Rutas.bandeja(comunidad.id)),
        icon: const Icon(Icons.inbox_outlined),
        label: const Text('Ver solicitudes recibidas'),
      );
    }

    return BotonSolicitarIngreso(
      // La clave fuerza a reconstruir el botón cuando el detalle se recarga con
      // un estado de solicitud distinto.
      key: ValueKey('${comunidad.id}:${comunidad.estadoMiSolicitud}'),
      comunidadId: comunidad.id,
      estadoConocido:
          comunidad.conoceMiSolicitud ? comunidad.estadoMiSolicitud : null,
      alCambiar: _cargar,
    );
  }

  Widget _botonSeguir(Comunidad comunidad) {
    if (_procesando) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (comunidad.siguiendo) {
      return OutlinedButton.icon(
        onPressed: () => _alternarSeguimiento(comunidad),
        icon: const Icon(Icons.check),
        label: const Text('Siguiendo'),
      );
    }

    return FilledButton.icon(
      onPressed: () => _alternarSeguimiento(comunidad),
      icon: const Icon(Icons.add),
      label: const Text('Seguir'),
    );
  }

  // --- Vista pública ---------------------------------------------------
  //
  // Sin sesión no hay seguir ni postular, así que no aparecen. Tampoco hay
  // "próximos eventos" (fuera de alcance de esta vista) ni una tarjeta de
  // "únete": no hay nada que unir sin cuenta. La ficha de "Información" y
  // el carrusel de Instagram solo muestran lo que el club realmente tenga
  // cargado, en vez de inventar un dato para la fila que falte.

  Widget _buildPublico(BuildContext context) {
    return Theme(
      data: AppTema.claro,
      child: Scaffold(
        backgroundColor: ColoresPublico.fondoPagina,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const NavPublico(),
              VistaAsync<Comunidad>(
                estado: _estado,
                cargando: const Padding(
                  padding: EdgeInsets.all(64),
                  child: Center(child: CircularProgressIndicator()),
                ),
                alReintentar: _cargar,
                constructor: _contenidoPublico,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contenidoPublico(BuildContext context, Comunidad comunidad) {
    final ancho = MediaQuery.sizeOf(context).width;
    final angosto = ancho < 900;
    final principales = _tarjetasPrincipales(comunidad);
    final laterales = _tarjetasLaterales(comunidad);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: EdgeInsets.fromLTRB(ancho < 760 ? 16 : 32, 20, ancho < 760 ? 16 : 32, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _migaDePanPublica(context, comunidad),
              const SizedBox(height: 20),
              _portadaPublica(comunidad),
              _encabezadoPublico(comunidad),
              const SizedBox(height: 20),
              _statsPublicas(comunidad),
              const SizedBox(height: 32),
              if (angosto) ...[
                ...principales,
                if (principales.isNotEmpty && laterales.isNotEmpty) const SizedBox(height: 20),
                ...laterales,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: principales,
                      ),
                    ),
                    if (laterales.isNotEmpty) ...[
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: laterales,
                        ),
                      ),
                    ],
                  ],
                ),
              const SizedBox(height: 40),
              _piePublico(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _migaDePanPublica(BuildContext context, Comunidad comunidad) {
    void volver() =>
        context.canPop() ? context.pop() : context.go(Rutas.publico);

    return Row(
      children: [
        IconButton(
          onPressed: volver,
          icon: const Icon(Icons.arrow_back, color: ColoresPublico.textoSecundario),
          tooltip: 'Volver al catálogo',
          visualDensity: VisualDensity.compact,
        ),
        InkWell(
          onTap: volver,
          child: const Text(
            'Clubes',
            style: TextStyle(
              color: ColoresPublico.textoSecundario,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _separadorMiga(),
        Text(comunidad.categoria,
            style: const TextStyle(color: ColoresPublico.textoSecundario, fontSize: 13)),
        _separadorMiga(),
        Flexible(
          child: Text(
            comunidad.nombre,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ColoresPublico.textoPrimario,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _separadorMiga() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.chevron_right, size: 14, color: ColoresPublico.textoSecundario),
    );
  }

  Widget _portadaPublica(Comunidad comunidad) {
    final color = colorMonograma(comunidad.nombre);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, AppColores.azulEspol],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        Positioned(
          left: 24,
          bottom: -28,
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 4),
            ),
            alignment: Alignment.center,
            child: Text(
              inicialesClub(comunidad.nombre),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26),
            ),
          ),
        ),
      ],
    );
  }

  Widget _encabezadoPublico(Comunidad comunidad) {
    return Padding(
      padding: const EdgeInsets.only(top: 44),
      child: Wrap(
        spacing: 20,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  comunidad.nombre,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: ColoresPublico.textoPrimario,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      [
                        comunidad.categoria,
                        if (comunidad.facultad.isNotEmpty) comunidad.facultad,
                      ].join(' · '),
                      style: const TextStyle(color: ColoresPublico.textoSecundario, fontSize: 14),
                    ),
                    if (comunidad.nivelActividad != 'sin_verificar')
                      EtiquetaActividad(nivel: comunidad.nivelActividad),
                  ],
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (comunidad.instagram.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () => abrirUrl(comunidad.instagram),
                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                  label: const Text('Instagram'),
                ),
              OutlinedButton.icon(
                onPressed: () => _compartir(context),
                icon: const Icon(Icons.ios_share_outlined, size: 16),
                label: const Text('Compartir'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _compartir(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: Uri.base.toString()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Enlace copiado')));
  }

  Widget _statsPublicas(Comunidad comunidad) {
    return Wrap(
      spacing: 28,
      runSpacing: 10,
      children: [
        _estadisticaPublica(
          icono: Icons.groups_rounded,
          valor: '${comunidad.seguidores}',
          etiqueta: comunidad.seguidores == 1 ? 'seguidor' : 'seguidores',
        ),
        if (comunidad.fundado.isNotEmpty)
          _estadisticaPublica(
            icono: Icons.calendar_today_outlined,
            valor: comunidad.fundado,
            etiqueta: 'fundado',
          ),
      ],
    );
  }

  Widget _estadisticaPublica({
    required IconData icono,
    required String valor,
    required String etiqueta,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 16, color: AppColores.turquesa),
        const SizedBox(width: 8),
        Text(valor,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: ColoresPublico.textoPrimario)),
        const SizedBox(width: 5),
        Text(etiqueta, style: const TextStyle(color: ColoresPublico.textoSecundario, fontSize: 14)),
      ],
    );
  }

  List<Widget> _tarjetasPrincipales(Comunidad comunidad) {
    return [
      _tarjetaPublica(
        titulo: 'Acerca de la comunidad',
        child: Text(
          comunidad.descripcion,
          style: const TextStyle(color: ColoresPublico.textoPrimario, height: 1.5, fontSize: 14),
        ),
      ),
      if (comunidad.publicacionesInstagram.isNotEmpty) ...[
        const SizedBox(height: 20),
        _tarjetaPublica(
          titulo: 'Actividad reciente',
          child: Column(
            children: [
              for (final url in comunidad.publicacionesInstagram) ...[
                InstagramEmbed(key: ValueKey(url), url: url),
                if (url != comunidad.publicacionesInstagram.last) const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ],
    ];
  }

  List<Widget> _tarjetasLaterales(Comunidad comunidad) {
    final filasInfo = _filasInformacion(comunidad);
    final tieneContacto = comunidad.instagram.isNotEmpty || comunidad.contacto.isNotEmpty;

    return [
      if (filasInfo.isNotEmpty) ...[
        _tarjetaPublica(titulo: 'Información', child: Column(children: filasInfo)),
        if (tieneContacto) const SizedBox(height: 20),
      ],
      if (tieneContacto)
        _tarjetaPublica(
          titulo: 'Contacto y redes',
          child: Column(
            children: [
              if (comunidad.instagram.isNotEmpty)
                _filaContacto(
                  icono: Icons.camera_alt_outlined,
                  valor: comunidad.instagram,
                  onTap: () => abrirUrl(comunidad.instagram),
                ),
              if (comunidad.instagram.isNotEmpty && comunidad.contacto.isNotEmpty)
                const Divider(height: 20, color: ColoresPublico.borde),
              if (comunidad.contacto.isNotEmpty)
                _filaContacto(icono: Icons.mail_outline, valor: comunidad.contacto),
            ],
          ),
        ),
    ];
  }

  List<Widget> _filasInformacion(Comunidad comunidad) {
    final filas = [
      if (comunidad.facultad.isNotEmpty) MapEntry('Facultad', comunidad.facultad),
      if (comunidad.carrera.isNotEmpty) MapEntry('Carrera', comunidad.carrera),
      if (comunidad.fundado.isNotEmpty) MapEntry('Fundado', comunidad.fundado),
      if (comunidad.reuniones.isNotEmpty) MapEntry('Reuniones', comunidad.reuniones),
      if (comunidad.lugarReuniones.isNotEmpty) MapEntry('Lugar', comunidad.lugarReuniones),
      if (comunidad.membresia.isNotEmpty) MapEntry('Membresía', comunidad.membresia),
    ];

    return [
      for (var i = 0; i < filas.length; i++) ...[
        _filaInformacion(filas[i].key, filas[i].value),
        if (i != filas.length - 1) const Divider(height: 20, color: ColoresPublico.borde),
      ],
    ];
  }

  Widget _filaInformacion(String etiqueta, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(etiqueta, style: const TextStyle(color: ColoresPublico.textoSecundario, fontSize: 13)),
        ),
        Expanded(
          child: Text(valor,
              style: const TextStyle(
                  color: ColoresPublico.textoPrimario,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _filaContacto({required IconData icono, required String valor, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icono, size: 16, color: ColoresPublico.textoSecundario),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                valor,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: onTap != null ? AppColores.turquesa : ColoresPublico.textoPrimario,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaPublica({required String titulo, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColoresPublico.fondoTarjeta,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColoresPublico.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: ColoresPublico.textoPrimario)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _piePublico(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: ColoresPublico.borde)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.groups_rounded, size: 16, color: ColoresPublico.textoSecundario),
              SizedBox(width: 8),
              Text('ESPOL Comunidades',
                  style: TextStyle(color: ColoresPublico.textoSecundario, fontSize: 13)),
            ],
          ),
          TextButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go(Rutas.publico),
            child: const Text('Volver al catálogo'),
          ),
        ],
      ),
    );
  }
}

class _EsqueletoDetalle extends StatelessWidget {
  const _EsqueletoDetalle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Esqueleto(ancho: 260, alto: 30),
        SizedBox(height: 12),
        Esqueleto(ancho: 180, alto: 16),
        SizedBox(height: 32),
        Esqueleto(ancho: 190, alto: 44),
        SizedBox(height: 40),
        Esqueleto(alto: 14),
        SizedBox(height: 10),
        Esqueleto(alto: 14),
        SizedBox(height: 10),
        Esqueleto(ancho: 240, alto: 14),
      ],
    );
  }
}
