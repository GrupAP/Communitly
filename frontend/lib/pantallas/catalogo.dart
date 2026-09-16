import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../estado/estado_async.dart';
import '../modelos/comunidad.dart';
import '../modelos/usuario.dart';
import '../rutas/rutas.dart';
import '../servicios/api.dart';
import '../servicios/preferencias.dart';
import '../servicios/sesion.dart';
import '../tema/tema.dart';
import '../tema/tema_publico.dart';
import '../widgets/esqueletos.dart';
import '../widgets/etiqueta_actividad.dart';
import '../widgets/monograma_club.dart';
import '../widgets/nav_publico.dart';
import '../widgets/rejilla_responsiva.dart';
import '../widgets/vista_async.dart';
import 'eventos.dart';

/// RF-01 a RF-03: catálogo de comunidades con búsqueda y filtro por categoría.
class PantallaCatalogo extends StatefulWidget {
  /// Vista pública (sin sesión): solo lectura, sin seguir, solicitudes ni
  /// eventos. Pensada para quien todavía no tiene cuenta institucional.
  final bool publico;

  const PantallaCatalogo({super.key, this.publico = false});

  @override
  State<PantallaCatalogo> createState() => _PantallaCatalogoState();
}

class _PantallaCatalogoState extends State<PantallaCatalogo> {
  final _buscador = TextEditingController();

  Estado<List<Comunidad>> _estado = const Cargando();
  List<String> _categorias = const [];
  List<String> _facultades = const [];
  String _categoriaActiva = '';
  String _facultadActiva = '';
  // Estos los usa solo la vista pública (RF-01 público).
  String _nivelActividadActivo = '';
  /// '' = recomendado (orden del backend), 'seguidores' = más seguidos primero.
  String _ordenPublico = '';
  /// Total sin filtrar, para las estadísticas del encabezado público.
  int _totalClubes = 0;
  Timer? _retrasoBusqueda;

  /// Contador de peticiones. Sin él, filtrar rápido podía pintar el resultado
  /// de una búsqueda anterior encima de la actual, porque nada garantiza que
  /// las respuestas lleguen en el orden en que se pidieron.
  int _ultimaPeticion = 0;

  bool get _hayFiltros =>
      _buscador.text.trim().isNotEmpty ||
      _categoriaActiva.isNotEmpty ||
      _facultadActiva.isNotEmpty ||
      _nivelActividadActivo.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _retrasoBusqueda?.cancel();
    _buscador.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final peticion = ++_ultimaPeticion;
    final texto = _buscador.text.trim();

    setState(() => _estado = const Cargando());

