import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/routes/app_pages.dart';
import 'package:lnc_mach_app/providers/background_container.dart';
import 'package:lnc_mach_app/screens/create_machine/simple_app_bar.dart';

class CreateMachineDone extends StatelessWidget {
  const CreateMachineDone({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: SimpleAppBar(
          title: "Complete",
          nextAction: () {},
          hideNext: true,
          hideBack: true,
          child: BackgroundContainer(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Added Successfully',
                    style: TextStyle(
                        fontSize: 24.0,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                  const SizedBox(
                    height: 72,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, Routes.MAH_HOME, (route) => route.isFirst);

                        // Get.offNamedUntil(
                        //     Routes.MAH_HOME, (route) => route.isFirst);
                      },
                      style: OutlinedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0)),
                        padding: const EdgeInsets.all(12.0),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Home',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Icon(
                            Icons.touch_app,
                            size: 28,
                            color: Colors.white,
                          ),
                        ],
                      ))
                ],
              ),
            ),
          ))),
      onWillPop: () async {
        return false;
      },
    );
  }
}
