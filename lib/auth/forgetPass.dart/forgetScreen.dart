// import 'package:easy_localization/easy_localization.dart';
// import 'package:education_app/resources/colors.dart';
// import 'package:education_app/resources/customTextField.dart';
// import 'package:education_app/resources/style_manager.dart';
// import 'package:education_app/resources/widgets/mainButton.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   TextEditingController emailController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           Gap(10),
//           CustomTextField(
//             cotroller: emailController,
//             hintText: "password".tr(),
//           ),
//           Gap(30),
//           MainButton(
//             color: ColorManeger.primary,
//             text: "login".tr(),
//             onTap: () {},
//           ),
//           Row(
//             children: [
//               Text(
//                 "donnotHaveAcc".tr(),
//                 style: StyleManager.sBoldBlack14,
//               ),
//               Gap(10),
//               Text(
//                 "registerNow".tr(),
//                 style: StyleManager.sBoldBlack14,
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
