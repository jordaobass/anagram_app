// Conectar ao abrir (DECISOES CA1–CA4): no computador, depois do primeiro
// quadro, uma única tentativa pelo USB com o mesmo aperto de mão da conexão
// manual. Não achar a pedaleira não é erro: a tela de conectar fica como
// estava e o motivo vai para o registro. No macOS, só com o Monitoramento de
// Entrada já concedido. Celular e web não tentam.
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dados/preferencias_conexao.dart';
import '../nucleo/registro.dart';
import '../plataforma/acesso_entrada_mac.dart';
import 'estado/controlador_conexao.dart';
import 'estado/estado_conexao.dart';

/// Onde o app procura a pedaleira sozinho ao abrir.
enum PlataformaDeAbertura { computador, macOS, semTentativa }

PlataformaDeAbertura get plataformaDeAberturaAtual {
  if (kIsWeb) return PlataformaDeAbertura.semTentativa;
  return switch (defaultTargetPlatform) {
    TargetPlatform.windows || TargetPlatform.linux => PlataformaDeAbertura.computador,
    TargetPlatform.macOS => PlataformaDeAbertura.macOS,
    _ => PlataformaDeAbertura.semTentativa,
  };
}

/// Os testes fixam a plataforma (o padrão deles é não tentar).
final plataformaDeAberturaProvider = Provider<PlataformaDeAbertura>((ref) => plataformaDeAberturaAtual);

final preferenciasConexaoProvider = Provider<PreferenciasConexao>((ref) => PreferenciasConexaoLocais());

final acessoEntradaMacProvider = Provider<ConsultaAcessoEntrada>((ref) => consultarAcessoEntradaMac);

/// Estado: o interruptor das Configurações (ligado por padrão).
final conectarAoAbrirProvider = NotifierProvider<ControladorConectarAoAbrir, bool>(ControladorConectarAoAbrir.new);

class ControladorConectarAoAbrir extends Notifier<bool> {
  @override
  bool build() => true;

  /// Chamada uma vez, depois do primeiro quadro; nunca repete sozinha.
  Future<void> aoAbrir() async {
    final plataforma = ref.read(plataformaDeAberturaProvider);
    if (plataforma == PlataformaDeAbertura.semTentativa) return;
    final ligado = await ref.read(preferenciasConexaoProvider).lerConectarAoAbrir();
    if (!ref.mounted) return;
    state = ligado;
    if (!ligado) return registro.i('conexão ao abrir: desligada nas Configurações');
    if (plataforma == PlataformaDeAbertura.macOS && !await _monitoramentoLiberado()) return;
    // a pessoa já tocou em conectar (ou na demonstração) enquanto isto lia
    if (!ref.mounted || ref.read(conexaoProvider) is! SemConexao) return;
    await ref.read(conexaoProvider.notifier).conectarAoAbrir();
  }

  /// Vale para a próxima abertura; mudar aqui não conecta nem desconecta.
  Future<void> definir(bool ligado) async {
    state = ligado;
    await ref.read(preferenciasConexaoProvider).gravarConectarAoAbrir(ligado);
  }

  Future<bool> _monitoramentoLiberado() async {
    final acesso = await ref.read(acessoEntradaMacProvider)();
    if (acesso == AcessoEntrada.concedido) return true;
    registro.i('conexão ao abrir: sem tentativa, Monitoramento de Entrada ${acesso.name}; espera o clique');
    return false;
  }
}
