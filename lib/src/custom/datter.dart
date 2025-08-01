import 'package:damath/damath.dart';
import 'package:datter/datter.dart';
import 'package:flutter/material.dart';

///
///
///

///
///
/// [FContexting], (update with [Contexting.decoration])
/// [VerticalDragIndexing]
///
///
///

// theme, color, emphasis level
typedef MaterialTextStyle =
    (MaterialTextTheme?, MaterialColorRole?, MaterialEmphasisLevel?);

typedef MaterialColorEmphasis = (MaterialColorRole?, MaterialEmphasisLevel?);

typedef MaterialBorderStyle =
    (MaterialColorEmphasis?, double?, BorderStyle?, double?);

// cell decoration: shape, background color, border color
typedef MaterialDecoration =
    (
      BoxShape?,
      BorderRadius?,
      List<BoxShadow>?,
      Gradient?,
      BlendMode?,
      MaterialColorEmphasis?,
      MaterialBorderStyle?,
    );

///
///
///
extension FContexting on ContextGeneral {
  static ContextGeneral<Decoration> decorationBox({
    required BoxShape shape,
    required BorderRadius? borderRadius,
    required List<BoxShadow>? boxShadow,
    required Gradient? gradient,
    required BlendMode? blendMode,
    required MaterialColorRole background,
    required MaterialEmphasisLevel backgroundEmphasis,
    required MaterialBorderStyle? border,
  }) {
    final backgroundColor = background.buildColor;
    final backgroundColorAlpha = backgroundEmphasis.value;
    if (border == null) {
      return (context) => BoxDecoration(
        color: backgroundColor(context).withAlpha(backgroundColorAlpha),
        shape: shape,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        gradient: gradient,
        backgroundBlendMode: blendMode,
      );
    }

    //
    final emphasis = border.$1!;
    final colorBorder = emphasis.$1!.buildColor;
    final colorBorderAlpha = emphasis.$2!.value;
    final width = border.$2!;
    final style = border.$3!;
    final strokeAlign = border.$4!;
    return (context) => BoxDecoration(
      color: backgroundColor(context),
      shape: shape,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      gradient: gradient,
      backgroundBlendMode: blendMode,
      border: Border.fromBorderSide(
        BorderSide(
          color: colorBorder(context).withAlpha(colorBorderAlpha),
          width: width,
          style: style,
          strokeAlign: strokeAlign,
        ),
      ),
    );
  }
}

///
///
///
class VerticalDragIndexing<T> extends StatefulWidget {
  const VerticalDragIndexing({
    this.threshold = 25.0,
    required this.notifier,
    required this.availables,
    required this.onNextFormatIndex,
    required this.child,
  });

  final double threshold;
  final ValueNotifier<T> notifier;
  final List<T> availables;
  final ValueChanged<int> onNextFormatIndex;
  final Widget? child;

  @override
  State<VerticalDragIndexing<T>> createState() =>
      _VerticalDragIndexingState<T>();
}

class _VerticalDragIndexingState<T> extends State<VerticalDragIndexing<T>>
    with GestureDetectorDragMixin<VerticalDragIndexing<T>> {
  Widget _builderVerticalDragAble(
    BuildContext context,
    T value,
    Widget? child,
  ) {
    final availables = widget.availables;
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onVerticalDragStart: onDragStart,
      onVerticalDragUpdate: onDragUpdateFrom(),
      onVerticalDragEnd: onDragEndFrom(
        difference: OffsetExtension.differenceVertical,
        threshold: widget.threshold,
        direction: DirectionIn4.verticalForward,
        onDrag: FValueChanged.indexingByVerticalDrag(
          onIndex: widget.onNextFormatIndex,
          currentIndex: availables.indexOf(value),
          maxIndex: availables.length,
        ),
      ),
      child: widget.child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: widget.notifier,
      builder: _builderVerticalDragAble,
      child: widget.child,
    );
  }
}
