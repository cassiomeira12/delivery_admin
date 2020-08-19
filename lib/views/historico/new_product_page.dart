import 'package:kidelivercompany/utils/log_util.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import '../../models/menu/additional.dart';
import '../../models/menu/choice.dart';
import '../../views/historico/new_additional_page.dart';
import '../../views/historico/new_choice_page.dart';
import '../../views/home/choice_widget.dart';
import '../../widgets/rounded_shape.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/text_input_field.dart';
import '../../models/menu/product.dart';
import '../../views/home/additional_widget.dart';
import '../../widgets/area_input_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/background_card.dart';
import '../page_router.dart';

class NewProductPage extends StatefulWidget {
  final Product product;

  NewProductPage({this.product});

  @override
  State<StatefulWidget> createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loading = false;

  var nameController = TextEditingController();
  var descriptionController = TextEditingController();
  var costController = MoneyMaskedTextController(leftSymbol: 'R\$ ');
  var discountController = MoneyMaskedTextController(leftSymbol: 'R\$ ', initialValue: 0);

  String name;
  double cost, discount;
  PreparationTime preparationTime;
  List<String> imagesList = List();
  List<Choice> choiceList = List();
  List<Additional> additionalList = List();
  List<ChoiceWidget> selectedChoices = List();
  bool visible;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      setProductData(widget.product);
      visible = widget.product.visible;
    }
  }

  void setProductData(Product product) {
    nameController.text = product.name;
    descriptionController.text = product.description;
    costController.updateValue(product.cost);
    discountController.updateValue(product.discount);
    preparationTime = product.preparationTime;
    imagesList = product.images;
    choiceList = product.choices;
    additionalList = product.additional;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.product == null ? "Novo item" : widget.product.name),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        progressIndicator: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: CircularProgressIndicator(),
          ),
        ),
        child: keyboardDismisser(),
      ),
    );
  }

  Widget keyboardDismisser() {
    return KeyboardDismisser(
      gestures: [GestureType.onTap, GestureType.onVerticalDragDown],
      child: SingleChildScrollView(
        child: body(),
      ),
    );
  }

  Widget nestedScrollView() {
    return NestedScrollView(
      controller: ScrollController(keepScrollOffset: true),
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              Stack(
                //alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Stack(
                        alignment: Alignment.topCenter,
                        children: <Widget>[
                          BackgroundCard(
                            height: 200,
                          ),
                          //slidesImages(),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ]),
          ),
        ];
      },
      body: SingleChildScrollView(
        child: body(),
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
                    onSaved: (value) => name = nameController.text,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: AreaInputField(
                    labelText: "Descrição",
                    maxLines: 6,
                    textCapitalization: TextCapitalization.sentences,
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
                    onSaved: (value) => cost = costController.numberValue,
                  ),
                ),
//                Padding(
//                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
//                  child: TextInputField(
//                    labelText: "Desconto R\$",
//                    controller: discountController,
//                    onSaved: (value) =>
//                        discount = discountController.numberValue,
//                  ),
//                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: SecondaryButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "Visível",
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.body2
                        ),
                        Checkbox(
                          value: visible,
                          onChanged: (value) => setState(() => visible = !visible),
                        ),
                      ],
                    ),
                    onPressed: () => setState(() => visible = !visible),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: GestureDetector(
                    child: RoundedShape(
                      padding: EdgeInsets.only(left: 10, top: 15, bottom: 15),
                      color: Colors.transparent,
                      child: Text(
                        preparationTime == null
                            ? "Tempo de preparo"
                            : "Tempo de preparo: ${preparationTime.toString()}",
                        style: Theme.of(context).textTheme.body2,
                      ),
                    ),
                    onTap: () {
                      showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: 0, minute: 0),
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            preparationTime = PreparationTime()
                              ..hour = value.hour
                              ..minute = value.minute;
                          });
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          choicesWidget(),
          additionalWidget(),
          saveProductButton(),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  Widget choicesWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Column(
        children: [
          ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: choiceList.map((e) {
              return GestureDetector(
                child: ChoiceWidget(e),
                onTap: () async {
                  Choice result = await PageRouter.push(context, NewChoicePage(choice: e));
                  setState(() {
                    e = result;
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(
            height: 15,
          ),
          SecondaryButton(
            text: "Nova Opção",
            onPressed: () async {
              var result = await PageRouter.push(context, NewChoicePage());
              if (result != null) {
                setState(() {
                  choiceList.add(result);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget additionalWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Column(
        children: [
          AdditionalWidget(
            additional: additionalList,
            editable: true,
            changedCount: (value) { },
          ),
          SizedBox(
            height: 15,
          ),
          SecondaryButton(
            text: "Novo Adicional",
            onPressed: () async {
              var result = await PageRouter.push(context, NewAdditionalPage());
              if (result != null) {
                setState(() {
                  additionalList.add(result);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget saveProductButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      alignment: Alignment.center,
      child: PrimaryButton(
        text: "Salvar",
        onPressed: () {
          save();
        },
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

  void save() async {
    if (validateAndSave()) {
      if (widget.product == null) {
        discount = 0;

        var product = Product()
          ..name = name
          ..description = descriptionController.value.text.isEmpty
              ? null
              : descriptionController.value.text
          ..cost = cost
          ..discount = discount
          ..preparationTime = preparationTime
          ..images = imagesList
          ..choices = choiceList
          ..additional = additionalList
          ..visible = visible;

        PageRouter.pop(context, product);
      } else {
        discount = 0;

        widget.product.name = name;
        widget.product.description = descriptionController.value.text.isEmpty
            ? null
            : descriptionController.value.text;
        widget.product.cost = cost;
        widget.product.discount = discount;
        widget.product.preparationTime = preparationTime;
        widget.product.images = imagesList;
        widget.product.choices = choiceList;
        widget.product.additional = additionalList;
        widget.product.visible = visible;

        PageRouter.pop(context, widget.product);
      }
    }
  }
}