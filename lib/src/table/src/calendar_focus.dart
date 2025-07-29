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
/// [_CalendarFocus] is a class handle [_CalendarState._onDateTapped]
/// normal date  -> focused date -> selected date
/// when there is a selected date:
/// 1. continue selecting date by date
/// 2. continue selecting by ranging dates
/// 3. cancel selection date by date (remove selection, split range selection)
/// 4. cancel all selection
///
///
abstract base class _CalendarFocus {
  DateTime get dateFocused;

  set dateFocused(DateTime value);

  const _CalendarFocus._();

  factory _CalendarFocus(Calendar widget) {
    final style = widget.style;
    final dateFocused = widget.focusedDate ?? DateTime.now().dateOnly;
    if (style.styleCellBackground == null) {
      return _CalendarFocusOnly(dateFocused);
    } else {
      return _CalendarFocusSelection(dateFocused);
    }
    throw UnimplementedError();
  }

  // static Never _noSuchProperty(String name) =>
  //     throw StateError('[$name] is not available when [CalendarStyle.] is [].');

  void continueFocusing(ListenListener setState);

  ///
  /// return `true`  if focused on new date due to new intention
  /// return `false` if focused on new date due to old intention
  ///
  bool newFocus(ListenListener setState, DateTime dateTapped);
}

abstract base class _CalendarFocusParent extends _CalendarFocus {
  @override
  DateTime dateFocused;

  _CalendarFocusParent(this.dateFocused) : super._();
}

base class _CalendarFocusOnly extends _CalendarFocusParent {
  _CalendarFocusOnly(super.dateFocused);

  @override
  void continueFocusing(ListenListener setState) {}

  @override
  bool newFocus(ListenListener setState, DateTime dateTapped) {
    setState(() => dateFocused = dateTapped);
    return true;
  }
}

///
///
///
base class _CalendarFocusSelection extends _CalendarFocusParent {
  NodeNextSorted<DateTime>? _dateSelected;
  bool readyToRange = false;

  _CalendarFocusSelection(super.dateFocused);

  ///
  /// 1. continue focus to select
  /// 2. continue focus to select range
  ///
  @override
  void continueFocusing(ListenListener setState) {
    final dateSelected = _dateSelected;
    if (dateSelected == null) {
      _dateSelected = NodeNextSorted.mutable(dateFocused);
    }
    readyToRange = true;
    setState(FListener.none);
  }

  ///
  /// return `true`  if focused on new date without any selection
  /// return `false` if focused on new date with selection
  ///
  @override
  bool newFocus(ListenListener setState, DateTime dateTapped) {
    final dateSelected = _dateSelected;
    if (dateSelected == null) {
      setState(() => dateFocused = dateTapped);
      readyToRange = false;
      return true;
    }
    if (readyToRange) {
      final dateFocused = this.dateFocused;
      assert(dateSelected.contains(dateFocused));
      final range =
          dateFocused.isBefore(dateTapped)
              ? (dateFocused, dateTapped)
              : (dateTapped, dateFocused);
      final finalDate = range.$2.addDays(1);
      for (
        var date = range.$1.dateAddDays(1);
        date.isBefore(finalDate);
        date = date.dateAddDays(1)
      ) {
        dateSelected.push(date);
      }
      setState(FListener.none);
    } else {
      setState(() {
        if (!dateSelected.pullByRemove(dateTapped)) {
          dateSelected.push(dateTapped);
        }
      });
    }
    readyToRange = false;
    return false;
  }

}
