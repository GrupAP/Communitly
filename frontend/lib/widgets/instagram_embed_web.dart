import 'dart:async';
import 'dart:html' as html;
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

@JS('window.instgrm.Embeds.process')
external void _procesarEmbedsJs();

/// Incrusta una publicación pública de Instagram con su widget de embed
/// oficial (`blockquote` + `embed.js`): el mismo mecanismo que usa cualquier
/// sitio para "pegar" un post. No necesita token ni OAuth porque no trae el
/// feed de la cuenta, solo publicaciones puntuales que un gestor curó a mano
/// (Instagram no deja listar el feed de una cuenta ajena sin que esa cuenta
/// autorice nuestra app).
class InstagramEmbed extends StatefulWidget {
  final String url;

  const InstagramEmbed({super.key, required this.url});

  @override
  State<InstagramEmbed> createState() => _InstagramEmbedState();
}

class _InstagramEmbedState extends State<InstagramEmbed> {
  static const _idScript = 'instagram-embed-js';
  late final String _tipoVista;

  @override
  void initState() {
    super.initState();
    _tipoVista = 'instagram-embed-${identityHashCode(this)}';
    ui_web.platformViewRegistry.registerViewFactory(_tipoVista, _crearElemento);
  }

  html.Element _crearElemento(int idVista) {
    final contenedor = html.DivElement()
      ..style.width = '100%'
      ..style.display = 'flex'
      ..style.justifyContent = 'center';

    final blockquote = html.Element.tag('blockquote')
      ..className = 'instagram-media'
      ..style.margin = '0'
      ..style.width = '100%'
      ..style.maxWidth = '540px'
      ..style.minWidth = '260px';
    blockquote.setAttribute('data-instgrm-permalink', widget.url);
    blockquote.setAttribute('data-instgrm-version', '14');

    contenedor.append(blockquote);
    _cargarEmbedJs();
    return contenedor;
  }

  void _procesarEmbeds() {
    try {
      _procesarEmbedsJs();
    } catch (_) {
      // Si Instagram cambia su widget o embed.js aun no definio `instgrm`,
      // esto no debe tumbar la pagina: el post queda como enlace de texto.
    }
  }

  void _cargarEmbedJs() {
    if (html.document.getElementById(_idScript) != null) {
      // El script ya está cargado de un post anterior: solo hay que pedirle
      // que reprocese los blockquotes nuevos que aparecieron en el DOM.
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
    return SizedBox(
      height: 560,
      child: HtmlElementView(viewType: _tipoVista),
    );
  }
}
