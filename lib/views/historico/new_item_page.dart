import '../../models/menu/choice.dart';
import '../../widgets/text_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import '../../models/menu/item.dart';
import '../../widgets/area_input_field.dart';
import '../../widgets/primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../page_router.dart';

class NewItemPage extends StatefulWidget {
  final Choice choice;

  NewItemPage({this.choice});

  @override
  State<StatefulWidget> createState() => _NewItemPageState();
}

class _NewItemPageState extends State<NewItemPage> {
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loading = false;

  TextEditingController descriptionController;
  MoneyMaskedTextController costController;
  String name;
  bool required = false;

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController();
    costController = MoneyMaskedTextController(leftSymbol: 'R\$ ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Novo Item"),
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
                    keyboardType: TextInputType.number,
                    controller: costController,
                    validator: (value) => null,
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
      var item = Item()
          ..name = name
          ..description = descriptionController.value.text.isEmpty ? null : descriptionController.value.text
          ..cost = costController.numberValue;
      PageRouter.pop(context, item);
    }
  }

}