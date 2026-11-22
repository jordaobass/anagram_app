// Contraste WCAG 2.x entre duas cores e o contorno que um botão de fato
// desenha (o Material de dentro dele), para os testes medirem o que se vê.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double contraste(Color a, Color b) {
  final (claro, escuro) = a.computeLuminance() > b.computeLuminance() ? (a, b) : (b, a);
  return (claro.computeLuminance() + 0.05) / (escuro.computeLuminance() + 0.05);
}

Material materialDoBotao(WidgetTester tester, Finder botao) =>
    tester.widget<Material>(find.descendant(of: botao, matching: find.byType(Material)).first);

BorderSide contornoDoBotao(WidgetTester tester, Finder botao) =>
    (materialDoBotao(tester, botao).shape! as OutlinedBorder).side;
