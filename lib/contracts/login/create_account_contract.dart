import '../../models/company/admin.dart';
import '../base_progress_contract.dart';
import '../base_result_contract.dart';

abstract class CreateAccountContractView implements BaseProgressContract, BaseResultContract<Admin> {

}

abstract class CreateAccountContractPresenter {
  CreateAccountContractView view;
  CreateAccountContractPresenter(this.view);

  dispose() {
    this.view = null;
  }

  Future<Admin> createAccount(Admin user);

  onFailure(String error);
  onSuccess(Admin user);
}

abstract class CreateAccountContractService {
  CreateAccountContractPresenter presenter;
  CreateAccountContractService(this.presenter);

  dispose() {
    this.presenter = null;
  }

  Future<Admin> createAccount(Admin user);
}