import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:kidelivercompany/strings.dart';
import '../../models/menu/additional.dart';
import '../../widgets/text_input_field.dart';
import 'package:flutter/material.dart';
import '../../widgets/area_input_field.dart';
import '../../widgets/primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../page_router.dart';

class NewAdditionalPage extends StatefulWidget {
  final Additional additional;

  NewAdditionalPage({this.additional});

  @override
  State<StatefulWidget> createState() => _NewAdditionalPageState();
}

class _NewAdditionalPageState extends State<NewAdditionalPage> {
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loading = false;

  TextEditingController nameController;
  TextEditingController descriptionController;
  MoneyMaskedTextController costController;
  TextEditingController maxQuantityController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    costController = MoneyMaskedTextController(leftSymbol: 'R\$ ');
    maxQuantityController = TextEditingController();
    if (widget.additional != null) {
      nameController.text = widget.additional.name;
      descriptionController.text = widget.additional.description;
      costController.updateValue(widget.additional.cost);
      maxQuantityController.text = widget.additional.maxQuantity.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.additional == null ? "Novo Adicional" : widget.additional.name),
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
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: TextInputField(
                    labelText: "Quantidade Máxima",
                    keyboardType: TextInputType.number,
                    controller: maxQuantityController,
                    validator: (value) {
                      if (value.isNotEmpty) {
                        return int.parse(value) > 0 ? null : "Quantidade tem que ser maior que zero";
                      } else {
                        return "Quantidade não pode ser vazio";
                      }
                    },
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
        text: SALVAR,
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
      if (widget.additional == null) {
        var additional = Additional()
          ..name = nameController.value.text.isEmpty ? null : nameController.value.text
          ..description = descriptionController.value.text.isEmpty ? null : descriptionController.value.text
          ..cost = costController.numberValue
          ..maxQuantity = int.parse(maxQuantityController.text);
        PageRouter.pop(context, additional);
      } else {
        widget.additional.name = nameController.value.text.isEmpty ? null : nameController.value.text;
        widget.additional.description = descriptionController.value.text.isEmpty ? null : descriptionController.value.text;
        widget.additional.cost = costController.numberValue;
        widget.additional.maxQuantity = int.parse(maxQuantityController.text);
        PageRouter.pop(context, widget.additional);
      }
    }
  }

}