// Fotografia do editor: o que está aberto, o que mudou e o que está soando.
import 'dart:convert';

import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../../nucleo/modelo/slot_preset.dart';

const Object _manter = Object();

class EstadoEditor {
  const EstadoEditor({
    this.slot,
    this.original,
    this.atual,
    this.selecionado,
    this.aoVivo = true,
    this.carregando = false,
    this.salvando = false,
    this.latencia,
    this.aviso,
    this.blocoCopiado,
    this.escolhendoDestino = false,
    this.slotNaPedaleira = false,
  });

  final SlotPreset? slot;

  /// Como está gravado no aparelho (null = ainda não gravado).
  final DocumentoPreset? original;
  final DocumentoPreset? atual;
  final PosicaoBloco? selecionado;
  final bool aoVivo;
  final bool carregando;

  /// Gravação em curso: abrir outro slot ou salvar de novo fica bloqueado até
  /// ela terminar, senão o resultado dela cairia por cima do que foi aberto.
  final bool salvando;

  /// Ler ou gravar em curso: o preset na tela não pode ser trocado nem salvo.
  bool get ocupado => carregando || salvando;

  /// Ida e volta do último envio ao vivo.
  final Duration? latencia;
  final String? aviso;
  final Map<String, dynamic>? blocoCopiado;

  /// "Salvar como" em curso: tocar num slot da lista escolhe o destino.
  final bool escolhendoDestino;

  /// A pedaleira trocou para o slot aberto (Program Change). Falso = só audição.
  final bool slotNaPedaleira;

  bool get naoSalvo {
    final editado = atual;
    if (editado == null) return false;
    final gravado = original;
    return gravado == null || _semCena(editado) != _semCena(gravado);
  }

  /// Trocar de cena é tocar, não editar: a cena ativa não conta como mudança
  /// (mas vai junto quando o preset é salvo).
  static String _semCena(DocumentoPreset documento) {
    final json = documento.paraJson();
    (json['preset'] as Map<String, dynamic>).remove('scene');
    return jsonEncode(json);
  }

  BlocoPreset? get blocoSelecionado {
    final posicao = selecionado;
    return posicao == null ? null : atual?.bloco(posicao);
  }

  EstadoEditor copiar({
    Object? slot = _manter,
    Object? original = _manter,
    Object? atual = _manter,
    Object? selecionado = _manter,
    bool? aoVivo,
    bool? carregando,
    bool? salvando,
    Object? latencia = _manter,
    Object? aviso = _manter,
    Object? blocoCopiado = _manter,
    bool? escolhendoDestino,
    bool? slotNaPedaleira,
  }) =>
      EstadoEditor(
        slot: identical(slot, _manter) ? this.slot : slot as SlotPreset?,
        original: identical(original, _manter) ? this.original : original as DocumentoPreset?,
        atual: identical(atual, _manter) ? this.atual : atual as DocumentoPreset?,
        selecionado: identical(selecionado, _manter) ? this.selecionado : selecionado as PosicaoBloco?,
        aoVivo: aoVivo ?? this.aoVivo,
        carregando: carregando ?? this.carregando,
        salvando: salvando ?? this.salvando,
        latencia: identical(latencia, _manter) ? this.latencia : latencia as Duration?,
        aviso: identical(aviso, _manter) ? this.aviso : aviso as String?,
        blocoCopiado:
            identical(blocoCopiado, _manter) ? this.blocoCopiado : blocoCopiado as Map<String, dynamic>?,
        escolhendoDestino: escolhendoDestino ?? this.escolhendoDestino,
        slotNaPedaleira: slotNaPedaleira ?? this.slotNaPedaleira,
      );
}
