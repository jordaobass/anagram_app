// Erro que nenhum código tratou (num widget ou num Future solto) vai para o
// registro do app, com a pilha: sem isto ele só aparece no console do
// Flutter, que a pessoa não vê e não tem como mandar. O comportamento padrão
// continua (nada é engolido): a tela vermelha em depuração, o relato do motor.
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../nucleo/registro.dart';

void registrarErrosNaoTratados() {
  final padraoDoFlutter = FlutterError.onError;
  FlutterError.onError = (detalhes) {
    registro.e('erro não tratado: ${detalhes.context ?? detalhes.library ?? 'flutter'}',
        error: detalhes.exception, stackTrace: detalhes.stack);
    padraoDoFlutter?.call(detalhes);
  };
  final padraoDaPlataforma = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (erro, pilha) {
    registro.e('erro não tratado fora de widget', error: erro, stackTrace: pilha);
    // false: o motor continua relatando o erro como sempre
    return padraoDaPlataforma?.call(erro, pilha) ?? false;
  };
}
