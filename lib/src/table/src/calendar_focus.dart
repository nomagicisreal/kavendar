part of '../table_calendar.dart';

///
///
/// [_CalendarFocus]
/// [_CalendarFocusParent]
///   [_CalendarFocusOnly]
///   [_CalendarFocusSelection]
///
///
///

///
/// [_CalendarFocus] is a class handle date cell gesture
/// normal date  -> focused date -> selected date
///
abstract base class _CalendarFocus {
  DateTime get dateFocused;

  set dateFocused(DateTime value);

  const _CalendarFocus._();

  ///
  ///
  ///
  factory _CalendarFocus(Calendar widget) {
    final style = widget.style;
    final dateFocused = widget.focusedDate ?? DateTime.now().dateOnly;
    if (style.styleCellBackground == null) {
      return _CalendarFocusOnly(dateFocused);
    } else {
      return _CalendarFocusSelection(dateFocused);
    }
    // throw UnimplementedError();
  }

  VoidCallback onFocusDate(
    ListenListener setState,
    DateTime dateFocused,
    OnDateChanged? onFocusStart,
  ) => () {
    if (dateFocused == this.dateFocused) {
      _continueFocus(setState);
      return;
    }
    if (_newFocus(setState, dateFocused)) {
      onFocusStart?.call(dateFocused, this.dateFocused);
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
  void _continueFocus(ListenListener setState);

  ///
  /// return `true`  when [date] is a new focused date
  /// return `false` when [date] is not a new focused date
  ///
  bool _newFocus(ListenListener setState, DateTime date);
}

abstract base class _CalendarFocusParent extends _CalendarFocus {
  @override
  DateTime dateFocused;

  _CalendarFocusParent(this.dateFocused) : super._();
}

base class _CalendarFocusOnly extends _CalendarFocusParent {
  _CalendarFocusOnly(super.dateFocused);

  @override
  void _continueFocus(ListenListener setState) {}

  @override
  bool _newFocus(ListenListener setState, DateTime date) {
    setState(() => dateFocused = date);
    return true;
  }
}

///
///
///
base class _CalendarFocusSelection extends _CalendarFocusParent {
  _CalendarFocusSelection(super.dateFocused);

  ///
  /// [_dateSelected], [readyToRangePeriod]
  /// [_unselect], [unselectAll]
  ///
  NodeNextSorted<DateTime>? _dateSelected; // todo: sorted identical set
  bool readyToRangePeriod = false;

  void _unselect(DateTime date) {
    if (_dateSelected!.cutFirst(date)) {
      _dateSelected = _dateSelected?.next;
    }
  }

  void unselectAll() {
    _dateSelected = null;
    readyToRangePeriod = false;
  }

  ///
  /// 1. continue focus to create new selection
  /// 2. continue focus to add more selection
  /// 3. continue focus to ready to ranging period selection
  /// 4. continue focus to cancel current selection
  ///
  @override
  void _continueFocus(ListenListener setState) {
    final dateSelected = _dateSelected;

    if (dateSelected == null) {
      // 1.
      _dateSelected = NodeNextSorted.mutable(dateFocused);
    } else {
      if (dateSelected.contains(dateFocused)) {
        if (readyToRangePeriod) {
          // 4.
          _unselect(dateFocused);
          readyToRangePeriod = false;
        } else {
          // 3.
          readyToRangePeriod = true;
        }
      } else {
        // 2.
        dateSelected.push(dateFocused);
      }
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
  bool _newFocus(ListenListener setState, DateTime date) {
    //
    final dateSelected = _dateSelected;
    if (dateSelected == null) {
      setState(() => dateFocused = date);
      return true;
    }

    //
    if (dateSelected.contains(date)) {
      // 1.
      _unselect(date);
    } else {
      if (readyToRangePeriod) {
        // 3.
        final range =
            dateFocused.isBefore(date)
                ? (dateFocused, date)
                : (date, dateFocused);
        final dateEnd = range.$2;
        dateSelected.push(dateEnd);
        for (var d = range.$1; d.isBefore(dateEnd); d = d.dateAddDays(1)) {
          dateSelected.push(d);
        }
      } else {
        // 2.
        dateSelected.push(date);
      }
    }
    setState(FListener.none);
    return false;
  }
}
