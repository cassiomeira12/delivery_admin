import '../base_model.dart';

class Evaluation extends BaseModel<Evaluation> {
  int stars;
  String comment;

  Evaluation();

  Evaluation.fromMap(Map<dynamic, dynamic>  map) {
    id = map["id"];
    stars = map["stars"] as int;
    comment = map["comment"];
  }

  @override
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["id"] = id;
    map["stars"] = stars;
    map["comment"] = comment;
    return map;
  }

  @override
  update(Evaluation item) {
    id = item.id;
    stars = item.stars;
    comment = item.comment;
  }

}