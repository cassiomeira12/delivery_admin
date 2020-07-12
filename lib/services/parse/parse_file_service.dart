import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../services/parse/parse_init.dart';
import '../../utils/log_util.dart';
import '../../strings.dart';

class ParseFileService {

  Future<String> save(File file) async {
    var parseFile = ParseFile(file);
    return await parseFile.save().then((value) {
      return value.result.url;
    }).catchError((error) {
      Log.e(error);
      switch (error.code) {
        case -1:
          throw Exception(ERROR_NETWORK);
          break;
        default:
          throw Exception(error.message);
      }
    });
  }

  Future<bool> delete(File file, String url) async {
    String name = url.toString().split('/').last;
    var parseFile = ParseFile(file);
    parseFile.name = name;
    parseFile.url = url;
    Dio dio = Dio(BaseOptions(
      baseUrl: "https://pg-app-umn8hkxj0yfqr3tue4vyhpzr5j1zst.scalabl.cloud/1/files/$name",
      connectTimeout: 5000,
      headers: {
        'X-Parse-Master-Key': ParseInit.masterKey,
        'X-Parse-Application-Id': ParseInit.appId,
        'X-Parse-REST-API-Key': "6O4o1phUq74aalaJ75qqRrz3kbQgNWQORBg5kR7R",
      }
    ));
    print("https://pg-app-umn8hkxj0yfqr3tue4vyhpzr5j1zst.scalabl.cloud/1/files/$name");
    try {
      Response response = await dio.delete("");
      Log.e(response.statusCode);
      if (response == null || response.statusCode != 200) {
        return false;
      }
      return true;
    } catch (error) {
      Log.e(error.toString());
      return false;
    }
  }

}