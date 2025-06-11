import 'package:easy_localization/easy_localization.dart';
import 'package:education_app/auth/login/login_screen.dart';
import 'package:education_app/auth/services.dart';
import 'package:education_app/constants/colors.dart';
import 'package:education_app/settings/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthServiceClass _authService = AuthServiceClass();
  final bool isLoggedIn = true;

  @override
  Widget build(BuildContext context) {
    timeDilation = 2.0;
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text("Settings",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.black87)),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: Colors.black87),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 30),
          _buildMainSettingsCard(context),
          SizedBox(height: 20),
          _buildSecondaryOptionsCard(context),
        ],
      ),
    );
  }

  Widget _buildMainSettingsCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      shadowColor: primaryColor.withOpacity(0.2),
      child: Column(
        children: [
          _buildAnimatedListTile(
            context,
            icon: Icons.language,
            title: "Language",
            subtitle:
                context.locale.languageCode == 'ar' ? "Arabic" : "English",
            iconColor: Colors.blue,
            onTap: () => _showLanguageDialog(context),
          ),
          _buildDivider(),
          _buildAnimatedListTile(
            context,
            icon: Icons.person_2_outlined,
            title: "Profile",
            subtitle: "System Default",
            iconColor: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(userId: ''),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildAnimatedListTile(
            context,
            icon: Icons.notifications,
            title: "Notifications",
            subtitle: "Enabled",
            iconColor: Colors.orange,
            onTap: () => _navigateToNotifications(),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryOptionsCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _buildAnimatedListTile(
            context,
            icon: Icons.info,
            title: "About",
            iconColor: Colors.blueGrey,
            onTap: () => _navigateToAbout(),
          ),
          _buildDivider(),
          _buildAnimatedListTile(
            context,
            icon: isLoggedIn ? Icons.logout : Icons.login,
            title: isLoggedIn ? "Logout" : "Login",
            iconColor: isLoggedIn ? Colors.red : Colors.green,
            onTap: () => isLoggedIn ? _logout(context) : _login(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      splashColor: iconColor.withOpacity(0.1),
      highlightColor: iconColor.withOpacity(0.05),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  if (subtitle != null)
                    Text(subtitle,
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Divider(height: 1, thickness: 0.5),
    );
  }

  void _navigateToNotifications() {
    print("Navigate to Notifications Settings");
  }

  void _navigateToAbout() {
    print("Navigate to About Screen");
  }

  void _login(BuildContext context) {
    print("Login pressed");
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Confirm Logout",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to sign out from your account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("CANCEL", style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleLogout();
            },
            child: Text("LOGOUT",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.logout();
      if (!mounted) return;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed')),
      );
    }
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text("Select Language",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildLanguageOption(ctx, "English", "en", true),
            _buildLanguageOption(ctx, "Arabic", "ar", false),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /// 🔽 ضعها هنا مثلاً أسفل دالة _showLanguageDialog
  Widget _buildLanguageOption(
    BuildContext context,
    String language,
    String languageCode,
    bool isEnglish,
  ) {
    return ListTile(
      title: Text(language),
      onTap: () async {
        final newLocale =
            isEnglish ? const Locale('en', 'US') : const Locale('ar', 'EG');

        // تغيير اللغة داخل EasyLocalization
        await context.setLocale(newLocale);

        // حفظ اللغة في SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_language', languageCode);

        Navigator.of(context).pop(); // غلق الـ Dialog
      },
    );
  }
}
