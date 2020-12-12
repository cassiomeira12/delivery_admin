import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class ParseInit {
//  static String appId = "123456";
//  static String serverUrl = "http://10.0.0.106:1337/parse";
//  static String masterKey = "123456";

  static String appId = "vP5eyem24FCRjqbzvfTx7KKgRN7WMk7RGObRBQfk";
  static String serverUrl =
      "https://pg-app-umn8hkxj0yfqr3tue4vyhpzr5j1zst.scalabl.cloud/1/";
  static String clientKey = "hX0GOokmRVb1nQg4gjlM0n1RpkTk7NbWRgoQgBNH";

  static Parse parse;

  static Future<bool> init() async {
    parse = await Parse().initialize(
      appId,
      serverUrl,
      liveQueryUrl: serverUrl,
      //masterKey: masterKey,
      clientKey: clientKey,
      autoSendSessionId: true,
      debug: kDebugMode,
    );
    return (await parse.healthCheck()).success;
  }
}
