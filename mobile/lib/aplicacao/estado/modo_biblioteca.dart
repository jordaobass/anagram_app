// Modo Biblioteca (DECISOES BB1): o interruptor ao lado do "Ao vivo" troca a
// lista de presets da pedaleira pela biblioteca de presets prontos por banda.
// Abrir um deles só o toca (temporário); aplicar escolhe um slot da lista da
// pedaleira, então o modo sai sozinho quando a escolha de destino começa.
// Desconectar também o desliga: a lista volta a ser a da pedaleira.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/modelo/biblioteca_bandas.dart';
import 'biblioteca_presets.dart';
import 'controlador_conexao.dart';
import 'controlador_editor.dart';
import 'estado_conexao.dart';

final modoBibliotecaProvider = NotifierProvider<ModoBiblioteca, bool>(ModoBiblioteca.new);

class ModoBiblioteca extends Notifier<bool> {
  @override
  bool build() {
    ref.listen(conexaoProvider, (_, estado) {
      if (estado is SemConexao) state = false;
    });
    ref.listen(editorProvider.select((e) => e.escolhendoDestino), (_, escolhendo) {
      if (escolhendo) state = false;
    });
    return false;
  }

  /// Ligar relê a pasta da biblioteca: arquivo posto nela por fora (BB4)
  /// aparece sem reabrir o app.
  void definir(bool ligado) {
    if (ligado && !state) ref.invalidate(fonteBibliotecaProvider);
    state = ligado;
  }
}

/// Busca, ordem e coleções recolhidas da lista do modo Biblioteca (BB3).
/// Ficam enquanto o app está aberto: no celular a lista é outra tela, e
/// voltar a ela não pode apagar a busca.
class FiltroBiblioteca {
  const FiltroBiblioteca({this.busca = '', this.ordem = OrdemBiblioteca.arquivo, this.recolhidas = const {}});

  final String busca;
  final OrdemBiblioteca ordem;

  /// Nomes das coleções fechadas (com busca, todas abrem: o achado aparece).
  final Set<String> recolhidas;

  bool recolhida(String colecao) => busca.trim().isEmpty && recolhidas.contains(colecao);
}

final filtroBibliotecaProvider = NotifierProvider<ControladorFiltroBiblioteca, FiltroBiblioteca>(
  ControladorFiltroBiblioteca.new,
);

class ControladorFiltroBiblioteca extends Notifier<FiltroBiblioteca> {
  @override
  FiltroBiblioteca build() => const FiltroBiblioteca();

  void buscar(String busca) => state = FiltroBiblioteca(busca: busca, ordem: state.ordem, recolhidas: state.recolhidas);

  void ordenar(OrdemBiblioteca ordem) =>
      state = FiltroBiblioteca(busca: state.busca, ordem: ordem, recolhidas: state.recolhidas);

  void alternarColecao(String colecao) {
    final recolhidas = {...state.recolhidas};
    if (!recolhidas.remove(colecao)) recolhidas.add(colecao);
    state = FiltroBiblioteca(busca: state.busca, ordem: state.ordem, recolhidas: recolhidas);
  }
}
