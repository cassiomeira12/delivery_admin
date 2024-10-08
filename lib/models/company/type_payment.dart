import '../base_model.dart';

enum Type {
  CARD, MONEY, APP_PAYMENT, CASHBACK
}

class TypePayment extends BaseModel<TypePayment> {
  String name;
  Type type;
  double taxa;// 0.0 - 1.0
  int maxInstallments;//Max prestação

  TypePayment() {
    taxa = 0;
    maxInstallments = 1;
  }

  TypePayment.fromMap(Map<dynamic, dynamic>  map) {
    //id = map["id"];
    name = map["name"];
    var typeTemp = map["type"];
    Type.values.forEach((element) {
      if (element.toString().split('.').last == typeTemp) {
        type = element;
        return;
      }
    });
    taxa = (map["taxa"] as num).toDouble();
    maxInstallments = map["maxInstallments"] as int;
  }

  @override
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    //map["id"] = id;
    map["name"] = name;
    map["type"] = type.toString().split('.').last;
    map["taxa"] = taxa;
    map["maxInstallments"] = maxInstallments;
    return map;
  }

  @override
  update(TypePayment item) {
    id = item.id;
    name = item.name;
    type = item.type;
    taxa = item.taxa;
    maxInstallments = item.maxInstallments;
  }

  String getType() {
    switch (type) {
      case Type.CARD:
        return "Cartão";
      case Type.MONEY:
        return "Dinheiro";
      case Type.APP_PAYMENT:
        return "Pagamento no Aplicativo";
      case Type.CASHBACK:
        return "Cashback";
      default:
        return "";
    }
  }

}
