import 'dart:io';

import 'package:delivery_admin/services/parse/parse_file_service.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class FilePresenter {

  var service = ParseFileService();

  void save(File file) {
    service.save(file);
  }

  void delete() {
    service.delete();
  }

}