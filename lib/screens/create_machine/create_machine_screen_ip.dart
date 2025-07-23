import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lnc_mach_app/ai/routes/app_pages.dart';
import 'package:lnc_mach_app/global.dart';
import 'package:lnc_mach_app/providers/background_container.dart';
import 'package:lnc_mach_app/providers/recorn.dart';
import 'package:lnc_mach_app/screens/create_machine/simple_app_bar.dart';
import 'package:lnc_mach_app/screens/create_machine/create_mach_text_field.dart';
import 'package:provider/provider.dart';

class CreateMahcineIP extends StatefulWidget {
  const CreateMahcineIP({super.key});

  @override
  State<CreateMahcineIP> createState() => _CreateMahcineIP();
}

class _CreateMahcineIP extends State<CreateMahcineIP> {
  // RegExp: ip address regx
  RegExp ipExp = RegExp(
      r"^(?!0)(?!.*\.$)((1?\d?\d|25[0-5]|2[0-4]\d)(\.|$)){4}$",
      caseSensitive: false,
      multiLine: false);
  final TextEditingController ipInputContoller = TextEditingController();
  late Recorn _recorn;
  String? errorText;
  bool _loading = false;

  // Function: handle submit and check ip address
  Future<void> handleSubmit() async {
    final String ip = ipInputContoller.value.text;
    if (!ipExp.hasMatch(ip)) {
      setState(() {
        errorText = 'Please enter a correct IP address';
      });
      return;
    }
    setState(() {
      errorText = null;
      _loading = true;
    });

    // bool: test connect and return connect status true of false
    bool isConnectStateSuccess = await _recorn.testConnection(ip);

    if (isConnectStateSuccess) {
      postConnectSuccess(ip);
    } else {
      errorText = 'Connection time out';
    }
    _recorn.disconnect();
    _recorn.cleanIsolate();
    setState(() {
      _loading = false;
    });
  }

  void postConnectSuccess(String ip) {
    Fluttertoast.showToast(
        msg: "Connect Successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.0);

    Future.delayed(const Duration(milliseconds: 100), () {
      // Navigator.pushNamed(context, '/create-name', arguments: {'ip': ip});
      Get.toNamed(Routes.CREATE_NAME, arguments: {'ip': ip});
    });
  }

  @override
  void didChangeDependencies() {
    // _recorn = Provider.of<Recorn>(context, listen: false);
    _recorn = Global.recorn;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _recorn.clearTestingConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SimpleAppBar(
      title: 'IP Address',
      isLoading: _loading,
      nextAction: () {
        handleSubmit();
      },
      child: BackgroundContainer(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            MyTextField(
              textController: ipInputContoller,
              isNumKeyboard: true,
              label: 'IP Address',
              errorText: errorText,
            ),
          ],
        ),
      ),
    ));
  }
}
