// O que a aplicação quer dizer à pessoa, sem a frase pronta: a tela escolhe as
// palavras no idioma em uso (lib/apresentacao/textos_avisos.dart). Assim o
// estado continua sem BuildContext e os logs seguem em português.
import '../nucleo/protocolo/erros_anagram.dart';
import '../nucleo/suporte_aparelho.dart';

sealed class Aviso {
  const Aviso();
}

/// A conexão falhou por um erro do protocolo ou do transporte.
final class AvisoConexao extends Aviso {
  const AvisoConexao(this.erro);
  final ErroAnagram erro;
}

/// Erro de uma operação (ler, tocar, listar) mostrado como veio.
final class AvisoErro extends Aviso {
  const AvisoErro(this.erro);
  final ErroAnagram erro;
}

final class AvisoDemonstracaoFalhou extends Aviso {
  const AvisoDemonstracaoFalhou();
}

/// Erro fora do protocolo ao abrir [meio]; a causa real foi para o log.
final class AvisoFalhaInesperada extends Aviso {
  const AvisoFalhaInesperada(this.meio);
  final String meio;
}

final class AvisoPedaleiraDesconectada extends Aviso {
  const AvisoPedaleiraDesconectada();
}

final class AvisoPlataformaIndisponivel extends Aviso {
  const AvisoPlataformaIndisponivel(this.motivo);
  final MotivoIndisponivel motivo;
}

final class AvisoFormatoMaisNovo extends Aviso {
  const AvisoFormatoMaisNovo();
}

/// A pedaleira devolveu para [slot] um preset de id diferente do da lista.
final class AvisoPresetTrocado extends Aviso {
  const AvisoPresetTrocado(this.slot);
  final String slot;
}

final class AvisoAreaNaoTrocou extends Aviso {
  const AvisoAreaNaoTrocou(this.erro);
  final ErroAnagram erro;
}
