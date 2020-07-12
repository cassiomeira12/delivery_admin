import 'dart:io';

import 'package:delivery_admin/services/parse/parse_file_service.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class FilePresenter {

  var service = ParseFileService();

  Future<String> save(File file) {
    return service.save(file);
  }

  Future<bool> delete({File file, String url}) {
    return service.delete(file, url);
  }

}