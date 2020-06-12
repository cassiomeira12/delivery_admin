import 'dart:io';
import '../../models/company/admin.dart';
import '../../contracts/crud.dart';

abstract class AdminContractView {
  onFailure(String error);
  onSuccess(Admin user);
}

abstract class AdminContractPresenter extends AdminContractService {

}

abstract class AdminContractService extends Crud<Admin> {
  Future<Admin> currentUser();
  Future<void> signOut();
  Future<void> changePassword(String email, String password, String newPassword);
  Future<bool> changeName(String name);
  Future<String> changeUserPhoto(File image);
  Future<bool> isEmailVerified();
  Future<void> sendEmailVerification();
}