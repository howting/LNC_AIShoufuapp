import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/routes/app_pages.dart';
import 'package:lnc_mach_app/providers/background_container.dart';
import 'package:lnc_mach_app/screens/create_machine/simple_app_bar.dart';
import 'package:lnc_mach_app/utils/add_machine.dart';
import 'package:lnc_mach_app/utils/storage.dart';
import 'package:lnc_mach_app/screens/create_machine/create_mach_text_field.dart';

class CreateMachineName extends StatefulWidget {
  const CreateMachineName({super.key, required this.ip});

  final String ip;
  @override
  State<CreateMachineName> createState() => _CreateMachineName();
}

class _CreateMachineName extends State<CreateMachineName> {
  final TextEditingController nameInputController = TextEditingController();

  Storage storage = Storage();
  String? errorText;
  void handleSubmit() async {
    setState(() {
      errorText = null;
    });
    await addMachine(
        controller: nameInputController,
        setErrMsg: (err) {
          setState(() {
            errorText = err;
          });
        },
        ip: widget.ip);
    if (errorText != null) return;
    postAddMachineSuccess();
  }

  void postAddMachineSuccess() {
    Fluttertoast.showToast(
        msg: "新增成功",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 20.0);
    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.pushNamedAndRemoveUntil(
          context, Routes.CREATE_DONE, (route) => route.isFirst);
      // Get.toNamed(Routes.CREATE_DONE);
    });
  }

  @override
  void initState() {
    super.initState();
    storage.init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SimpleAppBar(
      title: 'Machine Name',
      nextAction: () {
        handleSubmit();
      },
      child: BackgroundContainer(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            MyTextField(
              textController: nameInputController,
              isNumKeyboard: true,
              label: 'Machine Name',
              errorText: errorText,
            ),
          ],
        ),
      ),
    ));
  }
}
