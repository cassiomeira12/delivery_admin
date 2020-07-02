import '../../models/base_user.dart';
import '../base_model.dart';
import 'company.dart';

class AdminCompany extends BaseModel<AdminCompany> {
  NotificationToken notificationToken;
  BaseUser user;
  Company company;

  AdminCompany({String id}) : super('AdminCompany') {
    this.id = id;
    objectId = id;
  }

  AdminCompany.fromMap(Map<dynamic, dynamic>  map) : super('_User') {
    objectId = map["objectId"];
    id = objectId;
    notificationToken = map["notificationToken"] == null ? null : NotificationToken.fromMap(map["notificationToken"]);
    user = BaseUser.fromMap(map["user"]);
    company = Company.fromMap(map["company"]);
  }

  toMap() {
    var map = Map<String, dynamic>();
    map["objectId"] = id;
    map["notificationToken"] = notificationToken == null ? null : notificationToken.toMap();
    map["user"] = user.toPointer();
    map["company"] = company.toPointer();
    return map;
  }

}