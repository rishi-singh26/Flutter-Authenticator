import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class FS {
  static Future<ReadFileResp> readFileContents(File file) async {
    try {
      // Read the file
      final contents = await file.readAsString();
      return ReadFileResp(contents: contents, status: true);
    } catch (e) {
      // If encountering an error, return 0
      return ReadFileResp(contents: '', status: false);
    }
  }

  static Future<WriteFileResp> writeFileContents(File file, String text) async {
    // Write the file
    try {
      File writtenFile = await file.writeAsString(text);
      return WriteFileResp(file: writtenFile, status: true, message: 'Success');
    } catch (e) {
      return WriteFileResp(file: file, status: false, message: e.toString());
    }
  }

  static Future<PickFileResp> pickSingleFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      // print(result.toString());
      if (result != null) {
        File file = File(result.files.single.path ?? '');
        return PickFileResp(file: file, status: true);
      } else {
        return PickFileResp(file: File('path'), status: false);
      }
    } catch (e) {
      return PickFileResp(file: File('path'), status: false);
    }
  }

  static Future<PickDirResp> pickDirectory() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        // User canceled the picker
        return PickDirResp(path: '', status: false);
      }
      return PickDirResp(path: selectedDirectory, status: true);
    } catch (e) {
      return PickDirResp(path: e.toString(), status: false);
    }
  }
}

class ReadFileResp {
  final String contents;
  final bool status;
  ReadFileResp({required this.contents, required this.status});
}

class WriteFileResp {
  final File file;
  final bool status;
  final String message;
  WriteFileResp({
    required this.file,
    required this.status,
    required this.message,
  });
}

class PickFileResp {
  final bool status;
  final File file;
  PickFileResp({required this.file, required this.status});
}

class PickDirResp {
  final bool status;
  final String path;
  PickDirResp({required this.path, required this.status});
}
