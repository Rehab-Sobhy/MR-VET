import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:education_app/auth/login/login_screen.dart';
import 'package:education_app/auth/register/cubit.dart';
import 'package:education_app/auth/register/register_model.dart';
import 'package:education_app/auth/register/register_states.dart';
import 'package:education_app/constants/colors.dart';
import 'package:education_app/constants/widgets/custom_texr_field.dart';
import 'package:education_app/constants/widgets/mainButton.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  final String role;

  const RegisterScreen({Key? key, required this.role}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RegisterModel _registerModel = RegisterModel();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  File? _selectedCollegeIdImage;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      _showErrorSnackbar('image_pick_error'.tr());
    }
  }

  Future<void> _pickCollegeIdImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _selectedCollegeIdImage = File(pickedFile.path));
      }
    } catch (e) {
      _showErrorSnackbar('id_pick_error'.tr());
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isStudent = widget.role == 'student';

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider(
        create: (_) => RegisterCubit(),
        child: Stack(
          children: [
            _buildBackgroundDecoration(size),
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: BlocConsumer<RegisterCubit, RegisterState>(
                listener: (context, state) {
                  if (state is RegisterSuccess) {
                    _showSuccessSnackbar('registration_success'.tr());
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  } else if (state is RegisterFailed) {
                    _showErrorSnackbar(state.errMessage);
                  }
                },
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(40),
                      _buildHeader(context),
                      const Gap(20),
                      _buildRoleChip(),
                      const Gap(30),
                      _buildNameField(),
                      const Gap(20),
                      _buildEmailField(),
                      const Gap(20),
                      _buildPasswordField(),
                      const Gap(10),
                      _buildPasswordHint(),
                      const Gap(20),
                      Row(
                        children: [
                          _buildProfilePictureSection(),
                          const Gap(20),
                          // if (!isStudent)
                          _buildCollegeIdSection(),
                        ],
                      ),
                      _buildRegisterButton(state),
                      _buildLoginPrompt(),
                      const Gap(50),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecoration(Size size) {
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        width: size.width * 0.6,
        height: size.height * 0.2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor.withOpacity(0.1), Colors.transparent],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(150),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        const Gap(10),
        Text(
          'create_account'.tr(),
          style: TextStyle(
            color: secondaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleChip() {
    return Center(
      child: Chip(
        backgroundColor: primaryColor.withOpacity(0.2),
        label: Text(
          widget.role.tr(),
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return _buildTextField(
      label: 'full_name'.tr(),
      hint: 'enter_full_name'.tr(),
      controller: _nameController,
      icon: Icons.person_outline,
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      label: 'email_address'.tr(),
      hint: 'enter_email'.tr(),
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      icon: Icons.email_outlined,
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      label: 'password'.tr(),
      hint: 'enter_password'.tr(),
      controller: _passwordController,
      isPassword: true,
      icon: Icons.lock_outline,
    );
  }

  Widget _buildPasswordHint() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'password_hint'.tr(),
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'profile_picture'.tr(),
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const Gap(10),
        _buildImagePicker(
          image: _selectedImage,
          onTap: _pickImage,
          label: 'upload_profile'.tr(),
        ),
      ],
    );
  }

  Widget _buildCollegeIdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Text(
            'college_id_proof'.tr(),
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const Gap(10),
        _buildImagePicker(
          image: _selectedCollegeIdImage,
          onTap: _pickCollegeIdImage,
          label: 'upload_id_proof'.tr(),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(RegisterState state) {
    return Column(
      children: [
        const Gap(20),
        if (state is RegisterLoading)
          Center(child: CircularProgressIndicator(color: primaryColor))
        else
          MainButton(
            onTap: _validateAndRegister,
            backGroundColor: primaryColor,
            text: 'complete_registration'.tr(),
            textColor: Colors.white,
            radius: 12,
          ),
      ],
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Text.rich(
        TextSpan(
          text: 'already_have_account'.tr(),
          style: TextStyle(color: Colors.grey),
          children: [
            const WidgetSpan(child: SizedBox(width: 5)),
            TextSpan(
              text: 'login_here'.tr(),
              style: TextStyle(
                color: secondaryColor,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool isPassword = false,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(8),
        CustomTextFieldCard(
          hintText: hint,
          controller: controller,
          isPassword: isPassword,
          keyboardType: keyboardType,
          prefixIcon: icon != null
              ? Icon(icon, color: primaryColor.withOpacity(0.6))
              : null,
        ),
      ],
    );
  }

  Widget _buildImagePicker({
    required File? image,
    required VoidCallback onTap,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  image,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
            else
              Icon(
                Icons.cloud_upload_outlined,
                size: 40,
                color: primaryColor.withOpacity(0.5),
              ),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _validateAndRegister() {
    _registerModel
      ..name = _nameController.text.trim()
      ..role = widget.role
      ..email = _emailController.text.trim()
      ..password = _passwordController.text.trim()
      ..profileImage = _selectedImage
      ..collegeId = _selectedCollegeIdImage;

    if (_registerModel.name!.isEmpty ||
        _registerModel.email!.isEmpty ||
        _registerModel.password!.isEmpty) {
      _showErrorSnackbar('fill_required_fields'.tr());
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_registerModel.email!)) {
      _showErrorSnackbar('invalid_email'.tr());
      return;
    }

    if (_registerModel.password!.length < 8) {
      _showErrorSnackbar('password_too_short'.tr());
      return;
    }

    if (_registerModel.collegeId == null) {
      _showErrorSnackbar('id_proof_required'.tr());
      return;
    }

    if (_registerModel.profileImage == null) {
      _showErrorSnackbar('image_required'.tr());
      return;
    }

    BlocProvider.of<RegisterCubit>(context).signup(_registerModel, context);
  }
}
