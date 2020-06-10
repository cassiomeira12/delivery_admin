import '../../models/menu/additional.dart';
import '../base_model.dart';

class OrderItem extends BaseModel<OrderItem> {
  String name;
  String description;
  double cost;
  double discount;
  String preparationTime;

  int amount;

  List<String> choicesSelected;
  List<Additional> additionalSelected;

  String note;

  OrderItem() {
    choicesSelected = List();
    additionalSelected = List();
  }

  OrderItem.fromMap(Map<dynamic, dynamic>  map) {
    id = map["id"];
    name = map["name"];
    description = map["description"];
    cost = (map["cost"] as num).toDouble();
    discount = (map["discount"] as num).toDouble();
    preparationTime = map["preparationTime"];
    amount = map["amount"] as int;
    choicesSelected = map["choicesSelected"] == null ?
        List() : List.from(map["choicesSelected"]);
        //List.from(map["choicesSelected"]).map<Choice>((e) => Choice.fromMap(e)).toList();
    additionalSelected = map["additionalSelected"] == null ?
        List() :
        List.from(map["additionalSelected"]).map<Additional>((e) => Additional.fromMap(e)).toList();
    note = map["note"];
  }

  @override
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["description"] = description;
    map["cost"] = cost;
    map["discount"] = discount;
    map["preparationTime"] = preparationTime;
    map["amount"] = amount;
    map["choicesSelected"] = choicesSelected == null ?
        null : choicesSelected.toList();
        //choicesSelected.map((e) => e.toMap()).toList();
    map["additionalSelected"] = additionalSelected == null ?
        null :
        additionalSelected.map((e) => e.toMap()).toList();
    map["note"] = note;
    return map;
  }

  @override
  update(OrderItem item) {
    id = item.id;
    name = item.name;
    description = item.description;
    cost = item.cost;
    discount = item.discount;
    preparationTime = item.preparationTime;
    amount = item.amount;
    choicesSelected = item.choicesSelected;
    additionalSelected = item.additionalSelected;
    note = item.note;
  }

  double getTotal() {
    double total = amount * cost;
    additionalSelected.forEach((element) {
      total += element.amount * element.cost;
    });
    return total;
  }

}