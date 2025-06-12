import 'package:education_app/constants/apiKey.dart';
import 'package:education_app/constants/colors.dart';
import 'package:education_app/instructor/cubit_of_Materials.dart';
import 'package:education_app/instructor/materialstates.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class StudentMaterialsScreen extends StatelessWidget {
  final String courseId;
  const StudentMaterialsScreen({super.key, required this.courseId});

  Future<String> _getDownloadPath(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$fileName';
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
          title: Text('materials.title'.tr()),
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 88, 112, 243),
                  const Color.fromARGB(255, 133, 0, 133)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade50,
                Colors.white,
              ],
            ),
          ),
          child: BlocConsumer<MaterialsCubit, MaterialsState>(
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      SizedBox(height: 16),
                      Text('materials.loading'.tr(),
                          style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                );
              } else if (state is MaterialsFailure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text(
                        state.error,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => context
                            .read<MaterialsCubit>()
                            .fetchMaterials(courseId),
                        child: Text('materials.retry'.tr(),
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              } else if (state is MaterialsSuccess) {
                final materials = state.materials;
                if (materials.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open,
                            size: 64, color: Colors.grey.shade400),
                        SizedBox(height: 16),
                        Text('materials.no_materials'.tr(),
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: materials.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = materials[index];
                    final materialId = item['_id'];
                    final fileUrl = "$baseUrlKey/${item['filePath']}";
                    final fileName = Uri.parse(fileUrl).pathSegments.last;
                    final fileExtension = fileName.contains('.')
                        ? fileName.split('.').last.toLowerCase()
                        : 'unknown';
                    final fileSize = item['fileSize'] != null
                        ? "${(item['fileSize'] / (1024 * 1024)).toStringAsFixed(2)} MB"
                        : "materials.unknown_size".tr();

                    return Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  _getFileColor(fileExtension).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getFileIcon(fileExtension),
                              color: _getFileColor(fileExtension),
                              size: 28,
                            ),
                          ),
                          title: Text(
                            fileName,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                fileSize,
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12),
                              ),
                              if (state.downloadProgress.containsKey(fileUrl))
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: LinearPercentIndicator(
                                    lineHeight: 4,
                                    percent: state.downloadProgress[fileUrl]!,
                                    backgroundColor: Colors.grey.shade200,
                                    progressColor: Colors.blue,
                                    animation: true,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.download, color: Colors.blue),
                                onPressed: () async {
                                  final path = await _getDownloadPath(fileName);
                                  await context
                                      .read<MaterialsCubit>()
                                      .downloadFile(fileUrl, path,
                                          context: context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'materials.download_success'.tr()),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  OpenFile.open(path);
                                },
                              ),
                            ],
                          ),
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
      ),
    );
  }
}
