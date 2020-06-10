import '../../models/company/company.dart';
import '../../models/order/order_item.dart';
import '../../models/address/address.dart';
import '../../models/company/type_payment.dart';
import '../../models/order/evaluation.dart';
import '../base_model.dart';
import 'order_status.dart';

class Order extends BaseModel<Order> {
  String userId;
  String userName;
  String companyId;
  String companyName;
  DateTime createdAt;
  DateTime updatedAt;
  String note;
  Evaluation evaluation;
  Address deliveryAddress;
  double deliveryCost;
  TypePayment typePayment;
  List<OrderItem> items;
  OrderStatus status;
  String changeMoney;

  Company company;

  Order() {
    items = List();
    status = OrderStatus();
  }

  Order.fromMap(Map<dynamic, dynamic>  map) {
    id = map["id"];
    userId = map["userId"];
    userName = map["userName"];
    companyId = map["companyId"];
    companyName = map["companyName"];
    createdAt = map["createdAt"] == null ? null : DateTime.parse(map["createdAt"]);
    updatedAt = map["updatedAt"] == null ? null : DateTime.parse(map["updatedAt"]);
    note = map["note"];
    evaluation = map["evaluation"] == null ? null : Evaluation.fromMap(map["evaluation"]);
    deliveryAddress = map["deliveryAddress"] == null ? null : Address.fromMap(map["deliveryAddress"]);
    deliveryCost = (map["deliveryCost"] as num).toDouble();
    typePayment = map["typePayment"] == null ? null : TypePayment.fromMap(map["typePayment"]);
    items = List.from(map["items"]).map<OrderItem>((e) => OrderItem.fromMap(e)).toList();
    status = OrderStatus.fromMap(map["status"]);
    changeMoney = map["changeMoney"];
  }

  @override
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["id"] = id;
    map["userId"] = userId;
    map["userName"] = userName;
    map["companyId"] = companyId;
    map["companyName"] = companyName;
    map["createdAt"] = createdAt == null ? null : createdAt.toString();
    map["updatedAt"] = updatedAt == null ? null : updatedAt.toString();
    map["note"] = note;
    map["evaluation"] = evaluation == null ? null : evaluation.toMap();
    map["deliveryAddress"] = deliveryAddress == null ? null : deliveryAddress.toMap();
    map["deliveryCost"] = deliveryCost;
    map["typePayment"] = typePayment == null ? null : typePayment.toMap();
    map["items"] = items.map<Map>((e) => e.toMap()).toList();
    map["status"] = status.toMap();
    map["changeMoney"] = changeMoney;
    return map;
  }

  @override
  update(Order item) {
    id = item.id;
    userId = item.userId;
    userName = item.userName;
    companyId = item.companyId;
    companyName = item.companyName;
    createdAt = item.createdAt;
    updatedAt = item.updatedAt;
    note = item.note;
    evaluation = item.evaluation;
    deliveryAddress = item.deliveryAddress;
    deliveryCost = item.deliveryCost;
    typePayment = item.typePayment;
    items = item.items;
    status = item.status;
    changeMoney = item.changeMoney;
  }

  clear() {
    id = null;
    userId = null;
    userName = null;
    companyId = null;
    companyName = null;
    createdAt = null;
    updatedAt = null;
    note = null;
    evaluation = null;
    deliveryAddress = null;
    deliveryCost = 0;
    typePayment = null;
    items = List();
    status = OrderStatus();
    changeMoney = null;

    company = null;
  }

}