part of '../table_calendar.dart';

///
///
/// [CalendarFocus]
/// [_CalendarFocusParent]
///   [_CalendarFocusFocusOnly]
///     [_CalendarFocusFocusAndSelection]
///
///
///

typedef CalendarFocusInitializer = CalendarFocus Function(DateTime dateFocused);

///
///
/// [CalendarFocus.focusOnly], ...
/// [pSelectionOnly], ...
///
/// [dateFocused]
/// [predicateFocused], [predicateOutside]
/// [_predicators]
///
sealed class CalendarFocus {
  DateTime dateFocused;
  final Map<CalendarCellType, Predicator<DateTime>?> _predicators = {
    CalendarCellType.normal: null,
  };

  CalendarFocus._(this.dateFocused);

  factory CalendarFocus(Calendar widget) => widget.style.focusInitializer(
    (widget.focusedDate ?? DateTime.now()).dateOnly,
  );

  factory CalendarFocus.focusOnly(DateTime dateFocused) =
      _CalendarFocusFocusOnly;

  factory CalendarFocus.focusAndSelection(DateTime dateFocused) =
      _CalendarFocusFocusAndSelection;

  ///
  ///
  ///
  static const CalendarFocusStyle styleDefault = (
    CalendarCellType.normal,
    (
      BoxShape.circle,
      null,
      null,
      null,
      null,
      (MaterialColorRole.surface, MaterialEmphasisLevel.primary),
      null,
    ),
    (
      MaterialTextTheme.bodyMedium,
      MaterialColorRole.onSurface,
      MaterialEmphasisLevel.primary,
    ),
  );

  static const List<CalendarFocusStyle> pSelectionOnly = [
    (
      CalendarCellType.selected,
      (null, null, null, null, null, (MaterialColorRole.primary, null), null),
      (MaterialTextTheme.bodyLarge, MaterialColorRole.onPrimary, null),
    ),
    (
      CalendarCellType.outside,
      (null, null, null, null, null, (MaterialColorRole.primary, null), null),
      (null, null, MaterialEmphasisLevel.interactive),
    ),
  ];

  static const List<CalendarFocusStyle> pSelectionAndReady = [
    (
      CalendarCellType.readyToAction,
      (null, null, null, null, null, (MaterialColorRole.primary, null), null),
      (MaterialTextTheme.bodyLarge, MaterialColorRole.onPrimary, null),
    ),
    (
      CalendarCellType.selected,
      (null, null, null, null, null, (MaterialColorRole.tertiary, null), null),
      (MaterialTextTheme.bodyLarge, MaterialColorRole.onTertiary, null),
    ),
    (
      CalendarCellType.outside,
      (
        null,
        null,
        null,
        null,
        null,
        (MaterialColorRole.surface, MaterialEmphasisLevel.inactive),
        null,
      ),
      (null, null, MaterialEmphasisLevel.interactive),
    ),
  ];

  ///
  ///
  ///
  // DateTime get dateFocused;
  //
  // set dateFocused(DateTime value);
  //
  // Map<CalendarCellType, Predicator<DateTime>?> get _predicators;
  //
  // Intersector<DateTime>? get onNewDateFocused;

  bool predicateFocused(DateTime date) => date.isSameDate(dateFocused);

  bool predicateOutside(DateTime date) => date.month != dateFocused.month;

  VoidCallback onFocusDate(Consumer<Callback> setState, DateTime date) =>
      () =>
          date == dateFocused
              ? _continueFocus(setState)
              : _newFocus(setState, date);

  // VoidCallback onDateLongPressed(
  //     ListenListener setState,
  //     DateTime dateTapped,
  //     OnDateChanged? onDateFocused,
  //     ) => () {
  //   final dateFocused = this.dateFocused;
  // };

  ///
  /// [_continueFocus] is called when tapped date is [dateFocused]
  ///
  void _continueFocus(Consumer<Callback> setState);

  ///
  /// [_newFocus] is called when tapped date is not [dateFocused]
  ///
  void _newFocus(Consumer<Callback> setState, DateTime date);
}

///
///
///
base class _CalendarFocusFocusOnly extends CalendarFocus {
  @override
  void _continueFocus(Consumer<Callback> setState) {}

  @override
  void _newFocus(Consumer<Callback> setState, DateTime date) {
    setState(() => dateFocused = date);
  }

  ///
  ///
  ///
  _CalendarFocusFocusOnly(super.dateFocused) : super._() {
    _predicators
      ..putIfAbsent(CalendarCellType.selected, () => predicateFocused)
      ..putIfAbsent(CalendarCellType.outside, () => predicateOutside);
  }
}

///
/// [_selection], ...
/// [_continueFocus], ...
/// [pSelectionAndReady], ...
///
base class _CalendarFocusFocusAndSelection extends CalendarFocus {
  final DatesContainer _selection = DatesContainer.empty();
  FrameCallback? _onRangingAnimationReady;
  FrameCallback? _onRangingAnimationFinished;
  Consumer<(DateTime, DateTime)>? _consumeRanging;
  int _rangingDistance = 0;

  bool get readyToRange => _rangingDistance != 0;

  bool _predicateSelected(DateTime date) => _selection.contains(date);

  bool _predicateReady(DateTime date) =>
      date == dateFocused && readyToRange && _selection.contains(date);

  _CalendarFocusFocusAndSelection(super.dateFocused) : super._() {
    _predicators
      ..putIfAbsent(CalendarCellType.selected, () => _predicateSelected)
      ..putIfAbsent(CalendarCellType.readyToAction, () => _predicateReady);
  }

  ///
  /// todo: calendar focus ranging distance 2, 7, 10, or even 100
  ///
  void _rangingReady() {
    _rangingDistance = 1;
    final onReady = _onRangingAnimationReady;
    if (onReady != null) {
      WidgetsBinding.instance.addPostFrameCallback(onReady);
    }
  }

  void _rangingFinished() {
    _rangingDistance = 0;
    final onFinished = _onRangingAnimationFinished;
    if (onFinished != null) {
      WidgetsBinding.instance.addPostFrameCallback(onFinished);
    }
  }

  ///
  /// 1. continue focus to include a selection
  /// 2. continue focus to ready ranging selection or cancel ranging selection
  ///
  @override
  void _continueFocus(Consumer<Callback> setState) {
    final dateSelected = _selection;

    // 2.
    if (dateSelected.contains(dateFocused)) {
      if (readyToRange) {
        dateSelected.exclude(dateFocused);
        _rangingFinished();
      } else {
        _rangingReady();
      }

      // 1.
    } else {
      dateSelected.include(dateFocused);
    }
    setState(FListener.none);
  }

  ///
  /// 1. include [date] into selection
  /// 2. exclude [date] out of selection
  /// 3. include dates between [date] and [dateFocused]
  ///
  @override
  void _newFocus(Consumer<Callback> setState, DateTime date) {
    final s = _selection;
    final readyToRange = this.readyToRange;

    // 3.
    if (readyToRange) {
      final dF = dateFocused;
      final range = dF.isBefore(date) ? (dF, date) : (date, dF);
      final dEnd = range.$2;
      final distance = _rangingDistance;
      for (var d = range.$1; !d.isAfter(dEnd); d = d.dateAddDays(distance)) {
        s.include(d);
      }
      _consumeRanging?.call(range);
      _rangingFinished();

      // 1, 2.
    } else {
      s.contains(date) ? s.exclude(date) : s.include(date);
    }
    setState(() => dateFocused = date);
  }
}
