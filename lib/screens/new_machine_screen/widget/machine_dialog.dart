import 'package:flutter/material.dart';

mixin MachineDialog {
  Future<void> machineDialog({required String title, required Widget content, required BuildContext context}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color.fromARGB(230, 36, 40, 43),
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
              textTheme: Theme.of(context).textTheme.apply(bodyColor: const Color.fromARGB(255, 239, 239, 239)),
              textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 239, 239, 239),
                      textStyle: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal)))),
          child: Stack(
            children: [
              AlertDialog(
                elevation: 0,
                backgroundColor: Colors.transparent,
                alignment: Alignment.topCenter,
                title: Center(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                ),
                content: content,
              ),
              Positioned(
                  bottom: 16,
                  right: 16,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.white),
                            borderRadius: BorderRadius.circular(2.0)),
                        child: const Icon(Icons.close, size: 24)),
                  )),
            ],
          ),
        );
      },
    );
  }
}
