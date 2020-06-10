import '../../models/menu/additional.dart';
import '../../models/menu/choice.dart';

import '../base_model.dart';
import 'item.dart';

class Product extends BaseModel<Product> {
  String name;
  String description;
  double cost;
  double discount;
  String preparationTime;
  List<String> images;
  //List<Size> sizes;
  //List<Ingredient> ingredientes;
  List<Choice> choices;
  List<Additional> additional;

  Product();

  Product.fromMap(Map<dynamic, dynamic>  map) {
    id = map["id"];
    name = map["name"];
    description = map["description"];
    cost = (map["cost"] as num).toDouble();
    discount = (map["discount"] as num).toDouble();
    preparationTime = map["preparationTime"];
    images = map["images"] == null ? List() : List.from(map["images"]);
    choices = map["choices"] == null ? List() : List.from(map["choices"]).map<Choice>((e) => Choice.fromMap(e)).toList();
    additional = map["additional"] == null ? List() : List.from(map["additional"]).map<Additional>((e) => Additional.fromMap(e)).toList();
    //images
    //sizes
    //ingredites
    //cost = 10;
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
    map["images"] = images == null ? List() : images;
    map["choices"] = choices == null ? List() : choices.map<Map>((e) => e.toMap()).toList();
    map["additional"] = additional == null ? List() : additional.map((e) => e.toMap()).toList();
    //images
    //sizes
    //ingredientes
    return map;
  }

  @override
  update(Product item) {
    id = item.id;
    name = item.name;
    description = item.description;
    cost = item.cost;
    discount = item.discount;
    preparationTime = item.preparationTime;
    images = item.images;
    choices = item.choices;
    additional = item.additional;
  }

}

class Size {
  String name;
  String description;

  Size();

  Size.fromMap(Map<dynamic, dynamic>  map) {
    name = map["name"];
    description = map["description"];
  }

  @override
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["name"] = name;
    map["description"] = description;
    return map;
  }

}

class Ingredient {
  String name;
  String description;
  double cost;

  Ingredient.fromMap(Map<dynamic, dynamic>  map) {
    name = map["name"];
    description = map["description"];
    cost = map["description"] as double;
  }

  @override
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["name"] = name;
    map["description"] = description;
    map["cost"] = cost;
    return map;
  }

}