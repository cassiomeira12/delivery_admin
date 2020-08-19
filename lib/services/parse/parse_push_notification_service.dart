import 'package:parse_server_sdk/parse_server_sdk.dart';
import '../../models/notification/push_notification.dart';
import '../../contracts/notification/push_notification_contract.dart';
import '../../services/parse/base_parse_service.dart';
import '../../strings.dart';

class ParsePushNotificationService extends PushNotificationContractService {

  BaseParseService service = BaseParseService("PushNotification");

  @override
  Future<PushNotification> create(PushNotification item) {
    return service.create(item).then((response) {
      PushNotification temp = PushNotification();
      temp.updateData(item);
      temp.id = response["objectId"];
      temp.objectId = response["objectId"];
      temp.createdAt = DateTime.parse(response["createdAt"]).toLocal();
      return response == null ? null : temp;
    }).catchError((error) {
      switch (error.code) {
        case -1:
          throw Exception(ERROR_NETWORK);
          break;
        default:
          throw Exception(error.message);
      }
    });
  }

  @override
  Future<PushNotification> read(PushNotification item) {
    return service.read(item).then((response) {
      return response == null ? null : PushNotification.fromMap(response);
    }).catchError((error) {
      switch (error.code) {
        case -1:
          throw Exception(ERROR_NETWORK);
          break;
        default:
          throw Exception(error.message);
      }
    });
  }

  @override
  Future<PushNotification> update(PushNotification item) {
    return service.update(item).then((response) {
      PushNotification temp = PushNotification();
      temp.updateData(item);
      temp.updatedAt = DateTime.parse(response["updatedAt"]).toLocal();
      return response == null ? null : temp;
    }).catchError((error) {
      switch (error.code) {
        case -1:
          throw Exception(ERROR_NETWORK);
          break;
        default:
          throw Exception(error.message);
      }
    });
  }

  @override
  Future<PushNotification> delete(PushNotification item) {
    return service.delete(item).then((response) {
      return response == null ? null : PushNotification.fromMap(response);
    }).catchError((error) {
      switch (error.code) {
        case -1:
          throw Exception(ERROR_NETWORK);
          break;
        default:
          throw Exception(error.message);
      }
    });
  }

  @override
  Future<List<PushNotification>> findBy(String field, value) async {
    var query = QueryBuilder<ParseObject>(service.getObject())
      ..whereEqualTo(field, value)
      ..includeObject(["senderCompany", "senderUser", "destinationUser"]);

    return await query.query().then((value) async {
      if (value.success) {
        if (value.result == null) {
          return List<PushNotification>();
        } else {
          List<ParseObject> listObj = value.result;

          return listObj.map<PushNotification>((obj) {
            var root = obj.toJson();
            var senderCompany = obj.get("senderCompany");
            var senderUser = obj.get("senderUser");
            var destinationUser = obj.get("destinationUser");

            if (senderCompany != null) {
              var json = senderCompany.toJson();
              root["senderCompany"] = json;
            }

            if (senderUser != null) {
              var json = senderUser.toJson();
              root["senderUser"] = json;
            }

            if (destinationUser != null) {
              var json = destinationUser.toJson();
              root["destinationUser"] = json;
            }

            return PushNotification.fromMap(root);
          }).toList();
        }
      } else {
        switch (value.error.code) {
          case -1:
            throw Exception(ERROR_NETWORK);
            break;
          default:
            throw Exception(value.error.message);
        }
      }
    }).catchError((error) {
      switch (error.code) {
        case -1:
          throw Exception(ERROR_NETWORK);
          break;
        default:
          throw Exception(error.message);
      }
    });
  }

  @override
  Future<List<PushNotification>> list() async {
    var query = QueryBuilder<ParseObject>(service.getObject())
      ..includeObject(["senderCompany", "senderUser", "destinationUser"]);

    return await query.query().then((value) async {
      if (value.success) {
        if (value.result == null) {
          return List<PushNotification>();
        } else {
          List<ParseObject> listObj = value.result;

          return listObj.map<PushNotification>((obj) {
            var root = obj.toJson();
            var senderCompany = obj.get("senderCompany");
            var senderUser = obj.get("senderUser");
            var destinationUser = obj.get("destinationUser");

            if (senderCompany != null) {
              var json = senderCompany.toJson();
              root["senderCompany"] = json;
            }

            if (senderUser != null) {
              var json = senderUser.toJson();
              root["senderUser"] = json;
            }

            if (destinationUser != null) {
              var json = destinationUser.toJson();
              root["destinationUser"] = json;
            }

            return PushNotification.fromMap(root);
          }).toList();
        }
      } else {
        switch (value.error.code) {
          case -1:
            throw Exception(ERROR_NETWORK);
            break;
          default:
            throw Exception(value.error.message);
        }
      }
    }).catchError((error) {
      switch (error.code) {
        case -1:
          throw Exception(ERROR_NETWORK);
          break;
        default:
          throw Exception(error.message);
      }
    });
  }

}