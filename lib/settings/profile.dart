import 'dart:io';
import 'package:education_app/auth/services.dart';
import 'package:education_app/constants/apiKey.dart';
import 'package:education_app/settings/cubitofUser.dart';
import 'package:education_app/settings/statesofuser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileCubit _profileCubit;
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _profileCubit = context.read<ProfileCubit>();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    await _profileCubit.fetchUserProfile();
    setState(() => _isLoading = false);
  }

  Future<void> _pickAndUpdateImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Reduced quality for better performance
        maxWidth: 800,
      );

      if (pickedFile != null && mounted) {
        setState(() => _selectedImage = File(pickedFile.path));
        await _profileCubit.updateProfileImage(widget.userId, _selectedImage!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update image: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _profileCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = '$baseUrlKey';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (_isLoading ||
              state is ProfileInitial ||
              state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const Gap(20),
                  ElevatedButton(
                    onPressed: _loadUserProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = (state is ProfileLoaded)
              ? state.userData['user']
              : (state as ProfileUpdated).updatedUser['user'];

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header Section
                _buildProfileHeader(context, theme, baseUrl, user),
                const Gap(60),
                // User Information Section
                _buildUserInfoSection(context, theme, user),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, ThemeData theme, String baseUrl, dynamic user) {
    return GestureDetector(
      onTap: _pickAndUpdateImage,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[700]!, Colors.indigo[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: MediaQuery.of(context).size.width / 2 - 60,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          cacheWidth: 240, // Optimized for performance
                        )
                      : CachedNetworkImage(
                          imageUrl: '$baseUrl/${user['profileImage']}',
                          fit: BoxFit.cover,
                          memCacheWidth: 240, // Reduced cache size
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Iconsax.user, size: 40),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Iconsax.user, size: 40),
                            ),
                          ),
                        ),
                ),
              ),
            ),
            Positioned(
              bottom: -5,
              left: MediaQuery.of(context).size.width / 2 + 28,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.primaryColor,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child:
                    const Icon(Iconsax.camera, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(
      BuildContext context, ThemeData theme, dynamic user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            user['name'] ?? 'No Name ',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.sms, size: 16),
              const Gap(8),
              Text(
                user['email'] ?? 'No Email Provided',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const Gap(20),
          Divider(color: Colors.grey[300]),
          _buildDetailItem(
            context: context,
            icon: Iconsax.calendar,
            title: 'Joined Date',
            value: user['createdAt'] != null
                ? _formatDate(user['createdAt'])
                : 'Unknown',
          ),
          _buildDetailItem(
            context: context,
            icon: Iconsax.book,
            title: 'Courses Enrolled',
            value: user['enrolledCourses']?.length.toString() ?? '0',
          ),
          _buildDetailItem(
            context: context,
            icon: Iconsax.award,
            title: 'Achievements',
            value: user['achievements']?.length.toString() ?? '0',
          ),
          _buildDetailItem(
            context: context,
            icon: Iconsax.info_circle,
            title: 'ID',
            value: user['_id'] ?? 'unknown',
          ),
          const Gap(20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _navigateToEditProfile(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Edit Profile'),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {}
  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    required BuildContext context, // Need context for SnackBar
  }) {
    bool isCopied = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[600]),
              const Gap(16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Gap(4),
                  Tooltip(
                    message: 'Tap to copy',
                    child: GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: value));
                        setState(() => isCopied = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Copied "$value" to clipboard'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        Future.delayed(Duration(seconds: 2), () {
                          if (mounted) setState(() => isCopied = false);
                        });
                      },
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isCopied ? Colors.blue : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
