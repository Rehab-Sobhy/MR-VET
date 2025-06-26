import 'package:easy_localization/easy_localization.dart';
import 'package:education_app/auth/choooseRoleToAuth.dart';
import 'package:education_app/auth/login/login_cubit.dart';
import 'package:education_app/auth/login/login_states.dart';
import 'package:education_app/auth/services.dart';
import 'package:education_app/settings/cubitofUser.dart';
import 'package:education_app/settings/statesofuser.dart';
import 'package:education_app/student/bottomBarScreen.dart';
import 'package:education_app/instructor/instructorHomeScreen.dart';
import 'package:education_app/constants/colors.dart';
import 'package:education_app/constants/widgets/custom_texr_field.dart';
import 'package:education_app/constants/widgets/mainButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // Background decoration
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: size.width * 0.7,
                  height: size.height * 0.3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.1),
                        Colors.transparent
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(150),
                    ),
                  ),
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(60),
                    // Welcome back text
                    Text(
                      "welcomMessage".tr(),
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(5),

                    const Gap(40),

                    // Email field
                    Text(
                      "email".tr(),
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(10),
                    CustomTextFieldCard(
                      hintText: 'enter_your_email'.tr(),
                      controller: emailController,
                      prefixIcon:
                          Icon(Icons.email_outlined, color: primaryColor),
                      borderRadius: 12,
                    ),
                    const Gap(20),

                    // Password field
                    Text(
                      "password".tr(),
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(10),
                    CustomTextFieldCard(
                      hintText: 'enter_your_password'.tr(),
                      controller: passwordController,
                      isPassword: !isPasswordVisible,
                      prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                      borderRadius: 12,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: primaryColor.withOpacity(0.6),
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    const Gap(15),

                    // Remember me & Forgot password row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  rememberMe = value!;
                                });
                              },
                              activeColor: primaryColor,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            Text(
                              "remember_me".tr(),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Gap(30),

                    BlocConsumer<LoginCubit, LoginState>(
                      listener: (context, state) async {
                        if (state is LoginFailed) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("loginerror".tr()),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        } else if (state is LoginSuccess) {
                          final authService = AuthServiceClass();
                          String? role = await authService.getCurrentRole();

                          if (role == "student") {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BottomBarScreen()),
                            );
                          } else if (role == "instructor") {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InsHomeScreen()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Unknown role'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      builder: (context, state) {
                        return state is LoginLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryColor),
                                ),
                              )
                            : MainButton(
                                onTap: () async {
                                  if (emailController.text.isNotEmpty &&
                                      passwordController.text.isNotEmpty) {
                                    context.read<LoginCubit>().login(
                                          emailController.text,
                                          passwordController.text,
                                        );

                                    await _loadUserProfile();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text("pleaseFillAllFields".tr()),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                                backGroundColor: primaryColor,
                                text: "login".tr(),
                                textColor: Colors.white,
                                radius: 12,
                              );
                      },
                    ),

                    const Spacer(),

                    // Sign up prompt
                    Center(
                      child: Column(
                        children: [
                          const Gap(30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "donnotHaveAcc".tr(),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 5),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChooseRole()),
                                  );
                                },
                                child: Text(
                                  "creatAcc".tr(),
                                  style: TextStyle(
                                    color: secondaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Gap(20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? userName;
  Future<void> _loadUserProfile() async {
    // تأكد من أن الـ widget ما زال mounted قبل استخدام context
    if (!mounted) return;

    await context.read<ProfileCubit>().fetchUserProfile();

    // تحقق مرة أخرى بعد await لأن الـ widget ممكن يكون Unmounted أثناء الانتظار
    if (!mounted) return;

    final state = context.read<ProfileCubit>().state;
    if (state is ProfileLoaded) {
      setState(() {
        userName = state.userData['user']['name'] ?? "User";
      });
    }
  }
}
