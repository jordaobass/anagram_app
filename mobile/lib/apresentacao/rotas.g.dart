// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rotas.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$rotaEditor];

RouteBase get $rotaEditor => GoRouteData.$route(
  path: '/',
  hasOverriddenOnExit: false,
  factory: $RotaEditor._fromState,
  routes: [
    GoRouteData.$route(
      path: 'presets',
      hasOverriddenOnExit: false,
      factory: $RotaPresets._fromState,
    ),
    GoRouteData.$route(
      path: 'creditos',
      hasOverriddenOnExit: false,
      factory: $RotaCreditos._fromState,
    ),
    GoRouteData.$route(
      path: 'configuracoes',
      hasOverriddenOnExit: false,
      factory: $RotaConfiguracoes._fromState,
    ),
  ],
);

mixin $RotaEditor on GoRouteData {
  static RotaEditor _fromState(GoRouterState state) => const RotaEditor();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RotaPresets on GoRouteData {
  static RotaPresets _fromState(GoRouterState state) => const RotaPresets();

  @override
  String get location => GoRouteData.$location('/presets');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RotaCreditos on GoRouteData {
  static RotaCreditos _fromState(GoRouterState state) => const RotaCreditos();

  @override
  String get location => GoRouteData.$location('/creditos');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RotaConfiguracoes on GoRouteData {
  static RotaConfiguracoes _fromState(GoRouterState state) =>
      const RotaConfiguracoes();

  @override
  String get location => GoRouteData.$location('/configuracoes');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
