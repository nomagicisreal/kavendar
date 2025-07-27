part of '../table_calendar.dart';

///
///
/// [StyleTextButton]
///
///

class DecorationTextStyle {
  final Decoration? decoration;
  final TextStyle? textStyle;

  const DecorationTextStyle(this.decoration, this.textStyle);
}

///
///
///
class StyleTextButton {
  final String Function(int index)? _texting;
  final TextStyle textStyle;
  final BoxDecoration decoration;
  final EdgeInsets padding;

  const StyleTextButton({
    String Function(int index)? texting,
    this.textStyle = const TextStyle(fontSize: 14.0),
    this.decoration = const BoxDecoration(
      border: Border.fromBorderSide(BorderSide()),
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
    ),
    this.padding = const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
  }) : _texting = texting;

  static String Function(int index) _textWeek<T>(List<T> items) => (index) {
    final item = items[index];
    return switch (item) {
      1 => "1 week",
      2 => "2 weeks",
      6 => "6 weeks",
      _ => throw StateError('unimplement item: $item'),
    };
  };

  ///
  ///
  ///
  static NotifierBuilder<int> _builderFromList({
    required CalendarStyle style,
    required StyleTextButton styleTextButton,
    required ValueChanged<int> notifyChanging,
  }) {
    final availables = style.formatAvailables;
    return (weeksPerPage) => Padding(
      padding: KGeometry.edgeInsets_left_1 * 8,
      child: ValueListenableBuilder(
        valueListenable: weeksPerPage,
        builder: (context, wPP, child) {
          return InkWell(
            borderRadius: styleTextButton.decoration.borderRadius?.resolve(
              context.textDirection,
            ),
            onTap: () {
              final index = availables.indexOf(wPP);
              if (index == -1) {
                throw StateError(
                  'invalid weeks per page: $wPP\n'
                  'availables: $availables}',
                );
              }
              notifyChanging((index + 1) % availables.length);
            },
            child: Container(
              decoration: styleTextButton.decoration,
              padding: styleTextButton.padding,
              child: Text(
                styleTextButton._texting?.call(weeksPerPage.value) ??
                    _textWeek(availables)(weeksPerPage.value),
                style: styleTextButton.textStyle,
              ),
            ),
          );
        },
      ),
    );
  }

  NotifierBuilder<int>? builderFrom(
    CalendarStyle style,
    ValueChanged<int> notifyChanging,
  ) {
    if (style.formatAvailables.length == 1) return null;
    return _builderFromList(
      style: style,
      styleTextButton: this,
      notifyChanging: notifyChanging,
    );
  }
}

///
///
///
class StyleChevrons {
  final Widget chevronLeft;
  final Widget chevronRight;
  final EdgeInsets chevronPadding;
  final EdgeInsets chevronMargin;
  final PageStepperBuilder? _bChevronLeft;
  final PageStepperBuilder? _bChevronRight;

  const StyleChevrons({
    this.chevronPadding = const EdgeInsets.all(12.0),
    this.chevronMargin = const EdgeInsets.symmetric(horizontal: 8.0),
    this.chevronLeft = const Icon(Icons.chevron_left),
    this.chevronRight = const Icon(Icons.chevron_right),
    PageStepperBuilder? builderLeft,
    PageStepperBuilder? builderRight,
  }) : _bChevronLeft = builderLeft,
       _bChevronRight = builderRight;

  ///
  ///
  ///
  static PageStepperBuilder _builderFrom(
    StyleChevrons style,
    Widget icon,
    Duration duration,
    Curve curve,
  ) =>
      (stepper) => Padding(
        padding: style.chevronMargin,
        child: InkWell(
          onTap: () => stepper(duration: duration, curve: curve),
          borderRadius: KGeometry.borderRadius_circularAll_1 * 100,
          child: Padding(padding: style.chevronPadding, child: icon),
        ),
      );

  Widget builder(
    DirectionIn4 direction, {
    required PageStepper iconOnTap,
    required Duration duration,
    required Curve curve,
  }) => (switch (direction) {
    DirectionIn4.left =>
      _bChevronLeft ?? _builderFrom(this, chevronLeft, duration, curve),
    DirectionIn4.right =>
      _bChevronRight ?? _builderFrom(this, chevronRight, duration, curve),
    _ => throw StateError('invalid direction $direction'),
  })(iconOnTap);
}
