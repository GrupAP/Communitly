// Pruebas del detalle público en ancho de teléfono: sin sesión, ninguna fila
// debería desbordarse (RenderFlex) en un ancho angosto real de celular.

import 'package:communitly_frontend/pantallas/detalle.dart';
import 'package:communitly_frontend/servicios/cliente_api.dart';
import 'package:communitly_frontend/servicios/sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'ayuda.dart';

/// Comunidad con todos los campos opcionales llenos y un nombre largo, para
/// forzar el peor caso de ancho en la migaja de pan y el encabezado.
Map<String, dynamic> detalleJsonCompleto() => {
      'id': 1,
      'nombre': 'Comunidad Estudiantil de Prueba con Nombre Bastante Largo',
      'descripcion': 'Descripción larga de la comunidad, pensada para '
          'comprobar que el texto se ajusta en pantallas angostas sin que '
          'ninguna fila se desborde.',
      'categoria': 'Ingeniería',
      'facultad': 'FIEC',
      'facultad_descripcion': 'Ingeniería en Electricidad y Computación',
      'contacto': 'club@espol.edu.ec',
      'logo': '',
      'instagram': 'https://www.instagram.com/clubdeprueba/',
      'nivel_actividad': 'activo',
      'seguidores': 128,
      'carrera': 'Ingeniería en Electricidad y Computación',
      'fundado': '2015',
      'reuniones': 'Martes 18h00',
      'lugar_reuniones': 'Bloque 12, FIEC',
      'membresia': 'Abierta a todos los estudiantes',
      'publicaciones_instagram': [
        {
          'url': 'https://www.instagram.com/clubdeprueba/p/ABC123/',
          'titulo': 'Charla de bienvenida a los nuevos miembros del semestre',
          'imagen': '',
        },
        {
          'url': 'https://www.instagram.com/clubdeprueba/p/DEF456/',
          'titulo': 'Taller práctico de introducción',
          'imagen': '',
        },
      ],
    };

/// Comunidad sin ningún campo opcional, para comprobar que las tarjetas
/// "Información" y "Contacto y redes" simplemente no aparecen (en vez de
/// mostrarse vacías) también en un ancho angosto.
Map<String, dynamic> detalleJsonMinimo() => {
      'id': 2,
      'nombre': 'Club Mínimo',
      'descripcion': 'Descripción corta.',
      'categoria': 'Cultura',
      'facultad': '',
      'facultad_descripcion': '',
      'contacto': '',
      'logo': '',
      'instagram': '',
      'nivel_actividad': 'sin_verificar',
      'seguidores': 0,
      'carrera': '',
      'fundado': '',
      'reuniones': '',
      'lugar_reuniones': '',
      'membresia': '',
      'publicaciones_instagram': [],
    };

void main() {
  tearDown(() {
    Sesion.cerrar();
    ClienteApi.cliente = http.Client();
  });

  // 320 = iPhone SE (1.ª gen.), el más angosto que sigue circulando; 360 y
  // 390 cubren la mayoría de Android/iPhone actuales.
  for (final ancho in [320.0, 360.0, 390.0]) {
    testWidgets('el detalle público con todos los datos no se desborda a '
        '${ancho.toInt()} px', (tester) async {
      tester.view.physicalSize = Size(ancho, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      responderCon(detalleJsonCompleto());

      await montar(
        tester,
        const PantallaDetalle(comunidadId: 1, publico: true),
      );
      await asentar(tester);

      expect(tester.takeException(), isNull);
      expect(
        find.text('Comunidad Estudiantil de Prueba con Nombre Bastante Largo'),
        findsWidgets,
      );
      expect(find.text('Información'), findsOneWidget);
      expect(find.text('Actividad reciente'), findsOneWidget);
    });

    testWidgets('el detalle público sin datos opcionales no se desborda a '
        '${ancho.toInt()} px', (tester) async {
      tester.view.physicalSize = Size(ancho, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      responderCon(detalleJsonMinimo());

      await montar(
        tester,
        const PantallaDetalle(comunidadId: 2, publico: true),
      );
      await asentar(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Club Mínimo'), findsWidgets);
      // Sin datos opcionales, esas tarjetas no deben aparecer vacías.
      expect(find.text('Información'), findsNothing);
      expect(find.text('Contacto y redes'), findsNothing);
    });
  }
}
