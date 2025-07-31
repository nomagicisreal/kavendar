// ignore_for_file: constant_identifier_names
import 'package:datter/datter.dart';
import 'package:flutter/material.dart';

typedef TextStyleBuilder = TextStyle Function(BuildContext context);
typedef DecorationBuilder = Decoration Function(BuildContext context);
typedef DoubleBuilder = double Function(BuildContext context);
// typedef BoxBorderBuilder = BoxBorder Function(BuildContext context);

///
/// [builderTextStyle], ...
///
extension MaterialStyle on Material {
  static TextStyleBuilder builderTextStyle({
    required MaterialTextTheme theme,
    required MaterialColorRole styleColor,
    required MaterialEmphasisLevel styleAlpha,
  }) {
    final fontSize = theme.buildFontSize;
    final color = styleColor.buildColor;
    final alpha = styleAlpha.value;
    return (context) => TextStyle(
      fontSize: fontSize(context),
      color: color(context).withAlpha(alpha),
    );
  }

  ///
  /// todo: remove [shape], enable animation between box shapes (circle, rectangle)
  /// todo: generalize decoration builder
  ///
  static DecorationBuilder builderDecoration({
    required BoxShape shape,
    required MaterialColorRole backgroundColor,
    required MaterialColorRole? borderColor,
  }) {
    final color = backgroundColor.buildColor;
    final colorBorder = borderColor?.buildColor;
    return colorBorder == null
        ? (context) => BoxDecoration(color: color(context), shape: shape)
        : (context) => BoxDecoration(
          color: color(context),
          shape: shape,
          border: Border.fromBorderSide(
            BorderSide(color: colorBorder(context)),
          ),
        );
  }
}

///
///
enum MaterialEmphasisLevel {
  primary(0xFF),
  interactive(0x99),
  inactive(0x61);

  final int value;

  const MaterialEmphasisLevel(this.value);
}

///
/// see https://m3.material.io/styles/color/static/baseline
///
enum MaterialColorRole {
  primary,
  primaryContainer,
  secondary,
  secondaryContainer,
  tertiary,
  tertiaryContainer,
  error,
  errorContainer,
  onPrimary,
  onPrimaryContainer,
  onSecondary,
  onSecondaryContainer,
  onTertiary,
  onTertiaryContainer,
  onError,
  onErrorContainer,

  //
  primaryFixed,
  primaryFixedDim,
  secondaryFixed,
  secondaryFixedDim,
  tertiaryFixed,
  tertiaryFixedDim,
  onPrimaryFixed,
  onPrimaryFixedVariant,
  onSecondaryFixed,
  onSecondaryFixedVariant,
  onTertiaryFixed,
  onTertiaryFixedVariant,

  //
  surfaceDim,
  surface,
  surfaceBright,
  surfaceContainerLowest,
  surfaceContainerLow,
  surfaceContainer,
  surfaceContainerHigh,
  surfaceContainerHighest,
  onSurface,
  onSurfaceVariant,
  outline,
  outlineVariant,

  //
  transparent,
  inverseSurface,
  inverseOnSurface,
  inversePrimary,
  scrim,
  shadow,
  surfaceTint;

