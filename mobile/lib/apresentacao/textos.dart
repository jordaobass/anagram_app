// Frases da tela para o que a aplicação e o núcleo informam por tipo (avisos,
// erros, motivos, famílias de bloco). Ficam aqui, e não lá, para o estado
// não depender de BuildContext e os logs continuarem em português.
//
// Os erros do protocolo trazem em `mensagem` o detalhe técnico, escrito em
// português: o português mostra esse detalhe como sempre mostrou; inglês e
// espanhol trocam por uma frase geral do tipo de erro (o detalhe vai ao log).
import '../aplicacao/avisos.dart';
import '../aplicacao/casos_de_uso/salvar_no_slot.dart';
import '../aplicacao/casos_de_uso/transferir_preset.dart';
import '../l10n/app_localizations.dart';
import '../nucleo/catalogo/definicao_bloco.dart';
import '../nucleo/catalogo/familia_bloco.dart';
import '../nucleo/catalogo/formatador_valor.dart';
import '../nucleo/modelo/areas_presets.dart';
import '../nucleo/modelo/documento_preset.dart';
import '../nucleo/protocolo/erros_anagram.dart';
import '../nucleo/suporte_aparelho.dart';

extension TextosDoApp on AppLocalizations {
  String aviso(Aviso aviso) => switch (aviso) {
        AvisoConexao(:final erro) => erroDeConexao(erro),
        AvisoErro(:final erro) => erroDeOperacao(erro),
        AvisoDemonstracaoFalhou() => avisoDemonstracaoFalhou,
        AvisoFalhaInesperada(:final meio) => avisoFalhaInesperada(meio),
        AvisoPedaleiraDesconectada() => avisoPedaleiraDesconectada,
        AvisoPlataformaIndisponivel(:final motivo) => indisponivel(motivo),
        AvisoFormatoMaisNovo() => avisoFormatoMaisNovo,
        AvisoPresetTrocado(:final slot) => avisoPresetTrocado(slot),
        AvisoAreaNaoTrocou(:final erro) => avisoAreaNaoTrocou(erro.mensagem),
      };

  /// Ao conectar, a frase diz o que fazer (fechar o Suite, conferir o cabo).
  String erroDeConexao(ErroAnagram erro) => switch (erro) {
        // antes do caso geral: é subtipo de ocupada, mas fechar o Suite não resolve
        ErroPermissaoNegada() => conexaoPermissaoNegada,
        ErroInterfaceOcupada() => conexaoOcupada,
        ErroDesconectado() => conexaoSemAnagram,
        ErroSemResposta() => conexaoSemResposta,
        ErroPlataformaSemSuporte(:final mensagem) => erroSemSuporte(mensagem),
        ErroOperacaoEmCurso(:final mensagem) => erroOperacaoEmCurso(mensagem),
        ErroRespostaInvalida(:final mensagem) => conexaoRespostaInvalida(mensagem),
      };

  /// Erro de uma operação já conectada (ler, tocar, listar).
  String erroDeOperacao(ErroAnagram erro) => switch (erro) {
        ErroInterfaceOcupada() => erroOcupada(erro.mensagem),
        ErroDesconectado() => erroDesconectado(erro.mensagem),
        ErroSemResposta() => erroSemResposta(erro.mensagem),
        ErroRespostaInvalida() => erroRespostaInvalida(erro.mensagem),
        ErroOperacaoEmCurso() => erroOperacaoEmCurso(erro.mensagem),
        ErroPlataformaSemSuporte() => erroSemSuporte(erro.mensagem),
      };

  /// "Não salvou: …", sem nome de ação do protocolo nem tipo de exceção.
  String falhaAoSalvar(FalhaAoSalvar falha) => naoSalvou(switch (falha.erro) {
        ErroDesconectado() => salvarDesconectada,
        ErroSemResposta() => salvarSemResposta,
        ErroRespostaInvalida() => salvarRespostaInvalida,
        ErroInterfaceOcupada() => salvarOcupada,
        ErroOperacaoEmCurso(:final mensagem) => erroOperacaoEmCurso(mensagem),
        ErroPlataformaSemSuporte(:final mensagem) => erroSemSuporte(mensagem),
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
}
