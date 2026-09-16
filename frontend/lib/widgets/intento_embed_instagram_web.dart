import 'dart:async';
import 'dart:html' as html;
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

@JS('window.instgrm.Embeds.process')
external void _procesarEmbedsJs();

/// Prueba en segundo plano el embed oficial de Instagram (`blockquote` +
/// `embed.js`) encogido al mismo tamaño cuadrado que la miniatura curada de
/// [TarjetaActividad], por si el navegador de quien mira SÍ permite el
/// acceso a almacenamiento de terceros que ese iframe necesita para
/// dibujarse (la mayoría de navegadores actuales lo bloquean por defecto:
/// Tracking Prevention, Total Cookie Protection, Shields... y el post queda
/// en blanco). Mientras no se confirme que cargó, este widget no pinta nada
/// encima de la miniatura/marcador de abajo.
class IntentoEmbedInstagram extends StatefulWidget {
  final String url;
  final double lado;

  const IntentoEmbedInstagram({super.key, required this.url, required this.lado});

  @override
  State<IntentoEmbedInstagram> createState() => _IntentoEmbedInstagramState();
}

class _IntentoEmbedInstagramState extends State<IntentoEmbedInstagram> {
  static const _idScript = 'instagram-embed-js';
  // Ancho "natural" con el que se arma el embed antes de encogerlo: por
  // debajo de esto Instagram no acepta dibujarlo (min-width real: 260px).
  static const _anchoNatural = 400.0;

  late final String _tipoVista;
  html.Element? _contenedor;
  Timer? _timerVerificacion;
  bool _cargo = false;

  @override
  void initState() {
    super.initState();
    _tipoVista = 'instagram-embed-${identityHashCode(this)}';
    ui_web.platformViewRegistry.registerViewFactory(_tipoVista, _crearElemento);
  }

  @override
  void dispose() {
    _timerVerificacion?.cancel();
    super.dispose();
  }

  html.Element _crearElemento(int idVista) {
    final contenedor = html.DivElement()..style.width = '100%';
    _contenedor = contenedor;

    final blockquote = html.Element.tag('blockquote')
      ..className = 'instagram-media'
      ..style.margin = '0'
      ..style.width = '${_anchoNatural}px'
      ..style.minWidth = '${_anchoNatural}px'
      ..style.maxWidth = '${_anchoNatural}px';
    blockquote.setAttribute('data-instgrm-permalink', widget.url);
    blockquote.setAttribute('data-instgrm-version', '14');

    contenedor.append(blockquote);
    _cargarEmbedJs();
    // Igual que en el detalle: un embed que carga bien inserta su <iframe> y
    // lo estira a su alto real en un par de segundos via postMessage; si el
    // navegador lo bloquea, el iframe queda en el DOM colapsado a ~1px.
    _timerVerificacion = Timer(const Duration(seconds: 5), _verificarCarga);
    return contenedor;
  }

  void _verificarCarga() {
    final iframe = _contenedor?.querySelector('iframe');
    final alto = iframe?.offsetHeight ?? 0;
    if (iframe != null && alto > 100 && mounted) {
      setState(() => _cargo = true);
    }
  }

  void _procesarEmbeds() {
    try {
      _procesarEmbedsJs();
    } catch (_) {
      // Si Instagram cambia su widget o embed.js aun no definio `instgrm`,
      // el timer de verificacion ya se encarga de dejar todo como estaba.
    }
  }

  void _cargarEmbedJs() {
    if (html.document.getElementById(_idScript) != null) {
      Timer(const Duration(milliseconds: 100), _procesarEmbeds);
      return;
    }

    final script = html.ScriptElement()
      ..id = _idScript
      ..src = 'https://www.instagram.com/embed.js'
      ..async = true;
    script.onLoad.listen((_) => _procesarEmbeds());
    script.onError.listen((_) {});
    html.document.body!.append(script);
  }

  @override
  Widget build(BuildContext context) {
    final escala = widget.lado / _anchoNatural;
    // Sigue montado (para que la carga en segundo plano continue) aunque no
    // haya cargado todavia; solo se hace visible cuando se confirma el alto.
    return IgnorePointer(
      ignoring: !_cargo,
      child: Opacity(
        opacity: _cargo ? 1 : 0,
        child: ClipRect(
          child: Align(
            alignment: Alignment.topLeft,
            child: Transform.scale(
              scale: escala,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: _anchoNatural,
                height: widget.lado / escala,
                child: HtmlElementView(viewType: _tipoVista),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
