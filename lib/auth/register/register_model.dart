import 'dart:io';

import 'package:flutter/material.dart';

class RegisterModel extends ChangeNotifier {
  dynamic email;
  dynamic address;
  dynamic password;
  dynamic name;
  dynamic role;
  File? profileImage;
  dynamic password_confirmation;
  File? collegeId;
}
