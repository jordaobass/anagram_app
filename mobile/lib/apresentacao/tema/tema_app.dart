// Tema escuro único: palco e bancada mal iluminados pedem fundo escuro,
// texto claro de alto contraste e alvos grandes.
import 'package:flutter/material.dart';

import 'tokens.dart';

abstract final class TemaApp {
  static ThemeData escuro() {
    const esquema = ColorScheme.dark(
      surface: Cores.painel,
      surfaceContainer: Cores.painelElevado,
      onSurface: Cores.texto,
      onSurfaceVariant: Cores.textoSecundario,
      primary: Cores.tally,
      onPrimary: Cores.sobreTally,
      secondary: Cores.fitaGaffer,
      onSecondary: Cores.tintaMarcador,
      error: Cores.erro,
      outline: Cores.filete,
      outlineVariant: Cores.filete,
    );
    return ThemeData(
      colorScheme: esquema,
      scaffoldBackgroundColor: Cores.fundoCase,
      fontFamily: Fontes.ui,
      textTheme: _texto(),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      filledButtonTheme: FilledButtonThemeData(style: _botao(Cores.tally, Cores.sobreTally)),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Cores.texto,
          minimumSize: const Size(Medidas.alvoMinimo, Medidas.alvoMinimo),
          side: const BorderSide(color: Cores.aluminio),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Raios.controle))),
          textStyle: _texto().labelLarge,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Cores.painelElevado,
        titleTextStyle: _texto().titleLarge?.copyWith(fontFamily: Fontes.ui),
        contentTextStyle: _texto().bodyLarge?.copyWith(fontFamily: Fontes.ui),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Raios.painel))),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Cores.fitaGaffer,
        contentTextStyle: _texto().bodyMedium?.copyWith(color: Cores.tintaMarcador, fontFamily: Fontes.ui),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(color: Cores.filete, thickness: Medidas.filete, space: Medidas.filete),
      focusColor: Cores.tally.withValues(alpha: 0.24),
    );
  }

  static ButtonStyle _botao(Color fundo, Color frente) => FilledButton.styleFrom(
        backgroundColor: fundo,
        foregroundColor: frente,
        minimumSize: const Size(Medidas.alvoMinimo, Medidas.alvoMinimo),
        padding: const EdgeInsets.symmetric(horizontal: Espacos.l),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Raios.controle))),
        textStyle: _texto().labelLarge,
      );

  static const _figurasTabulares = [FontFeature.tabularFigures()];

  static TextTheme _texto() => const TextTheme(
        displaySmall: TextStyle(fontFamily: Fontes.estencil, fontSize: 40, height: 1, color: Cores.texto),
        headlineSmall: TextStyle(fontFamily: Fontes.marcador, fontSize: 26, height: 1.1, color: Cores.tintaMarcador),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Cores.texto),
        titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Cores.texto),
        titleSmall: TextStyle(
            fontFamily: Fontes.rotulo, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: Cores.texto),
        bodyLarge: TextStyle(fontSize: 16, height: 1.4, color: Cores.texto),
        bodyMedium: TextStyle(fontSize: 15, height: 1.4, color: Cores.textoSecundario),
        bodySmall: TextStyle(fontSize: 13, height: 1.35, color: Cores.textoSecundario),
        labelLarge: TextStyle(fontFamily: Fontes.rotulo, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.8),
        labelMedium: TextStyle(
            fontFamily: Fontes.rotulo, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.7, color: Cores.textoSecundario),
        labelSmall: TextStyle(
            fontFamily: Fontes.rotulo, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: Cores.textoSecundario),
        headlineMedium: TextStyle(
            fontSize: 26, fontWeight: FontWeight.w600, color: Cores.texto, fontFeatures: _figurasTabulares),
      );
}