  Color Function(BuildContext context) get buildColor => switch (this) {
    MaterialColorRole.primary => (context) => context.colorScheme.primary,
    MaterialColorRole.onPrimary => (context) => context.colorScheme.onPrimary,
    MaterialColorRole.primaryContainer =>
      (context) => context.colorScheme.primaryContainer,
    MaterialColorRole.onPrimaryContainer =>
      (context) => context.colorScheme.onPrimaryContainer,
    MaterialColorRole.secondary => (context) => context.colorScheme.secondary,
    MaterialColorRole.onSecondary =>
      (context) => context.colorScheme.onSecondary,
    MaterialColorRole.secondaryContainer =>
      (context) => context.colorScheme.secondaryContainer,
    MaterialColorRole.onSecondaryContainer =>
      (context) => context.colorScheme.onSecondaryContainer,
    MaterialColorRole.tertiary => (context) => context.colorScheme.tertiary,
    MaterialColorRole.onTertiary => (context) => context.colorScheme.onTertiary,
    MaterialColorRole.tertiaryContainer =>
      (context) => context.colorScheme.tertiaryContainer,
    MaterialColorRole.onTertiaryContainer =>
      (context) => context.colorScheme.onTertiaryContainer,
    MaterialColorRole.error => (context) => context.colorScheme.error,
    MaterialColorRole.onError => (context) => context.colorScheme.onError,
    MaterialColorRole.errorContainer =>
      (context) => context.colorScheme.errorContainer,
    MaterialColorRole.onErrorContainer =>
      (context) => context.colorScheme.onErrorContainer,
    MaterialColorRole.surface => (context) => context.colorScheme.surface,
    MaterialColorRole.onSurface => (context) => context.colorScheme.onSurface,
    MaterialColorRole.onSurfaceVariant =>
      (context) => context.colorScheme.onSurfaceVariant,
    MaterialColorRole.outline => (context) => context.colorScheme.outline,
    MaterialColorRole.outlineVariant =>
      (context) => context.colorScheme.outlineVariant,
    MaterialColorRole.shadow => (context) => context.colorScheme.shadow,
    MaterialColorRole.scrim => (context) => context.colorScheme.scrim,
    MaterialColorRole.inverseSurface =>
      (context) => context.colorScheme.inverseSurface,
    MaterialColorRole.inverseOnSurface =>
      (context) => context.colorScheme.onInverseSurface,
    MaterialColorRole.inversePrimary =>
      (context) => context.colorScheme.inversePrimary,
    MaterialColorRole.surfaceTint =>
      (context) => context.colorScheme.surfaceTint,
    MaterialColorRole.primaryFixed =>
      (context) => context.colorScheme.primaryFixed,
    MaterialColorRole.onPrimaryFixed =>
      (context) => context.colorScheme.onPrimaryFixed,
    MaterialColorRole.primaryFixedDim =>
      (context) => context.colorScheme.primaryFixedDim,
    MaterialColorRole.secondaryFixed =>
      (context) => context.colorScheme.secondaryFixed,
    MaterialColorRole.onSecondaryFixed =>
      (context) => context.colorScheme.onSecondaryFixed,
    MaterialColorRole.secondaryFixedDim =>
      (context) => context.colorScheme.secondaryFixedDim,
    MaterialColorRole.tertiaryFixed =>
      (context) => context.colorScheme.tertiaryFixed,
    MaterialColorRole.onTertiaryFixed =>
      (context) => context.colorScheme.onTertiaryFixed,
    MaterialColorRole.tertiaryFixedDim =>
      (context) => context.colorScheme.tertiaryFixedDim,
    MaterialColorRole.onPrimaryFixedVariant =>
      (context) => context.colorScheme.onPrimaryFixedVariant,
    MaterialColorRole.onSecondaryFixedVariant =>
      (context) => context.colorScheme.onSecondaryFixedVariant,
    MaterialColorRole.onTertiaryFixedVariant =>
      (context) => context.colorScheme.onTertiaryFixedVariant,
    MaterialColorRole.surfaceDim => (context) => context.colorScheme.surfaceDim,
    MaterialColorRole.surfaceBright =>
      (context) => context.colorScheme.surfaceBright,
    MaterialColorRole.surfaceContainerLowest =>
      (context) => context.colorScheme.surfaceContainerLowest,
    MaterialColorRole.surfaceContainerLow =>
      (context) => context.colorScheme.surfaceContainerLow,
    MaterialColorRole.surfaceContainer =>
      (context) => context.colorScheme.surfaceContainer,
    MaterialColorRole.surfaceContainerHigh =>
      (context) => context.colorScheme.surfaceContainerHigh,
    MaterialColorRole.surfaceContainerHighest =>
      (context) => context.colorScheme.surfaceContainerHighest,
    MaterialColorRole.transparent => (_) => Colors.transparent,
  };
}

///
/// see https://api.flutter.dev/flutter/material/TextTheme-class.html
///
/// default text style: [DefaultTextStyle].of(context).style.fontSize
/// in [Scaffold.body], default TextStyle fontSize is 14, [TextTheme.bodyMedium].
///
enum MaterialTextTheme {
  displayLarge, // 57.0
  displayMedium, // 45.0
  displaySmall, // 36.0

  headlineLarge, // 32.0
  headlineMedium, // 28.0
  headlineSmall, // 24.0

  titleLarge, // 22.0
  titleMedium, // 16.0
  titleSmall, // 14.0

  bodyLarge, // 16.0
  bodyMedium, // 14.0
  bodySmall, // 12.0

  labelLarge, // 14.0
  labelMedium, // 12.0
  labelSmall; // 11.0

  double? Function(BuildContext context) get buildFontSize => switch (this) {
    MaterialTextTheme.displayLarge =>
      (context) => context.themeText.displayLarge?.fontSize,
    MaterialTextTheme.displayMedium =>
      (context) => context.themeText.displayMedium?.fontSize,
    MaterialTextTheme.displaySmall =>
      (context) => context.themeText.displaySmall?.fontSize,
    MaterialTextTheme.headlineLarge =>
      (context) => context.themeText.headlineLarge?.fontSize,
    MaterialTextTheme.headlineMedium =>
      (context) => context.themeText.headlineMedium?.fontSize,
    MaterialTextTheme.headlineSmall =>
      (context) => context.themeText.headlineSmall?.fontSize,
    MaterialTextTheme.titleLarge =>
      (context) => context.themeText.titleLarge?.fontSize,
    MaterialTextTheme.titleMedium =>
      (context) => context.themeText.titleMedium?.fontSize,
    MaterialTextTheme.titleSmall =>
      (context) => context.themeText.titleSmall?.fontSize,
    MaterialTextTheme.bodyLarge =>
      (context) => context.themeText.bodyLarge?.fontSize,
    MaterialTextTheme.bodyMedium =>
      (context) => context.themeText.bodyMedium?.fontSize,
    MaterialTextTheme.bodySmall =>
      (context) => context.themeText.bodySmall?.fontSize,
    MaterialTextTheme.labelLarge =>
      (context) => context.themeText.labelLarge?.fontSize,
    MaterialTextTheme.labelMedium =>
      (context) => context.themeText.labelMedium?.fontSize,
    MaterialTextTheme.labelSmall =>
      (context) => context.themeText.labelSmall?.fontSize,
  };
}
