import 'dart:io';
import '../../models/singleton/user_singleton.dart';
import '../../models/company/admin.dart';
import '../../contracts/company/admin_contract.dart';
import '../../utils/preferences_util.dart';
import '../../utils/log_util.dart';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'base_firebase_service.dart';

class FirebaseAdminService implements AdminContractService {
  CollectionReference _collection;
  BaseFirebaseService _firebaseCrud;

  FirebaseAdminService(String path) {
    _firebaseCrud = BaseFirebaseService(path);
    _collection = _firebaseCrud.collection;
  }

  @override
  Future<Admin> create(Admin item) async {
    item.password = null;
    return _firebaseCrud.create(item).then((response) {
      return Admin.fromMap(response);
    });
  }

  @override
  Future<Admin> read(Admin item) {
    return _firebaseCrud.read(item).then((response) {
      return Admin.fromMap(response);
    }).catchError((error) {
      Log.e("Document ${item.id} not found");
    });
  }

  @override
  Future<Admin> update(Admin item) {
    return _firebaseCrud.update(item).then((response) {
      return Admin.fromMap(response);
    }).catchError((error) {
      Log.e("Document ${item.id} not found");
    });
  }

  @override
  Future<Admin> delete(Admin item) {
    return _firebaseCrud.delete(item).then((response) {
      return Admin.fromMap(response);
    }).catchError((error) {
      Log.e("Document ${item.id} not found");
    });
  }

  @override
  Future<List<Admin>> findBy(String field, value) async {
    return _firebaseCrud.findBy(field, value).then((response) {
      return response.map<Admin>((item) => Admin.fromMap(item)).toList();
    });
  }

  @override
  Future<List<Admin>> list() {
    return _firebaseCrud.list().then((response) {
      return response.map<Admin>((item) => Admin.fromMap(item)).toList();
    });
  }

  Future<Admin> findUserByEmail(String email) async {
    List<Admin> list;
    await findBy("email", email).then((value) {
      if (value.length == 1) {
        PreferencesUtil.setUserData(value[0].toMap());
      }
      list = value;
    }).catchError((error) async {
      dynamic result = await PreferencesUtil.getUserData();
      if (result != null) {
        list = List();
        list.add(Admin.fromMap(result));
      }
    });

    if (list == null) return null;

    if (list.length == 1) {
      return list[0];
    } else if (list.length == 0) {
      Log.e("Usuário não encontrado");
      return null;
    } else {
      Log.e("Mais de 1 usuário com mesmo email");
      return null;
    }
  }

  @override
  Future<Admin> createAccount(Admin user) async {
    return await create(user);
  }

  @override
  Future<void> changePassword(String email, String password, String newPassword) async {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((result) {
      result.user.updatePassword(newPassword);
    });
  }

  @override
  Future<bool> changeName(String name) async {
    UserSingleton.instance.name = name;
    return await update(UserSingleton.instance) == null ? false : true;
  }

  @override
  Future<String> changeUserPhoto(File image) async {
    String baseName = Path.basename(image.path);
    String uID = UserSingleton.instance.id + baseName.substring(baseName.length - 4);
    StorageReference storageReference = FirebaseStorage.instance.ref().child("users/${uID}");
    StorageUploadTask uploadTask = storageReference.putFile(image);
    return await uploadTask.onComplete.then((value) async {
      return await storageReference.getDownloadURL().then((fileURL) async {
        UserSingleton.instance.avatarURL = fileURL;
        return await update(UserSingleton.instance) == null ? null : fileURL;
      }).catchError((error) {
        print(error.message);
        return null;
      });
    }).catchError((error) {
      print(error.message);
      return null;
    });
  }

  @override
  Future<Admin> currentUser() async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    if (currentUser == null) {
      return null;
    } else {
      Admin user = await findUserByEmail(currentUser.email);
      if (user == null) {
        return null;
      }
      user.emailVerified = currentUser.isEmailVerified;
      return user;
    }
  }

  @override
  Future<void> signOut() async {
    PreferencesUtil.setUserData(null);
    return await FirebaseAuth.instance.signOut();
  }

  @override
  Future<bool> isEmailVerified() async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    bool emailVerified = currentUser.isEmailVerified;
    Admin user = await findUserByEmail(currentUser.email);
    if (user != null) {
      user.emailVerified = emailVerified;
      _collection.document(user.id).updateData(user.toMap());
    }
    return emailVerified;
  }

  @override
  Future<void> sendEmailVerification() async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    return currentUser.sendEmailVerification();
  }

}