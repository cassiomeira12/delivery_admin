import 'dart:io';
import '../services/parse/parse_file_service.dart';

class FilePresenter {

  var service = ParseFileService();

  Future<String> save(File file) {
    return service.save(file);
  }

  Future<bool> delete({File file, String url}) {
    return service.delete(file, url);
  }

}