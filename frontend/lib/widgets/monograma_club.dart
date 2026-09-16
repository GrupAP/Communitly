import 'package:flutter/material.dart';

const _stopwordsMonograma = {'de', 'del', 'la', 'el', 'los', 'las', 'en', 'y'};

/// Iniciales para el "logo" del club en la vista pública: dos letras a partir
/// del nombre, sin contar conectores cortos ("Club de Arqueología" -> "CA").
String inicialesClub(String nombre) {
  final palabras = nombre
      .split(' ')
      .where((p) => p.isNotEmpty && !_stopwordsMonograma.contains(p.toLowerCase()))
      .toList();

  if (palabras.length >= 2) {
    return (palabras[0][0] + palabras[1][0]).toUpperCase();
  }

  final unica = palabras.isNotEmpty ? palabras.first : nombre;
  return unica.length >= 2
      ? unica.substring(0, 2).toUpperCase()
      : unica.toUpperCase();
}

const _paletaMonograma = [
  Color(0xFF2E7D4F),
  Color(0xFF3F6FB8),
  Color(0xFFB8860B),
  Color(0xFF8B3A3A),
  Color(0xFF6B4FA0),
  Color(0xFFC2703D),
  Color(0xFF0E7E92),
  Color(0xFF6B8E23),
];

/// Color del "logo" del club: no tenemos el logo real de cada uno, así que se
/// deriva del nombre (estable entre rebuilds) en vez de mostrar algo inventado
/// como si fuera su identidad visual real.
Color colorMonograma(String nombre) =>
    _paletaMonograma[nombre.hashCode.abs() % _paletaMonograma.length];
