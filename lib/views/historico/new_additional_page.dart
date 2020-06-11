import 'package:delivery_admin/models/menu/additional.dart';
import 'package:delivery_admin/models/menu/choice.dart';
import 'package:delivery_admin/views/home/choice_widget.dart';
import 'package:delivery_admin/widgets/secondary_button.dart';
import 'package:delivery_admin/widgets/text_input_field.dart';

import '../../models/order/order_item.dart';
import '../../models/singleton/order_singleton.dart';
import '../../models/singleton/singleton_user.dart';
import '../../widgets/scaffold_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../models/menu/item.dart';
import '../../models/menu/product.dart';
import '../../strings.dart';
import '../../views/home/additional_widget.dart';
import '../../views/image_view_page.dart';
import '../../widgets/area_input_field.dart';
import '../../widgets/count_widget.dart';
import '../../widgets/primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:progress_state_button/progress_button.dart';
import '../../widgets/background_card.dart';
import '../page_router.dart';

class NewAdditionalPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _NewAdditionalPageState();
}

class _NewAdditionalPageState extends State<NewAdditionalPage> {
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loading = false;

  TextEditingController descriptionController;
  String name;
  double cost;
  int maxQuantity;

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Novo Adicional"),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        progressIndicator: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),
          child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(),),
        ),
        child: SingleChildScrollView(
          child: body(),
        ),
      ),
    );
  }

  Widget body() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: TextInputField(
                    labelText: "Nome",
                    textCapitalization: TextCapitalization.sentences,
                    onSaved: (value) => name = value.trim(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: AreaInputField(
                    labelText: "Descrição",
                    maxLines: 4,
                    controller: descriptionController,
                    validator: (value) => null,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: TextInputField(
                    labelText: "Preço R\$",
                    inputType: TextInputType.number,
                    onSaved: (value) => value.isEmpty ? cost = 0 : cost = double.parse(value.trim()),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: TextInputField(
                    labelText: "Quantidade Máxima",
                    inputType: TextInputType.number,
                    onSaved: (value) => maxQuantity = int.parse(value.trim()),
                  ),
                ),
                saveButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget saveButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
      alignment: Alignment.center,
      child: PrimaryButton(
        text: "Salvar",
        onPressed: save,
      ),
    );
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void save() {
    if (validateAndSave()) {
      var additional = Additional()
          ..name = name
          ..description = descriptionController.value.text.isEmpty ? null : descriptionController.value.text
          ..cost = cost
          ..maxQuantity = maxQuantity;
      PageRouter.pop(context, additional);
    }
  }

}