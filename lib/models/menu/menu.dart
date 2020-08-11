import 'package:kidelivercompany/models/company/company.dart';

import '../base_model.dart';
import 'category.dart';

class Menu extends BaseModel<Menu> {
  Company company;
  List<Category> categories;

  Menu() : super('Menu');

  Menu.fromMap(Map<String, dynamic>  map) : super('Menu') {
    objectId = map["objectId"];
    id = objectId;
    company = Company.fromMap(map["company"]);
    categories = map["categories"] == null ? null : List.from(map["categories"]).map<Category>((e) => Category.fromMap(e)).toList();
  }

  @override
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["objectId"] = id;
    map["company"] = company.toPointer();
    map["categories"] = categories == null ? null : categories.map<Map>((e) => e.toMap()).toList();
    return map;
  }

//  @override
//  update(Menu item) {
//    id = item.id;
//    idCompany = item.idCompany;
//    categories = item.categories;
//  }

}