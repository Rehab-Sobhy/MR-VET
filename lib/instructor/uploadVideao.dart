import 'dart:io';
import 'package:education_app/constants/colors.dart';
import 'package:education_app/instructor/video_cubit.dart';
import 'package:education_app/instructor/video_dtates.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

class VideoUploadScreen extends StatefulWidget {
  final String id;
  const VideoUploadScreen({required this.id, Key? key}) : super(key: key);

  @override
  _VideoUploadScreenState createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  final _titleController = TextEditingController();
  File? _videoFile;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideoUploadCubit(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text('video_upload.title'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),
        body: BlocConsumer<VideoUploadCubit, VideoUploadState>(
          listener: (context, state) {
            if (state is VideoUploadSuccess) {
              setState(() => _isUploading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('video_upload.success_message'.tr()),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else if (state is VideoUploadError) {
              setState(() => _isUploading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const SizedBox(height: 20),
                  Text(
                    'video_upload.header_title'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: primaryColor,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'video_upload.header_subtitle'.tr(),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 30),

                  // Video Title Input
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'video_upload.title_label'.tr(),
                      prefixIcon: const Icon(Iconsax.video),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Video Upload Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.video,
                          allowMultiple: false,
                        );
                        if (result != null &&
                            result.files.single.path != null) {
                          setState(() {
                            _videoFile = File(result.files.single.path!);
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              _videoFile == null
                                  ? Iconsax.video_add
                                  : Iconsax.video_play,
                              size: 50,
                              color: primaryColor,
                            ),
                            const SizedBox(height: 15),
                            Text(
                              _videoFile == null
                                  ? 'video_upload.select_video'.tr()
                                  : 'video_upload.video_selected'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _videoFile == null
                                  ? 'video_upload.tap_to_browse'.tr()
                                  : _videoFile!.path.split('/').last,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_videoFile != null) ...[
                              const SizedBox(height: 15),
                              Chip(
                                label:
                                    Text('video_upload.ready_to_upload'.tr()),
                                backgroundColor: Colors.green[50],
                                labelStyle:
                                    const TextStyle(color: Colors.green),
                                avatar: const Icon(Icons.check,
                                    size: 16, color: Colors.green),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Upload Button
                  ElevatedButton(
                    onPressed: _isUploading
                        ? null
                        : () {
                            if (_titleController.text.isEmpty ||
                                _videoFile == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('video_upload.fill_all_fields'.tr()),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              return;
                            }
                            setState(() => _isUploading = true);
                            context.read<VideoUploadCubit>().uploadVideo(
                                  title: _titleController.text,
                                  courseId: widget.id,
                                  videoFile: _videoFile!,
                                );
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'video_upload.upload_button'.tr(),
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
