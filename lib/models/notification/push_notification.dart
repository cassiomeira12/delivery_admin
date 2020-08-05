import '../../models/company/company.dart';
import '../base_model.dart';
import '../base_user.dart';

class PushNotification extends BaseModel<PushNotification> {
  String title, message, topic;
  Company senderCompany;
  BaseUser senderUser, destinationUser;
  bool validated;

  PushNotification() : super('PushNotification');

  PushNotification.fromMap(Map<dynamic, dynamic>  map) : super('PushNotification') {
    title = map["name"];
    message = map["message"];
    topic = map["topic"];
    senderCompany = map["senderCompany"] == null ? null : Company.fromMap(map["senderCompany"]);
    senderUser = map["senderUser"] == null ? null : BaseUser.fromMap(map["senderUser"]);
    destinationUser = map["destinationUser"] == null ? null : BaseUser.fromMap(map["destinationUser"]);
    validated = map["validated"] as bool;
  }

  @override
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["title"] = title;
    map["message"] = message;
    map["topic"] = topic;
    map["senderCompany"] = senderCompany == null ? null : senderCompany.toPointer();
    map["senderUser"] = senderUser == null ? null : senderUser.toPointer();
    map["destinationUser"] = destinationUser == null ? null : destinationUser.toPointer();
    map["validated"] = validated;
    return map;
  }

}