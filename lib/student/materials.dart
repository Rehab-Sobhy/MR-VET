import 'dart:io';

import 'package:education_app/constants/apiKey.dart';
import 'package:education_app/instructor/cubit_of_Materials.dart';
import 'package:education_app/instructor/materialstates.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:education_app/pdfScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class StudentMaterialsScreen extends StatelessWidget {
  final String courseId;
  const StudentMaterialsScreen({super.key, required this.courseId});

  Future<String> _getDownloadPath(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$fileName';
  }

  Future<bool> _fileExists(String fileName) async {
    try {
      final path = await _getDownloadPath(fileName);
      return File(path).exists();
    } catch (e) {
      return false;
    }
  }

  IconData _getFileIcon(String extension) {
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String extension) {
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'zip':
      case 'rar':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MaterialsCubit()..fetchMaterials(courseId),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: BackButton(),
          backgroundColor: Colors.white,
          title: Text('materials.title'.tr()),
          centerTitle: true,
          elevation: 0,
        ),
        body: BlocConsumer<MaterialsCubit, MaterialsState>(
          listener: (context, state) {
            if (state is DeleteMaterialSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('materials.delete_success'.tr()),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<MaterialsCubit>().fetchMaterials(courseId);
            } else if (state is DeleteMaterialfiled) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('materials.delete_failed'.tr()),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is MaterialsLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is MaterialsFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    SizedBox(height: 16),
                    Text(state.error),
                  ],
                ),
              );
            } else if (state is MaterialsSuccess) {
              final materials = state.materials;
              if (materials.isEmpty) {
                return Center(child: Text('materials.no_materials'.tr()));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: materials.length,
                separatorBuilder: (_, __) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = materials[index];
                  final fileUrl = "$baseUrlKey${item['fileUrl']}";
                  final fileName = Uri.parse(fileUrl).pathSegments.last;
                  final extension = fileName.contains('.')
                      ? fileName.split('.').last.toLowerCase()
                      : 'unknown';

                  return Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      leading: Icon(
                        _getFileIcon(extension),
                        color: _getFileColor(extension),
                        size: 30,
                      ),
                      title: Text(fileName,
                          style: TextStyle(overflow: TextOverflow.ellipsis)),
                      subtitle: state.downloadProgress.containsKey(fileUrl)
                          ? LinearPercentIndicator(
                              lineHeight: 4,
                              percent: state.downloadProgress[fileUrl]!,
                              backgroundColor: Colors.grey.shade200,
                              progressColor: Colors.blue,
                            )
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FutureBuilder<bool>(
                            future: _fileExists(fileName),
                            builder: (context, snapshot) {
                              final fileExists = snapshot.data ?? false;

                              return IconButton(
                                icon: Icon(
                                  fileExists
                                      ? Icons.open_in_new
                                      : Icons.download,
                                  color:
                                      fileExists ? Colors.green : Colors.blue,
                                ),
                                onPressed: () async {
                                  final path = await _getDownloadPath(fileName);

                                  if (fileExists) {
                                    // File already exists, just open it
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PDFViewerScreen(
                                          filePath: path,
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Download the file
                                    await context
                                        .read<MaterialsCubit>()
                                        .downloadFile(fileUrl, path,
                                            context: context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'materials.download_success'.tr()),
                                        backgroundColor: Colors.green,
                                      ),
                                    );

                                    // Open the downloaded file
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PDFViewerScreen(
                                          filePath: path,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
