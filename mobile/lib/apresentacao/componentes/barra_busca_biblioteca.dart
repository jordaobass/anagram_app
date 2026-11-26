// Busca e ordem da lista do modo Biblioteca (DECISOES BB3): o campo filtra
// enquanto se digita (nome do preset, da banda ou da coleção) e o botão ao
// lado escolhe a ordem. Os dois ficam no [filtroBibliotecaProvider], para a
// busca sobreviver a sair e voltar da lista no celular.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/modo_biblioteca.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/modelo/biblioteca_bandas.dart';
import '../tema/tokens.dart';
import 'item_de_menu.dart';

class BarraBuscaBiblioteca extends ConsumerStatefulWidget {
  const BarraBuscaBiblioteca({super.key});

  @override
  ConsumerState<BarraBuscaBiblioteca> createState() => _BarraBuscaBibliotecaState();
}

class _BarraBuscaBibliotecaState extends ConsumerState<BarraBuscaBiblioteca> {
  late final _campo = TextEditingController(text: ref.read(filtroBibliotecaProvider).busca);

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  void _buscar(String texto) => ref.read(filtroBibliotecaProvider.notifier).buscar(texto);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final filtro = ref.watch(filtroBibliotecaProvider);
    return Container(
      padding: const EdgeInsets.fromLTRB(Espacos.s, Espacos.s, Espacos.xs, Espacos.s),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.cores.filete)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const ValueKey('busca-biblioteca'),
              controller: _campo,
              onChanged: _buscar,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                isDense: true,
                hintText: l.bbBuscar,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: filtro.busca.isEmpty
                    ? null
                    : IconButton(
                        key: const ValueKey('limpar-busca-biblioteca'),
                        tooltip: l.bbLimparBusca,
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _campo.clear();
                          _buscar('');
                        },
                      ),
              ),
            ),
          ),
          PopupMenuButton<OrdemBiblioteca>(
            key: const ValueKey('ordem-biblioteca'),
            tooltip: l.bbOrdem,
            icon: Icon(
              Icons.sort,
              color: filtro.ordem == OrdemBiblioteca.arquivo ? context.cores.textoSecundario : context.cores.tallyTinta,
            ),
            onSelected: ref.read(filtroBibliotecaProvider.notifier).ordenar,
            itemBuilder: (_) => [
              for (final (ordem, rotulo) in [
                (OrdemBiblioteca.arquivo, l.bbOrdemArquivo),
                (OrdemBiblioteca.nomeAZ, l.bbOrdemAZ),
                (OrdemBiblioteca.nomeZA, l.bbOrdemZA),
              ])
                itemMarcado(
                  ordem,
                  key: ValueKey('ordem-${ordem.name}'),
                  rotulo: rotulo,
                  marcado: filtro.ordem == ordem,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
