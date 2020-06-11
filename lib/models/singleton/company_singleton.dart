import '../../models/company/company.dart';

class CompanySingleton {

  static final Company _instance = Company();

  static Company get instance => _instance;

}