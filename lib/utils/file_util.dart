import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class FileUtil {

  static Future<File> createFileFromBytes(String newFileNamePath, Uint8List bytes) async {
    final docDirectory = await getApplicationDocumentsDirectory();
    final path = docDirectory.path + newFileNamePath;
    final f = await File(path).writeAsBytes(bytes);
    return f;
  }

  static Future<String> getAppVideoFilesPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}';
    // return '${directory.path}/VideoWillFiles/';
  }
}