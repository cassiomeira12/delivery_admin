import '../../models/company/admin.dart';

class UserSingleton {

  static final Admin _instance = Admin();

  static Admin get instance => _instance;

}