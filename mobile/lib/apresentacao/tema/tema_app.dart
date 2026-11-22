// O tema do case em dois jogos de cores: o escuro (palco e bancada mal
// iluminados pedem fundo escuro, texto claro de alto contraste e alvos
// grandes) e o claro (o case de alumínio à luz do dia). Os dois usam o mesmo
// desenho: tudo aqui pede a cor pelo papel na [Paleta].
import 'package:flutter/material.dart';

import 'tokens.dart';

abstract final class TemaApp {
  static ThemeData escuro() => _tema(Paleta.escura);

  static ThemeData claro() => _tema(Paleta.clara);

  static ThemeData _tema(Paleta p) {
    final texto = _texto(p);
    return ThemeData(
      brightness: p.brilho,
      colorScheme: _esquema(p),
      extensions: [p],
      scaffoldBackgroundColor: p.fundoCase,
      fontFamily: Fontes.ui,
      textTheme: texto,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      filledButtonTheme: FilledButtonThemeData(style: _botao(texto, p.tally, p.sobreTally)),
      outlinedButtonTheme: OutlinedButtonThemeData(style: _botaoContornado(p, texto)),
      // o texto do botão de texto é ação: âmbar de tinta (o de preenchimento some no claro)
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: p.tallyTinta)
              .copyWith(side: anelDeFoco(p.tallyTinta), shape: _formaControle)),
      iconButtonTheme: IconButtonThemeData(style: ButtonStyle(side: anelDeFoco(p.tallyTinta))),
      appBarTheme: _barraDeTitulo(p),
      dialogTheme: _dialogo(p, texto),
      snackBarTheme: _aviso(p, texto),
      chipTheme: _chip(p, texto),
      segmentedButtonTheme: _segmentos(p),
      popupMenuTheme: _menu(p),
      dividerTheme: DividerThemeData(color: p.filete, thickness: Medidas.filete, space: Medidas.filete),
      focusColor: p.tallyTinta.withValues(alpha: Opacidades.foco),
    );
  }

  /// O esquema do Material sobre os papéis do case; os papéis que o case não
  /// usa ficam com o padrão do Material para o brilho do tema.
  static ColorScheme _esquema(Paleta p) {
    final esquema = p.ehEscura ? ColorScheme.dark : ColorScheme.light;
    return esquema(
      surface: p.painel,
      surfaceContainer: p.painelElevado,
      onSurface: p.texto,
      onSurfaceVariant: p.textoSecundario,
      primary: p.tally,
      onPrimary: p.sobreTally,
      // a fita creme só existe onde há nome escrito: seleção de chip e de
      // segmento usa o painel elevado, com o contorno em tally (ver _chip)
      secondary: p.aluminioClaro,
      onSecondary: p.fundoCase,
      secondaryContainer: p.painelElevado,
      onSecondaryContainer: p.texto,
      error: p.erro,
      outline: p.filete,
      outlineVariant: p.filete,
      // o Material 3 tinge superfícies elevadas com a primária: no case, o
      // âmbar é só seleção e ação, nunca a cor de uma barra rolada
      surfaceTint: Colors.transparent,
    );
  }

  /// Barra de título no painel, rolada ou não, com o filete embaixo.
  static AppBarTheme _barraDeTitulo(Paleta p) => AppBarTheme(
        backgroundColor: p.painel,
        foregroundColor: p.texto,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: p.filete)),
      );

  static ButtonStyle _botaoContornado(Paleta p, TextTheme texto) => OutlinedButton.styleFrom(
        foregroundColor: p.texto,
        minimumSize: const Size(Medidas.alvoMinimo, Medidas.alvoMinimo),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Raios.controle))),
        textStyle: texto.labelLarge,
      ).copyWith(side: anelDeFoco(p.tallyTinta, semFoco: BorderSide(color: p.aluminio)));

  static const _formaControle =
      WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Raios.controle))));

  /// Foco do teclado: contorno sólido de 2px em âmbar ([Paleta.tallyTinta]),
  /// que passa de 3:1 sobre o case e os painéis (o realce a 24% dava 1,69:1).
  /// Sobre um botão já preenchido, o anel é da cor do texto dele, para não
  /// sumir no fundo.
  static WidgetStateProperty<BorderSide?> anelDeFoco(Color cor, {BorderSide? semFoco}) =>
      WidgetStateProperty.resolveWith((estados) => estados.contains(WidgetState.focused)
          ? BorderSide(color: cor, width: Medidas.contornoSelecao)
          : semFoco);

  static WidgetStateBorderSide _contornoSelecao(Paleta p) =>
      WidgetStateBorderSide.resolveWith((estados) => estados.contains(WidgetState.selected)
          ? BorderSide(color: p.tallyTinta, width: Medidas.contornoSelecao)
          : BorderSide(color: p.filete));

  static ChipThemeData _chip(Paleta p, TextTheme texto) => ChipThemeData(
        backgroundColor: p.painel,
        selectedColor: p.painelElevado,
        checkmarkColor: p.tallyTinta,
        side: _contornoSelecao(p),
        labelStyle: texto.labelMedium?.copyWith(color: p.texto),
      );

  /// Todo menu (botão direito, ⋮, seletores) no tipo de item de menu: o
  /// Material 3 usaria o labelLarge, que aqui é o rótulo de botão (condensada,
  /// negrito, 17px) e deixava o menu pesado (DECISOES UI12).
  static PopupMenuThemeData _menu(Paleta p) => PopupMenuThemeData(
        textStyle: Tipos.itemMenu.copyWith(color: p.texto),
        labelTextStyle: WidgetStateProperty.resolveWith((estados) => Tipos.itemMenu.copyWith(
            color: estados.contains(WidgetState.disabled)
                ? p.texto.withValues(alpha: Opacidades.itemIndisponivel)
                : p.texto)),
      );

  static SegmentedButtonThemeData _segmentos(Paleta p) => SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
              (estados) => estados.contains(WidgetState.selected) ? p.painelElevado : p.painel),
          foregroundColor: WidgetStateProperty.resolveWith(
              (estados) => estados.contains(WidgetState.selected) ? p.tallyTinta : p.texto),
          side: _contornoSelecao(p),
        ),
      );

  static DialogThemeData _dialogo(Paleta p, TextTheme texto) => DialogThemeData(
        backgroundColor: p.painelElevado,
        titleTextStyle: texto.titleLarge?.copyWith(fontFamily: Fontes.ui),
        contentTextStyle: texto.bodyLarge?.copyWith(fontFamily: Fontes.ui),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Raios.painel))),
      );

  /// Aviso (SnackBar) como fita gaffer, igual ao nome do preset.
  static SnackBarThemeData _aviso(Paleta p, TextTheme texto) => SnackBarThemeData(
        backgroundColor: p.fitaGaffer,
        contentTextStyle: texto.bodyMedium?.copyWith(color: p.tintaMarcador, fontFamily: Fontes.ui),
        behavior: SnackBarBehavior.floating,
      );

  static ButtonStyle _botao(TextTheme texto, Color fundo, Color frente) => FilledButton.styleFrom(
        backgroundColor: fundo,
        foregroundColor: frente,
        minimumSize: const Size(Medidas.alvoMinimo, Medidas.alvoMinimo),
        padding: const EdgeInsets.symmetric(horizontal: Espacos.l),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Raios.controle))),
        textStyle: texto.labelLarge,
      ).copyWith(side: anelDeFoco(frente));

  static const _figurasTabulares = [FontFeature.tabularFigures()];

  static TextTheme _texto(Paleta p) => TextTheme(
        displaySmall: TextStyle(fontFamily: Fontes.estencil, fontSize: 40, height: 1, color: p.texto),
        headlineSmall: TextStyle(fontFamily: Fontes.marcador, fontSize: 26, height: 1.1, color: p.tintaMarcador),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: p.texto),
        titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: p.texto),
        titleSmall: TextStyle(
            fontFamily: Fontes.rotulo, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: p.texto),
        bodyLarge: TextStyle(fontSize: 16, height: 1.4, color: p.texto),
        bodyMedium: TextStyle(fontSize: 15, height: 1.4, color: p.textoSecundario),
        bodySmall: TextStyle(fontSize: 13, height: 1.35, color: p.textoSecundario),
        labelLarge:
            const TextStyle(fontFamily: Fontes.rotulo, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.8),
        labelMedium: TextStyle(
            fontFamily: Fontes.rotulo, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.7, color: p.textoSecundario),
        labelSmall: TextStyle(
            fontFamily: Fontes.rotulo, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: p.textoSecundario),
        headlineMedium: TextStyle(
            fontSize: 26, fontWeight: FontWeight.w600, color: p.texto, fontFeatures: _figurasTabulares),
      );
}
