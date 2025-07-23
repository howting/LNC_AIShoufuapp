import 'package:flutter/material.dart';

class MachineAxisRowItem extends StatelessWidget {
  const MachineAxisRowItem(
      {Key? key, this.last = false, required this.label, required this.value})
      : super(key: key);

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border(
                right: BorderSide(
                    color: last ? Colors.transparent : Colors.white38,
                    width: 1))),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        height: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              label,
              style: TextStyle(
                  color: Colors.blue[400],
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
            ),
            FittedBox(
              child: Text(
                value,
                style: const TextStyle(
                    color: Color.fromARGB(255, 231, 231, 231),
                    fontSize: 11.0,
                    letterSpacing: 1),
              ),
            )
          ],
        ));
  }
}
