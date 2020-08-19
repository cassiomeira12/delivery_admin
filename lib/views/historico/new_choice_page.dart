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
  bool editChoice;

  NewChoicePage({
    this.choice,
    this.editChoice = false
  });

  @override
  State<StatefulWidget> createState() => _NewChoicePageState();
}

class _NewChoicePageState extends State<NewChoicePage> {
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loading = false;

  bool required = false;
  TextEditingController nameDescription, descriptionController;
  TextEditingController maxQuantityController, minQuantityController;

  @override
  void initState() {
    super.initState();
    nameDescription = TextEditingController();
    descriptionController = TextEditingController();
    maxQuantityController = TextEditingController();
    minQuantityController = TextEditingController();
    setChoice();
  }

  void setChoice() {
    if (widget.choice != null && widget.editChoice) {
      nameDescription.text = widget.choice.name;
      descriptionController.text = widget.choice.description;
      required = widget.choice.required;
      maxQuantityController.text = widget.choice.maxQuantity.toString();
      minQuantityController.text = widget.choice.minQuantity.toString();
    }
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
            child: widget.choice == null ? bodyChoice() : widget.editChoice ? bodyChoice() : bodyItem(),
          ),
        ),
        floatingActionButton: widget.choice != null && !widget.editChoice ? FloatingActionButton(
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
        header: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.grey[200],
            padding: EdgeInsets.only(left: 10, top: 20, bottom: 20),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
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
                    Row(
                      children: [
                        Text(
                          "Min: ${widget.choice.minQuantity}, Max: ${widget.choice.maxQuantity}",
                          style: Theme.of(context).textTheme.body1,
                        ),
                        Expanded(
                          child: Text(
                            "Editar",
                            textAlign: TextAlign.end,
                            style: Theme.of(context).textTheme.body1,
                          ),
                        ),
                        SizedBox(width: 10,),
                      ],
                    ),
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
          onTap: () async {
            setState(() {
              widget.editChoice = true;
            });
            setChoice();
          },
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
                  Row(
                    children: [
                      FaIcon(
                        item.visible ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
                        size: 20,
                        color: Colors.black45,
                      ),
                      SizedBox(width: 5,),
                      Expanded(
                        child: Text(
                          item.name,
                          style: Theme.of(context).textTheme.body1,
                        ),
                      ),
                    ],
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
                    controller: nameDescription,
                    //onSaved: (value) => name = value.trim(),
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
                    labelText: "Quantidade máxima",
                    keyboardType: TextInputType.number,
                    controller: maxQuantityController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Quantidade máxima não pode ser vazio";
                      }
                      if (int.parse(value) < 1) {
                        return "Quantidade máxima deve ser maior que zero";
                      }
                      if (int.parse(value) < int.parse(minQuantityController.value.text)) {
                        return "Quantidade máxima deve ser maior";
                      }
                      return null;
                    },
                    //onSaved: (value) => minQuantity = int.parse(value.trim()),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: TextInputField(
                    labelText: "Quantidade mínima",
                    keyboardType: TextInputType.number,
                    controller: minQuantityController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Quantidade mínima não pode ser vazio";
                      }
                      if (int.parse(value) < 1) {
                        return "Quantidade mínima deve ser maior que zero";
                      }
                      if (int.parse(value) > int.parse(maxQuantityController.value.text)) {
                        return "Quantidade mínima deve ser menor";
                      }
                      return null;
                    },
                    //onSaved: (value) => maxQuantity = int.parse(value.trim()),
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
      if (widget.choice == null) {
        var choice = Choice()
          ..name = nameDescription.value.text
          ..description = descriptionController.value.text.isEmpty ? null : descriptionController.value.text
          ..minQuantity = int.parse(minQuantityController.value.text)
          ..maxQuantity = int.parse(maxQuantityController.value.text)
          ..required = required;
        setState(() => widget.choice = choice);
      } else {
        setState(() {
          widget.choice.name = nameDescription.value.text;
          widget.choice.description = descriptionController.value.text.isEmpty ? null : descriptionController.value.text;
          widget.choice.minQuantity = int.parse(minQuantityController.value.text);
          widget.choice.maxQuantity = int.parse(maxQuantityController.value.text);
          widget.choice.required = required;

          widget.editChoice = false;
        });
      }
    }
  }

}