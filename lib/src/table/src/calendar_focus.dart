part of '../table_calendar.dart';

///
///
/// [CalendarFocus]
/// [_CalendarFocusParent]
///   [_CalendarFocusFocusOnly]
///   [_CalendarFocusFocusAndSelection]
///
///
///

typedef CalendarFocusInitializer =
    CalendarFocus Function(
      DateTime dateFocused,
      Intersector<DateTime>? onNewDateFocused,
    );

///
///
/// [CalendarFocus.focusOnly], ...
/// [pFocusOnly], ...
///
/// [dateFocused]
/// [predicateFocused], [predicateOutside]
/// [_predicators]
///
abstract base class CalendarFocus {
  const CalendarFocus._();

  factory CalendarFocus(Calendar widget) => widget.style.focusInitializer(
    (widget.focusedDate ?? DateTime.now()).dateOnly,
    widget.onNewDateFocused,
  );

  factory CalendarFocus.focusOnly(
    DateTime dateFocused,
    Intersector<DateTime>? onNewDateFocused,
  ) = _CalendarFocusFocusOnly;

  factory CalendarFocus.focusAndSelection(
    DateTime dateFocused,
    Intersector<DateTime>? onNewDateFocused,
  ) = _CalendarFocusFocusAndSelection;

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

  static const List<CalendarFocusStyle> pFocusOnly = [
    (
      CalendarCellType.focused,
      (null, null, null, null, null, (MaterialColorRole.primary, null), null),
      (MaterialTextTheme.bodyLarge, MaterialColorRole.onPrimary, null),
    ),
    (
      CalendarCellType.outside,
      (null, null, null, null, null, (MaterialColorRole.primary, null), null),
      (null, null, MaterialEmphasisLevel.interactive),
    ),
  ];

  static const List<CalendarFocusStyle> pFocusAndSelection = [
    (
      CalendarCellType.readyToAction,
      (null, null, null, null, null, (MaterialColorRole.primary, null), null),
      (MaterialTextTheme.bodyLarge, MaterialColorRole.onPrimary, null),
    ),
    (
      CalendarCellType.selected,
      (null, null, null, null, null, (MaterialColorRole.secondary, null), null),
      (MaterialTextTheme.bodyLarge, MaterialColorRole.onSecondary, null),
    ),
    (
      CalendarCellType.focused,
      (
        null,
        null,
        null,
        null,
        null,
        (MaterialColorRole.tertiary, MaterialEmphasisLevel.inactive),
        null,
      ),
      (null, MaterialColorRole.onTertiary, null),
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
  DateTime get dateFocused;

  set dateFocused(DateTime value);

  Map<CalendarCellType, Predicator<DateTime>?> get _predicators;

  Intersector<DateTime>? get onNewDateFocused;

  bool predicateFocused(DateTime date) => date.isSameDate(dateFocused);

  bool predicateOutside(DateTime date) => date.month != dateFocused.month;

  VoidCallback onFocusDate(Consumer<Callback> setState, DateTime date) => () {
    if (date == dateFocused) {
      _continueFocus(setState);
      return;
    }
    if (_newFocus(setState, date)) {
      onNewDateFocused?.call(date, dateFocused);
    }
  };

  // VoidCallback onDateLongPressed(
  //     ListenListener setState,
  //     DateTime dateTapped,
  //     OnDateChanged? onDateFocused,
  //     ) => () {
  //   final dateFocused = this.dateFocused;
  // };

  ///
  /// [_continueFocus] is called when tapped date is focused date
  ///
  void _continueFocus(Consumer<Callback> setState);

  ///
  /// return `true`  when [date] is a new focused date
  /// return `false` when [date] is not a new focused date
  ///
  bool _newFocus(Consumer<Callback> setState, DateTime date);
}

abstract base class _CalendarFocusParent extends CalendarFocus {
  @override
  DateTime dateFocused;
  @override
  final Intersector<DateTime>? onNewDateFocused;
  @override
  final Map<CalendarCellType, Predicator<DateTime>?> _predicators = {
    CalendarCellType.normal: null,
  };

  _CalendarFocusParent(this.dateFocused, this.onNewDateFocused) : super._();
}

///
///
///
base class _CalendarFocusFocusOnly extends _CalendarFocusParent {
  @override
  void _continueFocus(Consumer<Callback> setState) {}

  @override
  bool _newFocus(Consumer<Callback> setState, DateTime date) {
    setState(() => dateFocused = date);
    return true;
  }

  ///
  ///
  ///
  _CalendarFocusFocusOnly(super.dateFocused, super.onNewDateFocused) {
    _predicators
      ..putIfAbsent(CalendarCellType.focused, () => predicateFocused)
      ..putIfAbsent(CalendarCellType.outside, () => predicateOutside);
  }
}

///
/// [_datesSelected], ...
/// [_continueFocus], ...
/// [pFocusAndSelection], ...
///
///
base class _CalendarFocusFocusAndSelection extends _CalendarFocusFocusOnly {
  final DatesContainer _datesSelected = DatesContainer.empty();
  int _rangingDistance = 0;

  bool _predicateFocus(DateTime date) =>
      _datesSelected.isEmpty && dateFocused == date;

  bool _predicateSelected(DateTime date) => _datesSelected.contains(date);

  bool _predicateReady(DateTime date) =>
      date == dateFocused &&
      _datesSelected.contains(date) &&
      _rangingDistance != 0;

  ///
  /// 1. continue focus to add a selection
  /// 2. continue focus to ready to ranging period selection, cancel current selection
  ///
  @override
  void _continueFocus(Consumer<Callback> setState) {
    final dateSelected = _datesSelected;
    if (dateSelected.contains(dateFocused)) {
      // 2.
      if (_rangingDistance != 0) {
        dateSelected.exclude(dateFocused);
        _rangingDistance = 0;
      } else {
        // todo: calendar focus ranging distance 2, 7, 10, or even 100
        _rangingDistance = 1;
      }
    } else {
      // 1.
      dateSelected.include(dateFocused);
    }
    setState(FListener.none);
  }

  ///
  /// return `true`  only when there is no selection
  /// return `false` when there are selection before [_newFocus] been called
  ///   1. [date] have to be removed from the selection
  ///   2. [date] have to be selected
  ///   3. [date] and the dates between [date] and [dateFocused] have to be in the selection
  ///
  @override
  bool _newFocus(Consumer<Callback> setState, DateTime date) {
    final dateSelected = _datesSelected;

    // return true
    if (dateSelected.isEmpty) return super._newFocus(setState, date);

    // return false
    if (dateSelected.contains(date)) {
      // ready to include dates, not excluding date
      if (_rangingDistance != 0) return false;

      // 1.
      dateSelected.exclude(date);
    } else {
      if (_rangingDistance != 0) {
        // 3.
        final selection =
            dateFocused.isBefore(date)
                ? (dateFocused, date)
                : (date, dateFocused);
        final dateEnd = selection.$2;
        dateSelected.include(dateEnd);
        final days = _rangingDistance;
        for (
          var day = selection.$1;
          day.isBefore(dateEnd);
          day = day.dateAddDays(days)
        ) {
          dateSelected.include(day);
        }
        _rangingDistance = 0;
      } else {
        // 2.
        dateSelected.include(date);
      }
    }
    setState(() => dateFocused = date);
    return false;
  }

  ///
  ///
  ///
  _CalendarFocusFocusAndSelection(super.dateFocused, super.onNewDateFocused) {
    _predicators
      ..update(CalendarCellType.focused, (_) => _predicateFocus)
      ..putIfAbsent(CalendarCellType.selected, () => _predicateSelected)
      ..putIfAbsent(CalendarCellType.readyToAction, () => _predicateReady);
  }
}
