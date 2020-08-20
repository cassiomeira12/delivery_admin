import '../../models/order/order.dart';
import '../../contracts/crud.dart';
import '../base_result_contract.dart';

abstract class OrderContractView extends BaseResultContract<Order> {
  removeOrder(Order order);
}

abstract class OrderContractPresenter extends Crud<Order> {
  dispose();
  readSnapshot(Order item);
  listDayOrdersSnapshot(DateTime day);
  listDayOrders(DateTime day);
}

abstract class OrderContractService extends Crud<Order> {

}