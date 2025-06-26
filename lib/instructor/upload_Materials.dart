import 'dart:io';
import 'dart:math';
import 'package:education_app/instructor/cubit_of_Materials.dart';
import 'package:education_app/instructor/materialstates.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class FileUploadScreen extends StatefulWidget {
  final String courseId;

  const FileUploadScreen({super.key, required this.courseId});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  File? _selectedFile;
  String _fileName = '';
  String _fileSize = '';
  String? _selectedFileType;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && mounted) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = p.basename(_selectedFile!.path);
          _fileSize = _formatFileSize(result.files.single.size);
        });
      }
    } catch (e) {
      _showSnackBar('file_upload.error_picking_file'.tr(args: [e.toString()]));
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MaterialsCubit(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'file_upload.title'.tr(),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[800]!, Colors.blue[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocConsumer<MaterialsCubit, MaterialsState>(
            listener: (context, state) {
              if (state is FileUploadSuccess) {
                _showSnackBar('file_upload.success'.tr());
                Navigator.pop(context, true);
              } else if (state is FileUploadFailure) {
                _showSnackBar('file_upload.failure'.tr(args: [state.error]));
              }
            },
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'file_upload.add_material'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  const Gap(5),

                  const Gap(30),

                  // Animated file upload card
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: _selectedFile == null ? 250 : 280,
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      shadowColor: Colors.blue.withOpacity(0.3),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _pickFile,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: _selectedFile == null
                                ? LinearGradient(
                                    colors: [
                                      Colors.blue[50]!,
                                      Colors.lightBlue[100]!,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.green[50]!,
                                      Colors.lightGreen[100]!,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(25),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.7),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Icon(
                                      _selectedFile == null
                                          ? Icons.cloud_upload_outlined
                                          : Icons.file_present_rounded,
                                      size: 60,
                                      color: _selectedFile == null
                                          ? Colors.blue[400]
                                          : Colors.green[600],
                                    ),
                                    if (_selectedFile != null)
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check_circle,
                                            color: Colors.green[600],
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const Gap(20),
                                Text(
                                  _selectedFile == null
                                      ? 'file_upload.tap_to_select'.tr()
                                      : 'file_upload.selected_file'.tr(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueGrey[800],
                                  ),
                                ),
                                if (_selectedFile != null) ...[
                                  const Gap(10),
                                  Text(
                                    _fileName,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[700],
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _fileSize,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Upload button with progress
                  if (state is FileUploadLoading) ...[
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: state.progress,
                          backgroundColor: Colors.grey[200],
                          color: Colors.blue,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const Gap(15),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                value: state.progress,
                                strokeWidth: 6,
                                backgroundColor: Colors.grey[200],
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              '${(state.progress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const Gap(10),
                        Text(
                          'file_upload.uploading'.tr(),
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Gap(20),
                  ] else
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue[600]!,
                            Colors.blue[400]!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: _selectedFile == null
                            ? null
                            : () {
                                context.read<MaterialsCubit>().uploadPdfFile(
                                      file: _selectedFile!,
                                      courseId: widget.courseId,
                                    );
                              },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.upload_rounded,
                              color: Colors.white,
                            ),
                            const Gap(10),
                            Text(
                              'file_upload.upload_button'.tr(),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
