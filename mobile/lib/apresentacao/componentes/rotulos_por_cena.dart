// Em que cenas vale o liga/desliga do bloco e o valor do knob (issue #39):
// "só na cena 2" só quando é verdade; com o mesmo estado em até três cenas,
// a lista delas; acima disso, que varia. Nulo = igual em todas as cenas.
import '../../l10n/app_localizations.dart';

/// Até quantas cenas a lista cabe no rótulo; acima disso, "varia entre as cenas".
const _cenasNaLista = 3;

String? rotuloLigaPorCena(AppLocalizations l, {required bool ligado, required List<int>? iguais}) =>
    switch (iguais) {
      null => null,
      [final unica] => ligado ? l.ligadoSoNaCena(unica) : l.desligadoSoNaCena(unica),
      _ when iguais.length <= _cenasNaLista =>
        ligado ? l.ligadoNasCenas(_lista(iguais)) : l.desligadoNasCenas(_lista(iguais)),
      _ => ligado ? l.ligadoVariaEntreCenas : l.desligadoVariaEntreCenas,
    };

String? rotuloValorPorCena(AppLocalizations l, {required List<int>? iguais}) => switch (iguais) {
      null => null,
      [final unica] => l.soNaCena(unica),
      _ when iguais.length <= _cenasNaLista => l.nasCenas(_lista(iguais)),
      _ => l.variaEntreCenas,
    };

String _lista(List<int> cenas) => cenas.join(', ');
