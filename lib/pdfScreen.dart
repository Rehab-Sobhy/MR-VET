import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for orientation control
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

class PDFViewerScreen extends StatelessWidget {
  final String filePath;
  const PDFViewerScreen({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    // Lock orientation to portrait when building the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      appBar: AppBar(title: Text('عرض الملف')),
      body: FutureBuilder<bool>(
        future: _checkFileExists(filePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.data!) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text('materials.file_not_found'.tr()),
                ],
              ),
            );
          } else {
            return PDFView(
              filePath: filePath,
              enableSwipe: true,
              swipeHorizontal: false, // Changed to false for vertical swiping
              autoSpacing: false,
              pageFling: false,
              onError: (error) {
                print('PDFView error: $error');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('materials.pdf_view_error'.tr()),
                      backgroundColor: Colors.red),
                );
              },
              onRender: (pages) {
                print('PDF rendered with $pages pages');
              },
            );
          }
        },
      ),
    );
  }

  Future<bool> _checkFileExists(String path) async {
    try {
      final file = File(path);
      final exists = await file.exists();
      print('File exists: $exists at $path');
      return exists;
    } catch (e) {
      print('File check error: $e');
      return false;
    }
  }
}














// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'dart:io';

// class PDFViewerScreen extends StatefulWidget {
//   final String filePath;
//   const PDFViewerScreen({super.key, required this.filePath});

//   @override
//   State<PDFViewerScreen> createState() => _PDFViewerScreenState();
// }

// class _PDFViewerScreenState extends State<PDFViewerScreen> {
//   @override
//   void initState() {
//     super.initState();

//     // Lock orientation
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);

//     // Prevent screenshots on Android
//     _enableSecureFlag();
//   }

//   @override
//   void dispose() {
//     // Restore ability to take screenshots
//     _disableSecureFlag();

//     // Reset orientation to default
//     SystemChrome.setPreferredOrientations(DeviceOrientation.values);

//     super.dispose();
//   }

//   Future<void> _enableSecureFlag() async {
//     const platform = MethodChannel('secure_channel');
//     try {
//       await platform.invokeMethod('enableSecure');
//     } catch (e) {
//       print('Error enabling FLAG_SECURE: $e');
//     }
//   }

//   Future<void> _disableSecureFlag() async {
//     const platform = MethodChannel('secure_channel');
//     try {
//       await platform.invokeMethod('disableSecure');
//     } catch (e) {
//       print('Error disabling FLAG_SECURE: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('عرض الملف')),
//       body: FutureBuilder<bool>(
//         future: _checkFileExists(widget.filePath),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError || !snapshot.data!) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.error_outline, color: Colors.red, size: 48),
//                   SizedBox(height: 16),
//                   Text('materials.file_not_found'.tr()),
//                 ],
//               ),
//             );
//           } else {
//             return PDFView(
//               filePath: widget.filePath,
//               enableSwipe: true,
//               swipeHorizontal: false,
//               autoSpacing: false,
//               pageFling: false,
//               onError: (error) {
//                 print('PDFView error: $error');
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                       content: Text('materials.pdf_view_error'.tr()),
//                       backgroundColor: Colors.red),
//                 );
//               },
//               onRender: (pages) {
//                 print('PDF rendered with $pages pages');

//               },
//             );
//           }
//         },
//       ),
//     );
//   }

//   Future<bool> _checkFileExists(String path) async {
//     try {
//       final file = File(path);
//       final exists = await file.exists();
//       print('File exists: $exists at $path');
//       return exists;
//     } catch (e) {
//       print('File check error: $e');
//       return false;
//     }
//   }
// }
