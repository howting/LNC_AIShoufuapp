// import 'package:extended_text_field/extended_text_field.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:lnc_ds/module/voice_record/customer_chat_voice_record_layout.dart';

// import 'chat_controller.dart';

// class ChatPage extends GetView<ChatController> {
//   @override
//   Widget build(BuildContext context) {
//     return CustomerChatVoiceRecordLayout(
//       onCompleted: (sec, path) {
//         if (sec == 0) {
//           Fluttertoast.showToast(msg: "語音時間過短。", gravity: ToastGravity.CENTER);
//           return;
//         }
//         print("onCompleted: $sec, $path");
//         controller.makeBase64(path);
//       },
//       builder: (bar) => GestureDetector(
//         onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
//         child: AnimatedContainer(
//           duration: Duration.zero,
//           height: MediaQuery.of(context).viewInsets.bottom > 0
//               ? Get.height - MediaQuery.of(context).viewInsets.bottom
//               : Get.height,
//           child: Scaffold(
//             backgroundColor: Colors.white,
//             appBar: AppBar(
//               backgroundColor: Colors.white,
//               elevation: 0,
//               leading: const Icon(
//                 Icons.short_text,
//                 color: Colors.black,
//                 size: 24,
//               ),
//               title: const Text(
//                 "新对话",
//                 style: TextStyle(fontSize: 16, color: Colors.black),
//               ),
//               centerTitle: true,
//               actions: const [
//                 Padding(
//                   padding: EdgeInsets.only(right: 14.0),
//                   child: Icon(
//                     Icons.add_circle_outline,
//                     color: Colors.black,
//                     size: 24,
//                   ),
//                 )
//               ],
//             ),
//             body: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Expanded(
//                     child: Obx(
//                   () => ListView.builder(
//                     itemCount: controller.chatMessageList.length,
//                     itemBuilder: (BuildContext context, int index) {
//                       ChatMessage message = controller.chatMessageList[index];
//                       return Container(
//                           color: message.isMe
//                               ? const Color.fromARGB(255, 255, 164, 164)
//                               : Colors.greenAccent,
//                           padding: EdgeInsets.symmetric(
//                               vertical: 12.h, horizontal: 16.w),
//                           child: Text(
//                             message.data,
//                             textAlign:
//                                 message.isMe ? TextAlign.right : TextAlign.left,
//                           ));
//                     },
//                   ),
//                 )),
//                 inputWidget(),
//                 buttonRow(),
//                 bar
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget inputWidget() {
//     return Container(
//       alignment: Alignment.center,
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
//       width: Get.width,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(22.5),
//         color: const Color.fromARGB(255, 245, 245, 245),
//       ),
//       child: ExtendedTextField(
//         controller: controller.textController,
//         minLines: 1,
//         maxLines: 4,
//         decoration: const InputDecoration(
//             border: InputBorder.none,
//             hintText: "向 DeepSeek 发送讯息",
//             hintStyle: TextStyle(
//                 color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 16),
//             contentPadding:
//                 EdgeInsets.only(left: 16, top: 13, bottom: 13, right: 16)),
//       ),
//     );
//   }

//   Widget buttonRow() {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
//       height: 50,
//       width: Get.width,
//       child: Row(
//         children: [
//           deepThinkWidget(),
//           const SizedBox(width: 10),
//           networkSearchWidget(),
//           const Spacer(),
//           const Icon(
//             Icons.add,
//             size: 26,
//           ),
//           const SizedBox(width: 10),
//           sendButton()
//         ],
//       ),
//     );
//   }

//   Widget deepThinkWidget() {
//     return ObxValue<RxBool>(
//         (val) => InkWell(
//               onTap: () => controller.seletDeepthink.toggle(),
//               child: Container(
//                 height: 30,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     color: controller.seletDeepthink.value
//                         ? const Color.fromARGB(255, 188, 216, 247)
//                         : const Color.fromARGB(255, 245, 245, 245)),
//                 child: const Row(
//                   children: [
//                     Icon(
//                       Icons.self_improvement,
//                       size: 20,
//                     ),
//                     SizedBox(width: 3),
//                     Text("深度思考(R1)")
//                   ],
//                 ),
//               ),
//             ),
//         controller.seletDeepthink);
//   }

//   Widget networkSearchWidget() {
//     return ObxValue<RxBool>(
//         (val) => InkWell(
//               onTap: () => controller.seletNetworkSearch.toggle(),
//               child: Container(
//                 height: 30,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     color: controller.seletNetworkSearch.value
//                         ? const Color.fromARGB(255, 188, 216, 247)
//                         : const Color.fromARGB(255, 245, 245, 245)),
//                 child: const Row(
//                   children: [
//                     Icon(
//                       Icons.language,
//                       size: 20,
//                     ),
//                     SizedBox(width: 3),
//                     Text("联网搜寻")
//                   ],
//                 ),
//               ),
//             ),
//         controller.seletNetworkSearch);
//   }

//   Widget sendButton() {
//     return Obx(() => controller.isSending.value
//         ? const SizedBox(
//             height: 26, width: 26, child: CupertinoActivityIndicator())
//         : InkWell(
//             onTap: () =>
//                 controller.canSend.value ? controller.sendAction() : null,
//             child: Container(
//               height: 26,
//               width: 26,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(26),
//                 color: controller.canSend.value
//                     ? Colors.blue
//                     : const Color.fromARGB(186, 68, 137, 255),
//               ),
//               child: const Icon(
//                 Icons.arrow_upward,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//           ));
//   }
// }
