import '../base_model.dart';
import 'product.dart';

class Category extends BaseModel<Category> {
  String name;
  List<Product> products;

  Category() : super('Category');

  Category.fromMap(Map<dynamic, dynamic>  map) : super('Category') {
    //objectId = map["objectId"];
    //id = objectId;
    name = map["name"];
    products = map["products"] == null ? List() : List.from(map["products"]).map<Product>((e) => Product.fromMap(e)).toList();
  }

  @override
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    //map["objectId"] = id;
    map["name"] = name;
    map["products"] = products.map<Map>((e) => e.toMap()).toList();
    return map;
  }

//  @override
//  update(Category item) {
//    id = item.id;
//    name = item.name;
//    products = item.products;
//  }

}