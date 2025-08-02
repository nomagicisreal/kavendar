part of '../table_calendar.dart';

///
///
///
class CalendarPageState {
  final PageController controller;
  final ValueNotifier<double> height;
  final ValueNotifier<int> weeks;
  int count;
  int indexPrevious;
  Generator<DateTime> findDate;

  CalendarPageState({
    required this.controller,
    required this.height,
    required this.weeks,
    required this.count,
    required this.findDate,
  }) : indexPrevious = controller.initialPage;

  void dispose() {
    controller.dispose();
    height.dispose();
    weeks.dispose();
  }

  ///
  /// [finderFrom]
  /// [_focusOnPageDate]
  /// [_indexFinderFrom]
  ///
  static Generator<DateTime> finderFrom(
    DateTime domainStart,
    DateTime domainEnd,
    int weeksPerPage,
    int formatStartingWeekday,
  ) => switch (weeksPerPage) {
    CalendarStyle.weeksPerPage_6 => DateTimeExtension.daysToDateClampFrom(
      domainStart,
      domainEnd,
      startingWeekday: formatStartingWeekday,
      times: DateTime.daysPerWeek * weeksPerPage,
    ),
    _ => throw UnimplementedError(),
  };

  DateTime? _focusOnPageDate(
    int weeksPerPage,
    int index,
    int indexPrevious,
    CalendarPageNext? toWhere,
  ) {
    if (weeksPerPage == CalendarStyle.weeksPerPage_6) {
      return switch (toWhere) {
        null => null,
        CalendarPageNext.correspondingDay => throw UnimplementedError(),
        CalendarPageNext.correspondingWeekAndDay => throw UnimplementedError(),
        CalendarPageNext.firstDateOfMonth => throw UnimplementedError(),
        CalendarPageNext.firstDateOfFirstWeek => throw UnimplementedError(),
        CalendarPageNext.lastDateOfMonth => throw UnimplementedError(),
        CalendarPageNext.lastDateOfLastWeek => throw UnimplementedError(),
      };
    } else {
      throw UnimplementedError();
    }
  }

  ValueChanged<int> _indexFinderFrom(
    CalendarStyle style,
    CalendarFocus focus,
  ) => (index) {
    if (index == this.indexPrevious) return;
    final indexPrevious = this.indexPrevious;
    final next = _focusOnPageDate(
      weeks.value,
      index,
      indexPrevious,
      style.pageToWhere,
    );
    if (next != null) focus.dateFocused = next;

    this.indexPrevious = index;
    style.pageOnChanged?.call(index, indexPrevious, next ?? focus.dateFocused);
  };

  ///
  ///
  ///
  static PageController initializer(
    DateTimeRange domain,
    int weeksPerPage,
    DateTime dateFocused,
  ) => PageController(
    initialPage:
        CalendarPageState.measure(
          domain.start,
          dateFocused,
          weeksPerPage,
        ).floor(),
  );

  static double measure(DateTime start, DateTime target, int weeksPerPage) =>
      (target.difference(start).inDays + 1) /
      (DateTime.daysPerWeek * weeksPerPage);
}

///
/// todo: [CalendarPageNext] is inappropriate as enum
///
enum CalendarPageNext {
  correspondingDay,
  correspondingWeekAndDay,
  firstDateOfMonth,
  firstDateOfFirstWeek,
  lastDateOfMonth,
  lastDateOfLastWeek,
}
