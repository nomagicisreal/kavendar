part of '../table_calendar.dart';

///
///
/// [StyleTextButton]
///
///

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
  static WidgetBuilder? _builderFromList({
    required CalendarStyle style,
    required StyleTextButton styleTextButton,
    required ValueNotifier<int> indexNotifier,
    required ValueChanged<int> notifyChanging,
  }) {
    final availables = style.availableWeeksPerPage;
    return (context) => Padding(
      padding: KGeometry.edgeInsets_left_1 * 8,
      child: ValueListenableBuilder(
        valueListenable: indexNotifier,
        builder: (context, value, child) {
          return InkWell(
            borderRadius: styleTextButton.decoration.borderRadius?.resolve(
              context.textDirection,
            ),
            onTap: () {
              final index = (value + 1) % availables.length;
              notifyChanging(index);
              // indexNotifier.value = index;
              // final weeksPerPage = availables[index];
              // pageHeightNotifier.value =
            },
            child: Container(
              decoration: styleTextButton.decoration,
              padding: styleTextButton.padding,
              child: Text(
                styleTextButton._texting?.call(indexNotifier.value) ??
                    _textWeek(availables)(indexNotifier.value),
                style: styleTextButton.textStyle,
              ),
            ),
          );
        },
      ),
    );
  }

  WidgetBuilder? buildFrom(
    CalendarStyle style,
    ValueNotifier<int> indexNotifier,
    ValueChanged<int> notifyChanging,
  ) {
    if (style.availableWeeksPerPage.length == 1) return null;
    return _builderFromList(
      style: style,
      styleTextButton: this,
      indexNotifier: indexNotifier,
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
  static PageStepperBuilder _builderChevron(
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

  Widget buildFrom(
    DirectionIn4 direction, {
    required PageStepper iconOnTap,
    required Duration duration,
    required Curve curve,
  }) => (switch (direction) {
    DirectionIn4.left =>
      _bChevronLeft ?? _builderChevron(this, chevronLeft, duration, curve),
    DirectionIn4.right =>
      _bChevronRight ?? _builderChevron(this, chevronRight, duration, curve),
    _ => throw StateError('invalid direction $direction'),
  })(iconOnTap);
}
