import '../../contracts/login/create_account_contract.dart';
import '../../models/company/admin.dart';
import '../../services/firebase/firebase_admin_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../strings.dart';
import '../../contracts/crud.dart';

class FirebaseCreateAccountService extends CreateAccountContractService {
  FirebaseCreateAccountService(CreateAccountContractPresenter presenter) : super(presenter);

  @override
  Future<Admin> createAccount(Admin user) async {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(email: user.email, password: user.password).then((AuthResult authResult) async {
      user.emailVerified = authResult.user.isEmailVerified;
      Crud<Admin> crud = FirebaseAdminService("admins");
      Admin result = await crud.create(user);
      if (result == null) {
        presenter.onFailure(ERROR_CRIAR_USUARIO);
      } else {
        presenter.onSuccess(result);
      }
    }).catchError((error) {
      presenter.onFailure(error.toString());
    });
  }

}