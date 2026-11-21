// Frases da tela para o que a aplicação e o núcleo informam por tipo (avisos,
// erros, motivos, famílias de bloco). Ficam aqui, e não lá, para o estado
// não depender de BuildContext e os logs continuarem em português.
//
// Os erros do protocolo trazem em `mensagem` o detalhe técnico (nome da ação,
// exceção de origem). Ele vai só para o log, onde foi registrado ao acontecer;
// a tela mostra, nos três idiomas, uma frase do tipo de erro. A exceção é a
// recusa do próprio app (ErroOperacaoEmCurso): a mensagem dela já é uma frase
// para a pessoa, e o português a mostra como está.
import '../aplicacao/avisos.dart';
import '../aplicacao/casos_de_uso/salvar_no_slot.dart';
import '../aplicacao/casos_de_uso/transferir_preset.dart';
import '../l10n/app_localizations.dart';
import '../nucleo/catalogo/arranjo_multibanda.dart';
import '../nucleo/catalogo/arranjo_parametros.dart';
import '../nucleo/catalogo/definicao_bloco.dart';
import '../nucleo/catalogo/familia_bloco.dart';
import '../nucleo/catalogo/formatador_valor.dart';
import '../nucleo/modelo/areas_presets.dart';
import '../nucleo/modelo/documento_preset.dart';
import '../nucleo/protocolo/erros_anagram.dart';
import '../nucleo/suporte_aparelho.dart';

extension TextosDoApp on AppLocalizations {
  /// Título de uma banda do Ignissor e do Entropia.
  String mbNomeDaBanda(BandaMultibanda banda) => switch (banda) {
        BandaMultibanda.graves => mbGraves,
        BandaMultibanda.medios => mbMedios,
        BandaMultibanda.agudos => mbAgudos,
      };

  /// Título de uma banda do paramétrico.
  String nomeDaBanda(BandaEq banda) => switch (banda) {
        BandaEq.geral => eqBandaGeral,
        BandaEq.passaAltas => eqPassaAltas,
        BandaEq.passaBaixas => eqPassaBaixas,
        BandaEq.shelfGraves => eqShelfGraves,
        BandaEq.banda1 => eqBanda(1),
        BandaEq.banda2 => eqBanda(2),
        BandaEq.banda3 => eqBanda(3),
        BandaEq.banda4 => eqBanda(4),
        BandaEq.shelfAgudos => eqShelfAgudos,
      };

  /// Nome do bloco na tela; versões mono e estéreo com o mesmo nome ganham o
  /// canal junto ("Parametric EQ · Estéreo"). O nome gravado no preset não muda.
  String nomeDoBloco(DefinicaoBloco bloco) => switch (bloco.canal) {
        CanalBloco.unico => bloco.nome,
        CanalBloco.mono => '${bloco.nome} · $cdBlocoMono',
        CanalBloco.estereo => '${bloco.nome} · $cdBlocoEstereo',
      };

  /// Na casa da cadeia o canal vai abreviado ("· ST"), para caber o nome.
  String nomeCurtoDoBloco(DefinicaoBloco bloco, {bool abreviado = false}) {
    final base = abreviado && bloco.abreviacao.isNotEmpty ? bloco.abreviacao : bloco.nome;
    return switch (bloco.canal) {
      CanalBloco.unico => base,
      CanalBloco.mono => '$base · $cdBlocoMonoCurto',
      CanalBloco.estereo => '$base · $cdBlocoEstereoCurto',
    };
  }

  String aviso(Aviso aviso) => switch (aviso) {
        AvisoConexao(:final erro) => erroDeConexao(erro),
        AvisoErro(:final erro) => erroDeOperacao(erro),
        AvisoDemonstracaoFalhou() => avisoDemonstracaoFalhou,
        AvisoFalhaInesperada(:final meio) => avisoFalhaInesperada(meioVisivel(meio)),
        AvisoPedaleiraDesconectada() => avisoPedaleiraDesconectada,
        AvisoPlataformaIndisponivel(:final motivo) => indisponivel(motivo),
        AvisoFormatoMaisNovo() => avisoFormatoMaisNovo,
        AvisoPresetTrocado(:final slot) => avisoPresetTrocado(slot),
        AvisoPresetAtualizado(:final slot) => avisoPresetAtualizado(slot),
        AvisoAreaNaoTrocou() => avisoAreaNaoTrocou,
      };

