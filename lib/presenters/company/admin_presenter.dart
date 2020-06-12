import 'dart:io';
import 'package:delivery_admin/models/singleton/user_singleton.dart';

import '../../contracts/company/admin_contract.dart';
import '../../models/company/admin.dart';
import '../../contracts/crud.dart';
import '../../services/firebase/firebase_admin_service.dart';
import '../../strings.dart';

class AdminPresenter implements AdminContractPresenter, Crud<Admin> {
  final AdminContractView _view;
  AdminPresenter(this._view);

  AdminContractService service = FirebaseAdminService("admins");

  @override
  Future<Admin> create(Admin item) async {
    return await service.create(item).then((value) {
      _view.onSuccess(value);
      return value;
    }).catchError((error) {
      _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<Admin> read(Admin item) async {
    return await service.read(item).then((value) {
      _view.onSuccess(value);
      return value;
    }).catchError((error) {
      _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<Admin> update(Admin item) async {
    return await service.update(item).then((value) {
      _view.onSuccess(value);
      return value;
    }).catchError((error) {
      _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<Admin> delete(Admin item) async {
    return await service.create(item).then((value) {
      _view.onSuccess(value);
      return value;
    }).catchError((error) {
      _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<List<Admin>> findBy(String field, value) async {
    return await service.findBy(field, value).then((value) {
      return value;
    }).catchError((error) {
      _view.onFailure(error.message);
      return null;
    });
  }

  @override
  Future<List<Admin>> list() {
    // TODO: implement list
    return null;
  }

  @override
  Future<bool> changeName(String name) async {
    await service.changeName(name).then((value) {
      if (value) {
        _view.onSuccess(UserSingleton.instance);
      } else {
        _view.onFailure(CHANGE_NAME_FAILURE);
      }
    });
  }

  @override
  Future<String> changeUserPhoto(File image) async {
    await service.changeUserPhoto(image).then((URL) {
      UserSingleton.instance.avatarURL = URL;
      _view.onSuccess(UserSingleton.instance);
    }).catchError((error) {
      _view.onFailure(error.message);
    });
  }

  @override
  Future<String> changePassword(String email, String password, String newPassword) async {
    await service.changePassword(email, password, newPassword).then((value) {
      _view.onSuccess(null);
    }).catchError((error) {
      _view.onFailure(error.message);
    });
  }

  @override
  Future<Admin> currentUser() async {
    Admin user =  await service.currentUser();
    if (user == null) {
      _view.onFailure("");
    } else {
      _view.onSuccess(user);
    }
  }

  @override
  Future<void> signOut() {
    return service.signOut();
  }

  @override
  Future<bool> isEmailVerified() {
    return service.isEmailVerified();
  }

  @override
  Future<void> sendEmailVerification() async {
    await service.sendEmailVerification().then((value) {
      _view.onSuccess(null);
    }).catchError((error) {
      _view.onFailure(ERROR_ENVIAR_EMAIL);
    });
  }

}