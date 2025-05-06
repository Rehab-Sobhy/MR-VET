// import 'package:easy_localization/easy_localization.dart';
// import 'package:education_app/resources/colors.dart';
// import 'package:education_app/resources/customTextField.dart';
// import 'package:education_app/resources/style_manager.dart';
// import 'package:education_app/resources/widgets/mainButton.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   TextEditingController emailController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           Text("creatAcc".tr()),
//           CustomTextField(
//             cotroller: emailController,
//             hintText: "name".tr(),
//           ),
//           CustomTextField(
//             cotroller: emailController,
//             hintText: "email".tr(),
//           ),
//           CustomTextField(
//             cotroller: emailController,
//             hintText: "phone".tr(),
//           ),
//           Gap(10),
//           CustomTextField(
//             cotroller: emailController,
//             hintText: "password".tr(),
//           ),
//           CustomTextField(
//             cotroller: emailController,
//             hintText: "confirmPassword".tr(),
//           ),
//           Gap(30),
//           MainButton(
//             backGroundColor: primaryColor,
//             text: "register".tr(),
//             onTap: () {},
//           ),
//           Row(
//             children: [
//               Text(
//                 "alreadyHaveAcc".tr(),
//                 style: StyleManager.sBoldBlack14,
//               ),
//               Gap(10),
//               Text(
//                 "loginNow".tr(),
//                 style: StyleManager.sBoldBlack14,
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
