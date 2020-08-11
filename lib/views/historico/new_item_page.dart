import 'dart:math';

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
  final Item item;

  NewItemPage({this.item});

  @override
  State<StatefulWidget> createState() => _NewItemPageState();
}

class _NewItemPageState extends State<NewItemPage> {
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loading = false;

  TextEditingController nameController;
  TextEditingController descriptionController;
  MoneyMaskedTextController costController;
  String name;
  bool required = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    costController = MoneyMaskedTextController(leftSymbol: 'R\$ ');
    if (widget.item != null) {
      nameController.text = widget.item.name;
      descriptionController.text = widget.item.description;
      costController.updateValue(widget.item.cost);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.item == null ? "Novo Item" : widget.item.name),
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
                    controller: nameController,
                    onSaved: (value) => null,
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
      if (widget.item == null) {
        var item = Item()
          ..name = nameController.value.text.isEmpty ? null : nameController.value.text
          ..description = descriptionController.value.text.isEmpty ? null : descriptionController.value.text
          ..cost = costController.numberValue;
        PageRouter.pop(context, item);
      } else {
        widget.item.name = nameController.value.text.isEmpty ? null : nameController.value.text;
        widget.item.description = descriptionController.value.text.isEmpty ? null : descriptionController.value.text;
        widget.item.cost = costController.numberValue;
        PageRouter.pop(context, widget.item);
      }
    }
  }

}