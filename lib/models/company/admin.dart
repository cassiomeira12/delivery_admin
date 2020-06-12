import '../../models/base_user.dart';
import '../phone_number.dart';

class Admin extends BaseUser {
  String companyId;

  Admin() : super();

  Admin.fromMap(Map<dynamic, dynamic>  map) {
    id = map["_id"];
    notificationToken = map["notificationToken"] == null ? null : NotificationToken.fromMap(map["notificationToken"]);
    avatarURL = map["avatarURL"];
    name = map["name"];
    email = map["email"];
    emailVerified = map["emailVerified"];
    password = map["password"];
    createAt = map["createAt"] == null ? null : DateTime.parse(map["createAt"]);
    updateAt = map["updateAt"] == null ? null : DateTime.parse(map["updateAt"]);
    phoneNumber = map["phoneNumber"] == null ? null : PhoneNumber.fromMap(map["phoneNumber"]);
    companyId = map["companyId"];
  }

  @override
  toMap() {
    var map = super.toMap();
    map["companyId"] = companyId;
    return map;
  }

  @override
  update(dynamic admin) {
    super.update(admin);
    companyId = admin.companyId;
  }
}