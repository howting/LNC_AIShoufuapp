import 'package:flutter/material.dart';

class MyBackButton extends StatelessWidget {
  const MyBackButton({Key? key, this.label = "", this.showIcon = true}) : super(key: key);

  final String label;
  final bool showIcon;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextButton(
        style: TextButton.styleFrom(foregroundColor: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            showIcon
                ? const Icon(
                    Icons.arrow_back_ios,
                    size: 16,
                  )
                : const SizedBox(),
            Text(label)
          ],
        ),
        onPressed: () => Navigator.of(context).pop("data"),
      ),
    );
  }
}
