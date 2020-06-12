import '../../contracts/base_result_contract.dart';
import '../../models/company/admin.dart';
import '../base_progress_contract.dart';

abstract class LoginContractView implements BaseProgressContract, BaseResultContract<Admin> {

}

abstract class LoginContractPresenter {
  LoginContractView view;
  LoginContractPresenter(this.view);

  dispose() {
    this.view = null;
  }

  signIn(String email, String password);
  signInWithGoogle();
  onFailure(String error);
  onSuccess(Admin user);
}

abstract class LoginContractService {
  LoginContractPresenter presenter;
  LoginContractService(this.presenter);

  dispose() {
    this.presenter = null;
  }

  signIn(String email, String password);
  signInWithGoogle();
}