    try {
      final lista = await Api.listarComunidades(
        texto: texto,
        categoria: _categoriaActiva,
        facultad: _facultadActiva,
        nivelActividad: _nivelActividadActivo,
      );
      if (!mounted || peticion != _ultimaPeticion) return;

      setState(() {
        _estado = ConDatos(lista);
        // Las categorías, facultades y el total solo se deducen de un listado
        // sin filtrar; con filtros la lista sería incompleta.
        if (_categorias.isEmpty && !_hayFiltros) {
          _categorias = lista.map((c) => c.categoria).toSet().toList()..sort();
        }
        if (_facultades.isEmpty && !_hayFiltros) {
          _facultades = lista
              .map((c) => c.facultad)
              .where((f) => f.isNotEmpty)
              .toSet()
              .toList()
            ..sort();
        }
        if (_totalClubes == 0 && !_hayFiltros) {
          _totalClubes = lista.length;
        }
      });
    } catch (error) {
      if (!mounted || peticion != _ultimaPeticion) return;
      setState(() => _estado = ConError.desde(error));
    }
  }

  /// La búsqueda se dispara sola mientras se escribe, con una pausa para no
  /// lanzar una petición por tecla.
  void _buscarConRetraso() {
    _retrasoBusqueda?.cancel();
    _retrasoBusqueda = Timer(const Duration(milliseconds: 350), _cargar);
  }

  void _filtrarPorCategoria(String categoria) {
    setState(() => _categoriaActiva = categoria);
    _cargar();
  }

  void _filtrarPorFacultad(String facultad) {
    setState(() => _facultadActiva = facultad);
    _cargar();
  }

  void _filtrarPorNivelActividad(String nivel) {
    setState(() => _nivelActividadActivo = nivel);
    _cargar();
  }

  void _limpiarFiltros() {
    _retrasoBusqueda?.cancel();
    _buscador.clear();
    setState(() {
      _categoriaActiva = '';
      _facultadActiva = '';
      _nivelActividadActivo = '';
    });
    _cargar();
  }

  Future<void> _abrirDetalle(int id) async {
    if (widget.publico) {
      // Sin sesión no hay nada que recargar al volver: la vista pública no
      // tiene acciones que cambien el estado de la comunidad.
      await context.push<void>(Rutas.publicoComunidad(id));
      return;
    }

    // Al volver del detalle se recarga: el estudiante pudo seguir la comunidad
    // o enviar una solicitud desde allí.
    await context.push<void>(Rutas.comunidad(id));
    if (mounted) await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.publico) return _buildPublico(context);

    final usuario = Sesion.actualONulo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ESPOL Communities'),
        actions: _acciones(context, usuario),
      ),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Descubre tu próxima comunidad',
                    style: context.textos.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _subtitulo(usuario),
                    style: context.textos.bodyMedium
                        ?.copyWith(color: context.textoSecundario),
                  ),
                  const SizedBox(height: 20),
                  _campoBusqueda(),
                  const SizedBox(height: 16),
                  _filtrosCategoria(),
                  if (_facultades.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _filtrosFacultad(),
                  ],
                  const SizedBox(height: 24),
                  _resultados(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _subtitulo(UsuarioSesion? usuario) {
    if (usuario == null) return '';
    return usuario.esGestor
        ? 'Conectado como ${usuario.usuario} · gestor'
        : 'Conectado como ${usuario.usuario}';
  }

  List<Widget> _acciones(BuildContext context, UsuarioSesion? usuario) {
    return [
      // RF-03: entrada al modulo de eventos. Sin colores fijos, para que
      // siga el tema claro u oscuro como el resto de la barra.
      TextButton.icon(
        onPressed: () => unawaited(Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const PantallaEventos()),
        )),
        icon: const Icon(Icons.event),
        label: const Text('Eventos'),
      ),
      _botonTema(context),
      IconButton(
        onPressed: () => context.push(Rutas.solicitudes),
        icon: const Icon(Icons.assignment_outlined),
        tooltip: 'Mis solicitudes',
      ),
      IconButton(
        onPressed: Sesion.cerrar,
        icon: const Icon(Icons.logout),
        tooltip: usuario == null
            ? 'Cerrar sesión'
            : 'Cerrar sesión (${usuario.usuario})',
      ),
    ];
  }

  Widget _botonTema(BuildContext context) {
    return IconButton(
      onPressed: () => PreferenciasUi.alternar(Theme.of(context).brightness),
      icon: Icon(Theme.of(context).brightness == Brightness.dark
          ? Icons.light_mode_outlined
          : Icons.dark_mode_outlined),
      tooltip: 'Cambiar el tema',
    );
  }

  Widget _campoBusqueda() {
    return TextField(
      controller: _buscador,
      // El setState es para que aparezca o desaparezca la "x" de limpiar.
      onChanged: (_) {
        setState(() {});
        _buscarConRetraso();
      },
      onSubmitted: (_) => _cargar(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Buscar por nombre, categoría o interés...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _buscador.text.isEmpty
            ? null
            : IconButton(
                onPressed: _limpiarFiltros,
                icon: const Icon(Icons.close),
                tooltip: 'Limpiar la búsqueda',
              ),
      ),
    );
  }

  Widget _filtrosCategoria() {
    if (_categorias.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('Todas'),
          selected: _categoriaActiva.isEmpty,
          onSelected: (_) => _filtrarPorCategoria(''),
        ),
        for (final categoria in _categorias)
          FilterChip(
            label: Text(categoria),
            selected: _categoriaActiva == categoria,
            onSelected: (_) => _filtrarPorCategoria(categoria),
          ),
      ],
    );
  }

  /// Filtro por facultad (p. ej. FIEC, FIMCP...), para que un estudiante de
  /// colegio pueda explorar los clubes de la carrera que le interesa.
  Widget _filtrosFacultad() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('Todas las facultades'),
          selected: _facultadActiva.isEmpty,
          onSelected: (_) => _filtrarPorFacultad(''),
        ),
        for (final facultad in _facultades)
          FilterChip(
            label: Text(facultad),
            selected: _facultadActiva == facultad,
            onSelected: (_) => _filtrarPorFacultad(facultad),
          ),
      ],
    );
  }

  Widget _resultados() {
    return VistaAsync<List<Comunidad>>(
      estado: _estado,
      cargando: const EsqueletoRejilla(),
      alReintentar: _cargar,
      estaVacio: (lista) => lista.isEmpty,
      iconoVacio: Icons.search_off,
      tituloVacio: 'No encontramos comunidades',
      detalleVacio: _hayFiltros
          ? 'Prueba con otras palabras o quita los filtros.'
          : 'Todavía no hay comunidades publicadas.',
      textoAccionVacio: _hayFiltros ? 'Limpiar filtros' : null,
      alPulsarAccionVacio: _hayFiltros ? _limpiarFiltros : null,
      constructor: (context, lista) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lista.length == 1
                ? '1 comunidad encontrada'
                : '${lista.length} comunidades encontradas',
            style: context.textos.bodyMedium
                ?.copyWith(color: context.textoSecundario),
          ),
          const SizedBox(height: 12),
          RejillaResponsiva(
            hijos: [for (final comunidad in lista) _tarjeta(comunidad)],
          ),
        ],
      ),
    );
  }

  Widget _tarjeta(Comunidad comunidad) {
    return Card(
      child: InkWell(
        onTap: () => _abrirDetalle(comunidad.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      comunidad.nombre,
                      style: context.textos.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (comunidad.siguiendo)
                    const Tooltip(
                      message: 'Ya sigues esta comunidad',
                      child: Icon(
                        Icons.check_circle,
                        size: 18,
                        color: AppColores.turquesa,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                [
                  comunidad.categoria,
                  if (comunidad.facultad.isNotEmpty) comunidad.facultad,
                  '${comunidad.seguidores} seguidores',
                ].join(' · '),
                style: context.textos.bodySmall
                    ?.copyWith(color: context.textoSecundario),
              ),
              if (comunidad.nivelActividad != 'sin_verificar') ...[
                const SizedBox(height: 6),
                EtiquetaActividad(nivel: comunidad.nivelActividad),
              ],
              const SizedBox(height: 8),
              Text(
                comunidad.descripcion,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Vista pública -------------------------------------------------------
  //
  // Layout propio (no el AppBar/Scaffold de arriba): catálogo de solo lectura
  // pensado para un visitante sin cuenta institucional, con su propia marca
  // fija (no sigue el tema claro/oscuro, igual que el diseño del que sale).

  Widget _buildPublico(BuildContext context) {
    // Portada de marca fija: no debe alternar a oscuro con el tema del
    // sistema o de la app, ni siquiera en los widgets compartidos (esqueleto
    // de carga, estados vacíos) que sí son sensibles al tema ambiente.
    return Theme(
      data: AppTema.claro,
      child: Scaffold(
        backgroundColor: ColoresPublico.fondoPagina,
        body: RefreshIndicator(
          onRefresh: _cargar,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const NavPublico(),
                _heroPublico(context),
                _filterBarPublico(context),
                _gridPublico(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroPublico(BuildContext context) {
    final compacto = MediaQuery.sizeOf(context).width < 760;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(compacto ? 20 : 64, 48, compacto ? 20 : 64, 40),
      decoration: const BoxDecoration(gradient: ColoresPublico.heroGradiente),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CATÁLOGO PÚBLICO · SIN NECESIDAD DE CUENTA',
            style: TextStyle(
              color: ColoresPublico.heroAcento,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Descubre tu próxima comunidad',
            style: TextStyle(
              color: Colors.white,
              fontSize: compacto ? 30 : 44,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: const Text(
              'Explora los clubes y capítulos estudiantiles de ESPOL. Inicia '
              'sesión solo cuando quieras seguir uno o postular.',
              style: TextStyle(color: ColoresPublico.heroSubtexto, fontSize: 16, height: 1.4),
            ),
          ),
          const SizedBox(height: 24),
          _buscadorPublico(),
          if (_totalClubes > 0) ...[
            const SizedBox(height: 22),
            Wrap(
              spacing: 28,
              runSpacing: 12,
              children: [
                _estadisticaPublica(
                  icono: Icons.groups_rounded,
                  valor: '$_totalClubes',
                  etiqueta: 'clubes activos',
                ),
                _estadisticaPublica(
                  icono: Icons.apartment_rounded,
                  valor: '${_facultades.length}',
                  etiqueta: 'facultades',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buscadorPublico() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 560),
      decoration: BoxDecoration(
        color: ColoresPublico.fondoTarjeta,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: ColoresPublico.textoSecundario),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _buscador,
              onChanged: (_) {
                setState(() {});
                _buscarConRetraso();
              },
              onSubmitted: (_) => _cargar(),
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: ColoresPublico.textoPrimario, fontSize: 14),
              cursorColor: ColoresPublico.textoPrimario,
              // La página pública no sigue el InputDecorationTheme global
              // (que en modo oscuro rellena el campo de negro): fondo
              // transparente y colores fijos, como el resto de esta vista.
              decoration: const InputDecoration(
                border: InputBorder.none,
                filled: false,
                isDense: true,
                hintText: 'Buscar por nombre, categoría o interés...',
                hintStyle: TextStyle(color: ColoresPublico.textoSecundario, fontSize: 14),
              ),
            ),
          ),
          FilledButton(
            onPressed: _cargar,
            style: FilledButton.styleFrom(
              backgroundColor: AppColores.turquesa,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            ),
            child: const Text('Buscar'),
          ),
        ],
      ),
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
        Icon(icono, size: 16, color: ColoresPublico.heroAcento),
        const SizedBox(width: 8),
        Text(valor,
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(width: 5),
        Text(etiqueta, style: const TextStyle(color: ColoresPublico.heroStatLabel, fontSize: 14)),
      ],
    );
  }

  Widget _filterBarPublico(BuildContext context) {
    final compacto = MediaQuery.sizeOf(context).width < 760;

    return Container(
      decoration: const BoxDecoration(
        color: ColoresPublico.fondoTarjeta,
        border: Border(bottom: BorderSide(color: ColoresPublico.borde)),
      ),
      padding: EdgeInsets.symmetric(horizontal: compacto ? 16 : 32, vertical: 14),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _pildoraSelector(
            etiqueta: 'Categoría',
            valor: _categoriaActiva.isEmpty ? 'Todas' : _categoriaActiva,
            onTap: _elegirCategoria,
          ),
          _pildoraSelector(
            etiqueta: 'Facultad',
            valor: _facultadActiva.isEmpty ? 'Todas' : _facultadActiva,
            onTap: _elegirFacultad,
          ),
          _pildoraSelector(
            etiqueta: 'Actividad',
            valor: _nombreNivelActividad(_nivelActividadActivo),
            onTap: _elegirNivelActividad,
          ),
          _ordenSelectorPublico(),
        ],
      ),
    );
  }

  Widget _pildoraSelector({
    required String etiqueta,
    required String valor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: ColoresPublico.fondoTarjeta,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColoresPublico.borde),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$etiqueta: ',
                style: const TextStyle(fontSize: 12, color: ColoresPublico.textoSecundario)),
            Text(valor,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ColoresPublico.textoPrimario)),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: ColoresPublico.textoSecundario),
          ],
        ),
      ),
    );
  }

  Widget _ordenSelectorPublico() {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: _elegirOrden,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_vert_rounded, size: 16, color: ColoresPublico.textoSecundario),
            const SizedBox(width: 6),
            Text(
              _ordenPublico == 'seguidores' ? 'Más seguidos' : 'Recomendado',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: ColoresPublico.textoPrimario),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: ColoresPublico.textoSecundario),
          ],
        ),
      ),
    );
  }

  String _nombreNivelActividad(String nivel) => switch (nivel) {
        'activo' => 'Activo',
        'poco_activo' => 'Poco activo',
        'inactivo' => 'Inactivo',
        'sin_verificar' => 'Sin verificar',
        _ => 'Cualquiera',
      };

  Future<void> _elegirCategoria() async {
    final elegido = await _mostrarSelectorHoja(
      titulo: 'Categoría',
      actual: _categoriaActiva,
      opciones: [
        const MapEntry('Todas', ''),
        for (final c in _categorias) MapEntry(c, c),
      ],
    );
    if (elegido != null) _filtrarPorCategoria(elegido);
  }

  Future<void> _elegirFacultad() async {
    final elegido = await _mostrarSelectorHoja(
      titulo: 'Facultad',
      actual: _facultadActiva,
      opciones: [
        const MapEntry('Todas las facultades', ''),
        for (final f in _facultades) MapEntry(f, f),
      ],
    );
    if (elegido != null) _filtrarPorFacultad(elegido);
  }

  Future<void> _elegirNivelActividad() async {
    final elegido = await _mostrarSelectorHoja(
      titulo: 'Actividad',
      actual: _nivelActividadActivo,
      opciones: const [
        MapEntry('Cualquiera', ''),
        MapEntry('Activo', 'activo'),
        MapEntry('Poco activo', 'poco_activo'),
        MapEntry('Inactivo', 'inactivo'),
        MapEntry('Sin verificar', 'sin_verificar'),
      ],
    );
    if (elegido != null) _filtrarPorNivelActividad(elegido);
  }

  Future<void> _elegirOrden() async {
    final elegido = await _mostrarSelectorHoja(
      titulo: 'Ordenar por',
      actual: _ordenPublico,
      opciones: const [
        MapEntry('Recomendado', ''),
        MapEntry('Más seguidos primero', 'seguidores'),
      ],
    );
    if (elegido != null) setState(() => _ordenPublico = elegido);
  }

  Future<String?> _mostrarSelectorHoja({
    required String titulo,
    required String actual,
    required List<MapEntry<String, String>> opciones,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            ),
            RadioGroup<String>(
              groupValue: actual,
              onChanged: (valor) => Navigator.pop(context, valor),
              child: Column(
                children: [
                  for (final opcion in opciones)
                    RadioListTile<String>(
                      value: opcion.value,
                      title: Text(opcion.key),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _gridPublico(BuildContext context) {
    return VistaAsync<List<Comunidad>>(
      estado: _estado,
      cargando: const Padding(
        padding: EdgeInsets.all(24),
        child: EsqueletoRejilla(),
      ),
      alReintentar: _cargar,
      estaVacio: (lista) => lista.isEmpty,
      iconoVacio: Icons.search_off,
      tituloVacio: 'No encontramos comunidades',
      detalleVacio: _hayFiltros
          ? 'Prueba con otras palabras o quita los filtros.'
          : 'Todavía no hay comunidades publicadas.',
      textoAccionVacio: _hayFiltros ? 'Limpiar filtros' : null,
      alPulsarAccionVacio: _hayFiltros ? _limpiarFiltros : null,
      constructor: (context, lista) {
        final ordenada = [...lista];
        if (_ordenPublico == 'seguidores') {
          ordenada.sort((a, b) => b.seguidores.compareTo(a.seguidores));
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ordenada.length == 1
                    ? '1 comunidad encontrada'
                    : '${ordenada.length} comunidades encontradas',
                style: const TextStyle(
                    color: ColoresPublico.textoSecundario,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              RejillaResponsiva(
                hijos: [for (final c in ordenada) _tarjetaPublica(c)],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tarjetaPublica(Comunidad c) {
    final iniciales = inicialesClub(c.nombre);
    final colorLogo = colorMonograma(c.nombre);

    return Container(
      decoration: BoxDecoration(
        color: ColoresPublico.fondoTarjeta,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColoresPublico.borde),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _abrirDetalle(c.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 100,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(color: AppColores.azulEspol, width: double.infinity, height: 100),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: EtiquetaActividad(nivel: c.nivelActividad),
                  ),
                  Positioned(
                    left: 16,
                    bottom: -24,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: colorLogo,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        iniciales,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.nombre,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: ColoresPublico.textoPrimario),
                        ),
                      ),
                      if (c.instagram.isNotEmpty)
                        const Icon(Icons.camera_alt_outlined,
                            size: 16, color: ColoresPublico.textoSecundario),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      c.categoria,
                      if (c.facultad.isNotEmpty) c.facultad,
                      '${c.seguidores} seguidores',
                    ].join(' · '),
                    style: const TextStyle(fontSize: 12, color: ColoresPublico.textoSecundario),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    c.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, color: ColoresPublico.textoSecundario, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
