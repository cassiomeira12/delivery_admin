import '../../models/order/order.dart';
import '../../contracts/crud.dart';
import '../base_result_contract.dart';

abstract class OrderContractView extends BaseResultContract<Order> {

}

abstract class OrderContractPresenter extends Crud<Order> {
  dispose();
  listTodayOrders();
}

abstract class OrderContractService extends Crud<Order> {

}