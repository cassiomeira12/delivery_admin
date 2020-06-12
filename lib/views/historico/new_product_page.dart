import 'package:delivery_admin/models/menu/additional.dart';
import 'package:delivery_admin/models/menu/choice.dart';
import 'package:delivery_admin/utils/log_util.dart';
import 'package:delivery_admin/views/historico/new_additional_page.dart';
import 'package:delivery_admin/views/historico/new_choice_page.dart';
import 'package:delivery_admin/views/home/choice_widget.dart';
import 'package:delivery_admin/widgets/rounded_shape.dart';
import 'package:delivery_admin/widgets/secondary_button.dart';
import 'package:delivery_admin/widgets/text_input_field.dart';

import '../../models/order/order_item.dart';
import '../../models/singleton/order_singleton.dart';
import '../../models/singleton/user_singleton.dart';
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

class NewProductPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loading = false;

  TextEditingController descriptionController;
  String name;
  double cost, discount;
  PreparationTime preparationTime;
  List<String> imagesList = List();
  List<Choice> choiceList = List();
  List<Additional> additionalList = List();

  List<ChoiceWidget> selectedChoices = List();

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
        title: Text("Novo item"),
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
                          BackgroundCard(height: 200,),
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
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: TextInputField(
                    labelText: "Preço R\$",
                    inputType: TextInputType.number,
                    onSaved: (value) => cost = double.parse(value.trim()),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: TextInputField(
                    labelText: "Desconto R\$",
                    controller: TextEditingController(text: "0"),
                    onSaved: (value) => discount = double.parse(value.trim()),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: GestureDetector(
                    child: RoundedShape(
                      padding: EdgeInsets.only(left: 10, top: 15, bottom: 15),
                      color: Colors.transparent,
                      child: Text(
                        preparationTime == null ? "Tempo de preparo" : "Tempo de preparo: ${preparationTime.toString()}",
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

          SizedBox(height: 30,),
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
                  var result = await PageRouter.push(context, NewChoicePage(choice: e,));
                },
              );
            }).toList(),
          ),
          SizedBox(height: 15,),
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
            changedCount: (value) {
//              double temp = 0;
//              value.forEach((element) {
//                if (element.amount > 0) {
//                  temp += element.amount * element.cost;
//                }
//              });
//              setState(() {
//                additionalCost = temp;
//              });
            },
          ),
          SizedBox(height: 15,),
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
      var product = Product()
        ..name = name
        ..description = descriptionController.value.text.isEmpty ? null : descriptionController.value.text
        ..cost = cost
        ..discount = discount
        ..preparationTime = preparationTime
        ..images = imagesList
        ..choices = choiceList
        ..additional = additionalList;

      Log.d(product.toMap());
      PageRouter.pop(context, product);
    }
  }

}