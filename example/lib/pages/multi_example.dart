// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

// ignore_for_file: avoid_print

import 'dart:collection';

import 'package:example/utils.dart';
import 'package:flutter/material.dart';
import 'package:kavendar/kavendar.dart';

class TableMultiExample extends StatefulWidget {
  const TableMultiExample({super.key});

  @override
  State<TableMultiExample> createState() => _TableMultiExampleState();
}

class _TableMultiExampleState extends State<TableMultiExample> {
  final ValueNotifier<List<Event>> _selectedEvents = ValueNotifier([]);

  // Using a `LinkedHashSet` is recommended due to equality comparison override
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  DateTime _focusedDay = DateTime.now();

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForDays(Set<DateTime> days) {
    // Implementation example
    // Note that days are in selection order (same applies to events)
    return [for (final d in days) ..._getEventsForDay(d)];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      // Update values in a Set
      if (_selectedDays.contains(selectedDay)) {
        _selectedDays.remove(selectedDay);
      } else {
        _selectedDays.add(selectedDay);
      }
    });

    _selectedEvents.value = _getEventsForDays(_selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TableCalendar - Multi')),
      body: Column(
        children: [
          Calendar<Event>(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            eventLoader: _getEventsForDay,
            style: CalendarStyle(startingWeekday: DateTime.monday),
            predicateSelect: (day) {
              return _selectedDays.contains(day);
            },
            onDaySelected: _onDaySelected,
            onPageChanged: (index, focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          ElevatedButton(
            child: const Text('Clear selection'),
            onPressed: () {
              setState(() {
                _selectedDays.clear();
                _selectedEvents.value = [];
              });
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        onTap: () => print('${value[index]}'),
                        title: Text('${value[index]}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
