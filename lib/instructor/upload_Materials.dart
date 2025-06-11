import 'dart:io';
import 'dart:math';
import 'package:education_app/instructor/cubit_of_Materials.dart';
import 'package:education_app/instructor/materialstates.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:path/path.dart' as p;

import 'package:flutter_bloc/flutter_bloc.dart';

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
      _showSnackBar('Error picking file: $e');
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
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MaterialsCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Upload Course Material'),
          centerTitle: true,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocConsumer<MaterialsCubit, MaterialsState>(
            listener: (context, state) {
              if (state is FileUploadSuccess) {
                _showSnackBar('File uploaded successfully!');
                Navigator.pop(context, true);
              } else if (state is FileUploadFailure) {
                _showSnackBar('Upload failed: ${state.error}');
              }
            },
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Select File ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Gap(10),

                  const Gap(30),

                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: _pickFile,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_upload,
                              size: 60,
                              color: Colors.blue[300],
                            ),
                            const Gap(15),
                            Text(
                              _selectedFile == null
                                  ? 'Tap to select a file'
                                  : '$_fileName ($_fileSize)',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_selectedFile != null) ...[
                              const Gap(10),
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 30,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Upload button with progress
                  if (state is FileUploadLoading) ...[
                    LinearProgressIndicator(
                      value: state.progress,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blue,
                      minHeight: 10,
                    ),
                    const Gap(10),
                    Text(
                      'Uploading: ${(state.progress * 100).toStringAsFixed(1)}%',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.blue),
                    ),
                    const Gap(20),
                  ] else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        context.read<MaterialsCubit>().uploadPdfFile(
                              file: _selectedFile!,
                              courseId: widget.courseId,
                            );
                      },
                      child: const Text(
                        'Upload File',
                        style: TextStyle(fontSize: 16),
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
