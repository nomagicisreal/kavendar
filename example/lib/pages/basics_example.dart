// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:example/utils.dart';
import 'package:flutter/material.dart';
import 'package:kavendar/kavendar.dart';

class TableBasicsExample extends StatefulWidget {
  const TableBasicsExample({super.key});

  @override
  State<TableBasicsExample> createState() => _TableBasicsExampleState();
}

class _TableBasicsExampleState extends State<TableBasicsExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      appBar: AppBar(title: const Text('TableCalendar - Basics')),
      body: Calendar(style: CalendarStyle()),
    );
  }
}
