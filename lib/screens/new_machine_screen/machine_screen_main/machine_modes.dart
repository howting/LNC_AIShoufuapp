import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MachineModes extends StatelessWidget {
  const MachineModes({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ModeImgModal(),
      builder: (context, _) {
        return Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 9.0),
              child: Material(
                color: Colors.transparent,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      imageButton(id: 1, onTap: () {}),
                      imageButton(id: 2, onTap: () {}),
                      imageButton(id: 3, onTap: () {}),
                      imageButton(id: 4, onTap: () {}),
                    ]),
              ),
            ),
            // const SizedBox(height: 8.0),
            // Container(
            //   color: Theme.of(context).colorScheme.primaryContainer,
            //   padding: const EdgeInsets.symmetric(vertical: 9.0),
            //   child: Material(
            //     color: Colors.transparent,
            //     child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            //       imageButton(id: 1, onTap: () {}),
            //       imageButton(id: 2, onTap: () {}),
            //       imageButton(id: 3, onTap: () {}),
            //       imageButton(id: 4, onTap: () {}),
            //     ]),
            //   ),
            // ),
          ],
        );
      },
    );
  }

  Widget imageButton({required void Function() onTap, required int id}) {
    return Selector<ModeImgModal, String>(
      shouldRebuild: (previous, next) => previous != next,
      selector: (ctx, model) => model.imageMap[id]['status'],
      builder: (context, value, child) {
        return InkWell(
          onTap: () {
            context.read<ModeImgModal>().toggleImage(id);
            onTap();
          },
          child: Ink(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.0),
                image: DecorationImage(
                    image: AssetImage(context.watch<ModeImgModal>().imageMap[id]
                        [context.watch<ModeImgModal>().imageMap[id]['status']]),
                    fit: BoxFit.cover)),
            height: 78,
            width: 78,
          ),
        );
      },
    );
  }
}

class ModeImgModal extends ChangeNotifier {
  Map imageMap = {
    1: {
      'on': 'assets/GoToZero_on.png',
      'off': 'assets/GoToZero_off.png',
      'status': 'off'
    },
    2: {
      'on': 'assets/HomeAll_on.png',
      'off': 'assets/HomeAll_off.png',
      'status': 'off'
    },
    3: {
      'on': 'assets/ZeroAll_on.png',
      'off': 'assets/ZeroAll_off.png',
      'status': 'off'
    },
    4: {
      'on': 'assets/GoToZero_on.png',
      'off': 'assets/GoToZero_off.png',
      'status': 'off'
    }
  };

  void changeImage(int id, String status) {
    imageMap[id]['status'] = status;
    notifyListeners();
  }

  void toggleImage(int id) {
    imageMap[id]['status'] = imageMap[id]['status'] == 'on' ? 'off' : 'on';
    notifyListeners();
  }
}
