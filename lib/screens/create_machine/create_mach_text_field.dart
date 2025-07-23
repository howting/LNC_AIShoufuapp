import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  const MyTextField(
      {Key? key,
      this.label = '',
      this.isNumKeyboard = false,
      this.errorText,
      required this.textController})
      : super(key: key);

  final String label;
  final TextEditingController textController;
  final bool isNumKeyboard;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      controller: textController,
      keyboardType: isNumKeyboard ? TextInputType.number : TextInputType.text,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: .9),
      decoration: InputDecoration(
          label: Text(label, style: const TextStyle(color: Colors.white70)),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          errorText: errorText ?? errorText,
          errorStyle: TextStyle(fontSize: 20, color: Colors.red[400]),
          filled: true,
          fillColor: Theme.of(context).colorScheme.primaryContainer,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.0),
              borderSide: const BorderSide(width: 1, color: Colors.white70)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.0),
              borderSide: const BorderSide(width: 0, style: BorderStyle.none))),
    );
  }
}
