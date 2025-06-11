import 'package:education_app/constants/apiKey.dart';
import 'package:education_app/constants/colors.dart';
import 'package:education_app/instructor/cubit_of_Materials.dart';
import 'package:education_app/instructor/materialstates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class MaterialsScreen extends StatelessWidget {
  final String courseId;
  const MaterialsScreen({super.key, required this.courseId});

  Future<String> _getDownloadPath(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$fileName';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MaterialsCubit()..fetchMaterials(courseId),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('المواد التعليمية'),
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
                  const SnackBar(
                    content: Text('تم حذف الملف بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<MaterialsCubit>().fetchMaterials(courseId);
              } else if (state is DeleteMaterialfiled) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('فشل في حذف الملف'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is MaterialsLoading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      SizedBox(height: 16),
                      Text('جاري تحميل المواد...',
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
                        child: const Text('إعادة المحاولة',
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
                        Text('لا توجد مواد متاحة حالياً',
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
                    final materialId =
                        item['_id']; // Assuming your material has an _id field
                    final fileUrl = "$baseUrlKey/${item['filePath']}";
                    final fileName = Uri.parse(fileUrl).pathSegments.last;
                    final fileExtension = fileName.contains('.')
                        ? fileName.split('.').last.toLowerCase()
                        : 'unknown';
                    final fileSize = item['fileSize'] != null
                        ? "${(item['fileSize'] / (1024 * 1024)).toStringAsFixed(2)} MB"
                        : "حجم غير معروف";

                    IconData fileIcon;
                    Color fileColor;

                    switch (fileExtension) {
                      case 'pdf':
                        fileIcon = Icons.picture_as_pdf;
                        fileColor = Colors.red;
                        break;
                      case 'doc':
                      case 'docx':
                        fileIcon = Icons.description;
                        fileColor = Colors.blue;
                        break;
                      case 'ppt':
                      case 'pptx':
                        fileIcon = Icons.slideshow;
                        fileColor = Colors.orange;
                        break;
                      case 'xls':
                      case 'xlsx':
                        fileIcon = Icons.table_chart;
                        fileColor = Colors.green;
                        break;
                      case 'zip':
                      case 'rar':
                        fileIcon = Icons.archive;
                        fileColor = Colors.purple;
                        break;
                      default:
                        fileIcon = Icons.insert_drive_file;
                        fileColor = Colors.grey;
                    }

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
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: fileColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(fileIcon, color: fileColor, size: 24),
                          ),
                          title: Text(
                            fileName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.download,
                                      color: Colors.blue, size: 20),
                                ),
                                onPressed: () async {
                                  final path = await _getDownloadPath(fileName);
                                  await context
                                      .read<MaterialsCubit>()
                                      .downloadFile(fileUrl, path,
                                          context: context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          const Text('تم تحميل الملف بنجاح'),
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
                              IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.delete,
                                      color: Colors.red, size: 20),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('حذف الملف'),
                                      content: const Text(
                                          'هل أنت متأكد أنك تريد حذف هذا الملف؟'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('إلغاء'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            context
                                                .read<MaterialsCubit>()
                                                .DeleteMaterial(
                                                    courseId: courseId,
                                                    materialId: materialId);
                                          },
                                          child: const Text('حذف',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
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
