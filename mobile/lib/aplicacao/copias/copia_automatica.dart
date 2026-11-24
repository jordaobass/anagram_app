// Backup automático antes de gravar (DECISOES BK1): toda escrita que substitui
// um slot ocupado — Salvar, Salvar como, clonar, mover, trocar bancos, limpar
// e o save_preset do MCP — guarda antes o que está no slot. Falhou o backup,
// a escrita não acontece: o backup é a rede de segurança da gravação.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dados/preferencias_copias.dart';
import '../../dados/repositorio_pedaleira.dart';
import '../../nucleo/modelo/copia_preset.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../../nucleo/protocolo/erros_anagram.dart';
import '../../nucleo/registro.dart';
import '../../nucleo/resultado.dart';
import '../../plataforma/abrir_link.dart';
import '../../plataforma/copias_de_seguranca.dart';
import '../casos_de_uso/transferir_preset.dart';

/// A pasta de backups; o `main` a liga no computador e entrega por override.
/// Nula no celular e no web (e nos testes que não a pedem).
final pastaDeCopiasProvider = Provider<PastaDeCopias?>((ref) => null);

/// Abre a pasta no gerenciador de arquivos (os testes trocam por um falso).
final abridorDePastaProvider = Provider<Future<bool> Function(String caminho)>((ref) => abrirPasta);

final preferenciasCopiasProvider = Provider<PreferenciasCopias>((ref) => PreferenciasCopiasLocais());

/// O interruptor como estava guardado; o `main` lê antes da primeira tela,
/// para a primeira gravação já respeitar quem desligou. Sem leitura, ligado.
final copiaAutomaticaSalvaProvider = Provider<bool>((ref) => true);

/// O interruptor das Configurações.
final copiaAutomaticaProvider = NotifierProvider<ControladorCopiaAutomatica, bool>(ControladorCopiaAutomatica.new);

class ControladorCopiaAutomatica extends Notifier<bool> {
  @override
  bool build() => ref.read(copiaAutomaticaSalvaProvider);

  Future<void> definir(bool ligada) async {
    state = ligada;
    registro.i('backup: automático ${ligada ? 'ligado' : 'desligado'} nas Configurações');
    await ref.read(preferenciasCopiasProvider).gravarAutomatica(ligada);
  }
}

/// Quem grava na pedaleira chama isto antes; nulo = sem backup (celular,
/// web, ou a pessoa desligou o interruptor).
final guardaDeCopiaProvider = Provider<GuardaDeCopia?>((ref) {
  final pasta = ref.watch(pastaDeCopiasProvider);
  if (pasta == null || !ref.watch(copiaAutomaticaProvider)) return null;
  return GuardaDeCopia(pasta);
});

class GuardaDeCopia {
  const GuardaDeCopia(this._pasta);

  final PastaDeCopias _pasta;

  /// Guarda [atual] (o que está no slot e vai ser substituído). Nulo = pode
  /// gravar; o erro já foi registrado com o caminho e a causa.
  Future<ErroCopiaDeSeguranca?> antesDeSubstituir(DocumentoPreset atual, SlotPreset slot, String? area) async {
    final origem = OrigemDaCopia(slot: slot, area: area, nome: atual.nome);
    try {
      final caminho = await _pasta.guardar(origem, TransferirPreset.textoDoPreset(atual));
      registro.i('backup: ${slot.rotulo} (${area ?? areaUnicaNaCopia}) "${atual.nome}" guardado em $caminho');
      return null;
    } on Object catch (erro, pilha) {
      registro.e('backup: ${slot.rotulo} não foi guardado em ${_pasta.caminho}; nada vai para a pedaleira',
          error: erro, stackTrace: pilha);
      return ErroCopiaDeSeguranca('Backup de ${slot.rotulo} falhou: $erro', pasta: _pasta.caminho);
    }
  }

  /// Para quem ainda não leu o slot (limpar, trocar): lê e guarda se houver
  /// preset. Slot vazio não tem o que guardar.
  Future<ErroAnagram?> lerEGuardar(RepositorioPedaleira repositorio, SlotPreset slot, String? area) async {
    return switch (await repositorio.lerPreset(slot, area: area)) {
      Sucesso(valor: final DocumentoPreset atual) => antesDeSubstituir(atual, slot, area),
      Sucesso() => null,
      Falha(:final erro) => erro,
    };
  }

  /// [lerEGuardar] de cada slot, parando no primeiro erro.
  Future<ErroAnagram?> lerEGuardarTodos(RepositorioPedaleira repositorio, Iterable<SlotPreset> slots, String? area) async {
    for (final slot in slots) {
      if (await lerEGuardar(repositorio, slot, area) case final erro?) return erro;
    }
    return null;
  }
}
