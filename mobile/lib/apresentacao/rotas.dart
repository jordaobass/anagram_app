// Rotas tipadas (go_router_builder). Gerar com:
//   dart run build_runner build --delete-conflicting-outputs
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'telas/tela_creditos.dart';
import 'telas/tela_editor.dart';
import 'telas/tela_presets.dart';

part 'rotas.g.dart';

@TypedGoRoute<RotaEditor>(
  path: '/',
  routes: [
    TypedGoRoute<RotaPresets>(path: 'presets'),
    TypedGoRoute<RotaCreditos>(path: 'creditos'),
  ],
)
class RotaEditor extends GoRouteData with $RotaEditor {
  const RotaEditor();

  @override
  Widget build(BuildContext context, GoRouterState state) => const TelaEditor();
}

class RotaPresets extends GoRouteData with $RotaPresets {
  const RotaPresets();

  @override
  Widget build(BuildContext context, GoRouterState state) => const TelaPresets();
}

class RotaCreditos extends GoRouteData with $RotaCreditos {
  const RotaCreditos();

  @override
  Widget build(BuildContext context, GoRouterState state) => const TelaCreditos();
}

GoRouter criarRoteador() => GoRouter(routes: $appRoutes);
