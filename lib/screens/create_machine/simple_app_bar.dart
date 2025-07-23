import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class SimpleAppBar extends StatelessWidget {
  const SimpleAppBar({
    Key? key,
    required this.child,
    required this.nextAction,
    this.title = 'App Bar',
    this.isLoading = false,
    this.backLabel = 'Back',
    this.hideNext = false,
    this.hideBack = false,
  }) : super(key: key);

  final bool isLoading;
  final bool hideNext;
  final bool hideBack;
  final VoidCallback nextAction;
  final Widget child;
  final String backLabel;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(0, 56),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Theme(
            data: ThemeData(
                textButtonTheme: TextButtonThemeData(
                    style: ButtonStyle(
                        overlayColor: MaterialStateColor.resolveWith(
                            (states) => Colors.transparent),
                        foregroundColor:
                            MaterialStateColor.resolveWith((states) {
                          if (states.contains(MaterialState.pressed)) {
                            return const Color.fromARGB(100, 137, 185, 41);
                          }
                          return Theme.of(context).colorScheme.secondary;
                        })))),
            child: AppBar(
              centerTitle: true,
              elevation: 0,
              title: Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.transparent,
              leading: hideBack
                  ? const SizedBox()
                  : TextButton(
                      onPressed: () {
                        // Navigator.pop(context);

                        Get.back();
                      },
                      style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.all(0)),
                      child: Text(
                        backLabel,
                        style: const TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.normal),
                      )),
              actions: [
                isLoading
                    ? SpinKitWave(
                        color: Theme.of(context).colorScheme.secondary,
                        size: 20.0,
                      )
                    : SizedBox(
                        child: hideNext
                            ? null
                            : TextButton(
                                onPressed: nextAction,
                                style: TextButton.styleFrom(
                                    minimumSize: Size.zero,
                                    padding: const EdgeInsets.all(0)),
                                child: const Text(
                                  'Next',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.normal),
                                )),
                      )
              ],
            ),
          ),
        ),
      ),
      body: child,
    );
  }
}
