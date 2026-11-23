// Restaurar um backup (DECISOES BK6): a lista das Configurações abre o preset
// guardado no editor, sem slot, pelo mesmo caminho do importar. Nada volta
// para a pedaleira sem a pessoa ouvir e usar o "Salvar como" (que confirma o
// destino ocupado e passa pelo backup automático de novo).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/modelo/copia_preset.dart';
import '../../nucleo/registro.dart';
import '../casos_de_uso/transferir_preset.dart';
import '../estado/controlador_editor.dart';
import 'copia_automatica.dart';

/// Os backups na pasta, do mais novo para o mais velho; relido a cada abertura da lista.
final copiasGuardadasProvider = FutureProvider.autoDispose<List<CopiaGuardada>>((ref) async {
  final pasta = ref.watch(pastaDeCopiasProvider);
  if (pasta == null) return const [];
  try {
    return await pasta.listar();
  } on Object catch (erro) {
    registro.w('backup: a pasta ${pasta.caminho} não foi listada', error: erro);
    return const [];
  }
});

final restaurarCopiaProvider = Provider<RestaurarCopia>(RestaurarCopia.new);

class RestaurarCopia {
  RestaurarCopia(this._ref);

  final Ref _ref;

  /// [PresetImportado] já está no editor, sem slot; [ImportacaoRecusada] diz
  /// por quê (arquivo sumiu, JSON mexido), com a causa no registro.
  Future<ResultadoImportacao> abrir(CopiaGuardada copia) async {
    final pasta = _ref.read(pastaDeCopiasProvider);
    final String texto;
    try {
      if (pasta == null) throw StateError('sem pasta de backups');
      texto = await pasta.ler(copia);
    } on Object catch (erro) {
      registro.e('backup: ${copia.caminho} não foi lido', error: erro);
      return const ImportacaoRecusada(MotivoImportacao.arquivoIlegivel);
    }
    final resultado = TransferirPreset.interpretar(texto);
    if (resultado case PresetImportado(:final documento)) {
      await _ref.read(editorProvider.notifier).abrirSemSlot(documento);
      registro.i('backup: ${copia.caminho} aberto no editor, sem slot');
    }
    return resultado;
  }
}
