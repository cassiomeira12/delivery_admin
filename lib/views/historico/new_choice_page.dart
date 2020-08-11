import '../../models/menu/choice.dart';
import '../../views/historico/new_item_page.dart';
import '../../widgets/rounded_shape.dart';
import '../../widgets/text_input_field.dart';
import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import '../../models/menu/item.dart';
import '../../widgets/area_input_field.dart';
import '../../widgets/primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../page_router.dart';

class NewChoicePage extends StatefulWidget {
  Choice choice;

  NewChoicePage({this.choice});

  @override
  State<StatefulWidget> createState() => _NewChoicePageState();
}

class _NewChoicePageState extends State<NewChoicePage> {
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loading = false;

  TextEditingController descriptionController;
  String name;
  bool required = false;
  int maxQuantity, minQuantity;

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.choice == null ? "Nova Opção" : widget.choice.name),
        ),
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          progressIndicator: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),
            child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(),),
          ),
          child: SingleChildScrollView(
            child: widget.choice == null ? bodyChoice() : bodyItem(),
          ),
        ),
        floatingActionButton: widget.choice != null ? FloatingActionButton(
          child: Icon(Icons.add, color: Colors.white,),
          onPressed: () async {
            var result = await PageRouter.push(context, NewItemPage());
            if (result != null) {
              setState(() {
                widget.choice.itens.add(result);
              });
            }
          },
        ) : null,
      ),
    );
  }

  Future<bool> _onBackPressed() {
    PageRouter.pop(context, widget.choice);
  }

  Widget bodyItem() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: StickyHeader(
        header: Container(
          color: Colors.grey[200],
          padding: EdgeInsets.only(left: 10, top: 20, bottom: 20),
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "${widget.choice.name}",
                    style: Theme.of(context).textTheme.body1,
                  ),
                  widget.choice.required ?
                  Text(
                    "*",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ) : Container(),
                ],
              ),
              widget.choice.description != null ?
              Text(
                widget.choice.description,
                style: Theme.of(context).textTheme.body2,
              ) : Container(),
            ],
          ),
        ),
        content: ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: widget.choice.itens.map((e) {
            return Column(
              children: [
                choiceItemWidget(e),
                //Divider(color: Colors.grey, height: 0,),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget choiceItemWidget(Item item) {
    return Card(
      margin: EdgeInsets.all(5),
      elevation: 2,
      child: FlatButton(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.body1,
                  ),
                  item.description != null ?
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.body2,
                  ) : Container(),
                ],
              ),
            ),
            Row(
              children: [
                item.cost != null ?
                Text(
                  "R\$ ${item.cost.toStringAsFixed(2)}",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ) : Container(),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: FaIcon(FontAwesomeIcons.trashAlt,),
                  ),
                  onTap: () {
                    setState(() {
                      widget.choice.itens.remove(item);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        onPressed: () async {
          var result = await PageRouter.push(context, NewItemPage(item: item,));
          setState(() {
            item = result;
          });
        },
      ),
    );
  }

  Widget bodyChoice() {
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
                    textCapitalization: TextCapitalization.sentences,
                    controller: descriptionController,
                    validator: (value) => null,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: RoundedShape(
                    padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Obrigatório",
                          style: Theme.of(context).textTheme.body2,
                        ),
                        Checkbox(
                          value: required,
                          onChanged: (value) {
                            setState(() {
                              required = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: TextInputField(
                    labelText: "Quantidade Mínima",
                    keyboardType: TextInputType.number,
                    onSaved: (value) => maxQuantity = int.parse(value.trim()),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: TextInputField(
                    labelText: "Quantidade Máxima",
                    keyboardType: TextInputType.number,
                    onSaved: (value) => minQuantity = int.parse(value.trim()),
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
      var choice = Choice()
          ..name = name
          ..description = descriptionController.value.text.isEmpty ? null : descriptionController.value.text
          ..minQuantity = minQuantity
          ..maxQuantity = maxQuantity;
      choice.required = required;
      setState(() {
        widget.choice = choice;
      });
    }
  }

}