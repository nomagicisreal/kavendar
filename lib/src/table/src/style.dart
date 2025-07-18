part of '../table_calendar.dart';

///
///
/// [StyleHeader]
/// [StyleTextButton]
///
///

///
///
///
class StyleHeader {
  final void Function(DateTime focusedDay)? headerOnTap;
  final void Function(DateTime focusedDay)? headerOnLongPress;
  final EdgeInsets headerPadding;
  final EdgeInsets headerMargin;
  final BoxDecoration headerDecoration;

  ///
  ///
  ///
  final bool titleCentered;
  final dm.TextFormatter? titleTextFormatter;
  final TextStyle titleTextStyle;
  final DateBuilder? _bTitle;

  ///
  ///
  ///
  final StyleTextButton? styleFormatButton;
  final StyleChevrons? styleChevrons;

  const StyleHeader({
    this.headerOnTap,
    this.headerOnLongPress,
    this.headerDecoration = const BoxDecoration(),
    this.headerMargin = EdgeInsets.zero,
    this.headerPadding = const EdgeInsets.symmetric(vertical: 8.0),
    this.titleCentered = false,
    this.titleTextFormatter,
    this.titleTextStyle = const TextStyle(fontSize: 17.0),
    this.styleFormatButton = const StyleTextButton(),
    this.styleChevrons = const StyleChevrons(),

    DateBuilder? builderTitle,
    WidgetBuilder Function(CalendarStyle style, StyleHeader styleHeader)?
    builderFormatButton,
  }) : _bTitle = builderTitle;

  static DateBuilder _builderTitle(StyleHeader style) =>
      (focusedDate, locale) => Expanded(
        child: GestureDetector(
          onTap: () => style.headerOnTap?.call(focusedDate),
          onLongPress: () => style.headerOnLongPress?.call(focusedDate),
          child: Text(
            style.titleTextFormatter?.call(focusedDate, locale) ??
                DateFormat.yMMMM(locale).format(focusedDate),
            style: style.titleTextStyle,
            textAlign: style.titleCentered ? TextAlign.center : TextAlign.start,
          ),
        ),
      );

  DateBuilder get buildTitle => _bTitle ?? _builderTitle(this);
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
  static WidgetBuilder _builderFromList<T>({
    void Function(T currentFormat)? onChanged,
    required StyleTextButton style,
    required ValueNotifier<int> indexNotifier,
    required List<T> availables,
  }) =>
      (context) => Padding(
        padding: KGeometry.edgeInsets_left_1 * 8,
        child: ValueListenableBuilder(
          valueListenable: indexNotifier,
          builder: (context, value, child) {
            return InkWell(
              borderRadius: style.decoration.borderRadius?.resolve(
                context.textDirection,
              ),
              onTap: () {
                final next = (value + 1) % availables.length;
                indexNotifier.value = next;
                onChanged?.call(availables[next]);
              },
              child: Container(
                decoration: style.decoration,
                padding: style.padding,
                child: Text(
                  style._texting?.call(indexNotifier.value) ??
                      _textWeek(availables)(indexNotifier.value),
                  style: style.textStyle,
                ),
              ),
            );
          },
        ),
      );

  WidgetBuilder? buildFrom(
    CalendarStyle style,
    ValueNotifier<int> indexNotifier,
  ) {
    if (style.availableWeeksPerPage.length == 1) return null;
    final availables = style.availableWeeksPerPage;
    final onFormatChanged = style.onFormatChanged;
    return _builderFromList<int>(
      style: this,
      indexNotifier: indexNotifier,
      availables: availables,
      onChanged: onFormatChanged,
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
