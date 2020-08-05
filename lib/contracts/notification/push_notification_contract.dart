import '../../models/notification/push_notification.dart';
import '../../contracts/crud.dart';
import '../base_result_contract.dart';

abstract class PushNotificationContractView extends BaseResultContract<PushNotification> {

}

abstract class PushNotificationContractPresenter extends Crud<PushNotification> {
  dispose();
}

abstract class PushNotificationContractService extends Crud<PushNotification> {

}