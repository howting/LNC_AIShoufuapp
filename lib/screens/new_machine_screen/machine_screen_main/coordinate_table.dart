// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';

class CoordinateTable extends StatelessWidget {
  const CoordinateTable({super.key});

  final double ROW_HEIGHT = 32.0;
  final double SQUARE_WIDTH = 32.0;
  final double CELL_GAP = 9.0;
  final double ROW_GAP = 2.0;
  final double HEAD_GAP = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Table(columnWidths: <int, TableColumnWidth>{
        0: FixedColumnWidth(SQUARE_WIDTH),
        1: FixedColumnWidth(CELL_GAP),
        2: const FlexColumnWidth(),
        3: const FlexColumnWidth(),
      }, children: <TableRow>[
        _headRow(context),
        _bodyRow(context, 'X', Theme.of(context).colorScheme.secondary),
        _bodyRow(context, 'Y', Theme.of(context).colorScheme.secondary),
        _bodyRow(context, 'Z', Theme.of(context).colorScheme.secondary),
        _bodyRow(context, 'A', Colors.grey),
        _bodyRow(context, 'C', Colors.grey),
      ]),
    );
  }

  TableRow _bodyRow(BuildContext context, String text, Color color) {
    return TableRow(children: <Widget>[
      TableCellPadded(
        rowGap: ROW_GAP,
        child: Container(
            height: ROW_HEIGHT,
            alignment: Alignment.center,
            color: color,
            child: Text(text, style: const TextStyle(fontSize: 24.0))),
      ),
      Container(),
      TableCellPadded(
        rowGap: ROW_GAP,
        child: Container(
            height: ROW_HEIGHT,
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: const Center(
                child: Text(
              '0000.000',
              style: TextStyle(fontSize: 11.0),
            ))),
      ),
      TableCellPadded(
        rowGap: ROW_GAP,
        child: Container(
            height: ROW_HEIGHT,
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: const Center(
                child: Text('0000.000', style: TextStyle(fontSize: 15.0)))),
      ),
    ]);
  }

  TableRow _headRow(BuildContext context) {
    return TableRow(children: <Widget>[
      Container(),
      Container(),
      TableCellPadded(
        rowGap: HEAD_GAP,
        child:
            const Center(child: Text('DTG', style: TextStyle(fontSize: 11.0))),
      ),
      TableCellPadded(
        rowGap: HEAD_GAP,
        child: const Center(
            child: Text(
          'POSITION',
          style: TextStyle(fontSize: 11.0),
        )),
      )
    ]);
  }
}

class TableCellPadded extends StatelessWidget {
  const TableCellPadded({super.key, required this.child, this.rowGap = 4.0});
  final Widget child;
  final double rowGap;

  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: rowGap),
        child: child,
      ),
    );
  }
}
