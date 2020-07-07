import 'dart:io';

import 'package:delivery_admin/utils/log_util.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class ParseFileService {


  Future<void> save(File file) async {
    var parseFile = ParseFile(file);
    await parseFile.save().then((value) {
      Log.d(value.result);
    }).catchError((error) {
      Log.d(error);
    });
  }

  Future<void> delete() async {
    var parseFile = ParseFile(null);
    String name = "1b97b764960ce06410402c0691430421_image_picker1711217905807541735_compressed4223552246770534032.jpg";
    String url = "https://2r1bmfb3qhj3zsxrstuh78sq0i4x0b.files-sashido.cloud/1b97b764960ce06410402c0691430421_image_picker1711217905807541735_compressed4223552246770534032.jpg";

    parseFile.delete(id: name).then((value) {
      Log.d(value);
    }).catchError((error) {
      Log.e(error);
    });

  }

}