  /// Ao conectar, a frase diz o que fazer (fechar o Suite, conferir o cabo).
  String erroDeConexao(ErroAnagram erro) => switch (erro) {
        // antes do caso geral: é subtipo de ocupada, mas fechar o Suite não resolve
        ErroPermissaoNegada() => conexaoPermissaoNegada,
        ErroInterfaceOcupada() => conexaoOcupada,
        ErroDesconectado() => conexaoSemAnagram,
        ErroSemResposta() => conexaoSemResposta,
        ErroPlataformaSemSuporte() => erroSemSuporte,
        ErroOperacaoEmCurso(:final mensagem) => erroOperacaoEmCurso(mensagem),
        ErroRespostaInvalida() => conexaoRespostaInvalida,
      };

  /// Erro de uma operação já conectada (ler, tocar, listar).
  String erroDeOperacao(ErroAnagram erro) => switch (erro) {
        ErroInterfaceOcupada() => erroOcupada,
        ErroDesconectado() => erroDesconectado,
        ErroSemResposta() => erroSemResposta,
        ErroRespostaInvalida() => erroRespostaInvalida,
        ErroOperacaoEmCurso(:final mensagem) => erroOperacaoEmCurso(mensagem),
        ErroPlataformaSemSuporte() => erroSemSuporte,
      };

  /// "Não salvou: …", sem nome de ação do protocolo nem tipo de exceção.
  String falhaAoSalvar(FalhaAoSalvar falha) => naoSalvou(switch (falha.erro) {
        ErroDesconectado() => salvarDesconectada,
        ErroSemResposta() => salvarSemResposta,
        ErroRespostaInvalida() => salvarRespostaInvalida,
        ErroInterfaceOcupada() => salvarOcupada,
        ErroOperacaoEmCurso(:final mensagem) => erroOperacaoEmCurso(mensagem),
        ErroPlataformaSemSuporte() => erroSemSuporte,
      });

  String indisponivel(MotivoIndisponivel motivo) => switch (motivo) {
        MotivoIndisponivel.ios => indisponivelIos,
        MotivoIndisponivel.navegadorSemWebHid => indisponivelNavegador,
        MotivoIndisponivel.semUsb => indisponivelSemUsb,
      };

  String importacaoRecusada(ImportacaoRecusada recusa) => switch (recusa.motivo) {
        MotivoImportacao.arquivoIlegivel => importacaoIlegivel,
        MotivoImportacao.naoEhPreset => importacaoNaoEhPreset(recusa.detalhe),
      };

  String nomeInvalido(NomeInvalido motivo) => switch (motivo) {
        NomeVazio() => nomeVazio,
        NomeComMarcador(:final marcador) => nomeComMarcador(marcador),
      };

  String familia(FamiliaBloco familia) => switch (familia) {
        FamiliaBloco.drive => familiaDrive,
        FamiliaBloco.compressor => familiaDinamica,
        FamiliaBloco.equalizador => familiaEq,
        FamiliaBloco.filtro => familiaFiltro,
        FamiliaBloco.modulacao => familiaModulacao,
        FamiliaBloco.delay => familiaDelay,
        FamiliaBloco.reverb => familiaReverb,
        FamiliaBloco.amplificador => familiaAmp,
        FamiliaBloco.gabinete => familiaGabinete,
        FamiliaBloco.utilitario => familiaUtilitario,
      };

  /// Valor de parâmetro com o separador decimal e o liga/desliga do idioma.
  String valorDe(DefinicaoParametro parametro, num valor) => FormatadorValor.formatar(parametro, valor,
      separadorDecimal: separadorDecimal, ligado: valorLigado, desligado: valorDesligado);

  /// O nome dado na pedaleira; sem nome, "Área N".
  String nomeDaArea(AreaPresets area) => area.nome.isEmpty ? areaSemNome(area.numero) : area.nome;

  /// Com mouse a pessoa clica e usa o botão direito; no toque, toca e segura.
  String dicaMontarCadeiaPara({required bool mouse}) => mouse ? txDicaMontarCadeiaMouse : dicaMontarCadeia;

  String slotVazioTextoPara({required bool mouse}) => mouse ? txSlotVazioMouse : slotVazioTexto;

  /// O meio sem o nome da biblioteca entre parênteses ("USB (hidapi)" vira
  /// "USB"): o nome técnico serve ao log, não a quem vai tocar.
  static String meioVisivel(String meio) => meio.replaceAll(RegExp(r'\s*\(.*?\)'), '').trim();
}
