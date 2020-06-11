import 'package:delivery_admin/models/menu/additional.dart';
import 'package:delivery_admin/models/menu/choice.dart';
import 'package:delivery_admin/views/historico/new_additional_page.dart';
import 'package:delivery_admin/views/historico/new_choice_page.dart';
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

class NewProductPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loading = false;

  Product product;

  bool favotito = false;

  var menu = ['Remover'];

  List list = [1,2,3];

  int count = 1;
  double additionalCost = 0;

  TextEditingController _observacaoController;

  int radioGroup;
  Item escolhido;


  List<Choice> choiceList = List();
  List<Additional> additionalList = List();

  List<ChoiceWidget> selectedChoices = List();

  ButtonState buttonState = ButtonState.idle;

  @override
  void initState() {
    super.initState();
    product = Product();
    _observacaoController = TextEditingController();
    //selectedChoices = product.choices.map((e) => ChoiceWidget(e)).toList();
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
        child: nestedScrollView(),
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

  Widget slidesImages() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 250,
          aspectRatio: 16/9,
          viewportFraction: 0.8,
          initialPage: 0,
          enableInfiniteScroll: true,
          reverse: false,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 3),
          autoPlayAnimationDuration: Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
          scrollDirection: Axis.horizontal,
          //pauseAutoPlayOnTouch: true,
          //onPageChanged: () {},
        ),
        items: product.images.map((e) {
          return Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(e),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                onTap: () {
                  PageRouter.push(context, ImageViewPage(networkImage: e,));
                },
              );
            },
          );
        }).toList(),
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
                    //inputType: TextInputType.emailAddress,
                    onSaved: (value) => value = value.trim(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: AreaInputField(
                    labelText: "Descrição",
                    maxLines: 4,
                    controller: _observacaoController,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: TextInputField(
                    labelText: "Preço R\$",
                    //inputType: TextInputType.emailAddress,
                    onSaved: (value) => value = value.trim(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: TextInputField(
                    labelText: "Desconto R\$",
                    //inputType: TextInputType.emailAddress,
                    onSaved: (value) => value = value.trim(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: TextInputField(
                    labelText: "Tempo de preparo",
                    //inputType: TextInputType.emailAddress,
                    onSaved: (value) => value = value.trim(),
                  ),
                ),
              ],
            ),
          ),

          choicesWidget(),

          additionalWidget(),

//          titleTextWidget(product.name),
//
//          Row(
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            children: [
//              Padding(
//                padding: EdgeInsets.only(left: 10),
//                child: CountWidget(
//                  minValue: 1,
//                  maxValue: 5,
//                  changedCount: (value) {
//                    setState(() {
//                      count = value;
//                    });
//                  },
//                ),
//              ),
//              costWidget(product.cost),
//            ],
//          ),
//
//          product.description == null ? Container() :
//          descriptionTextWidget(product.description),
//
//          product.preparationTime == null ? Container() : tempoPreparo(product.preparationTime),
//
//          SizedBox(height: 20,),
//
//          choicesWidget(),
//
//          additionalWidget(),
//
//          SizedBox(height: 30,),
//
//          GestureDetector(
//            child: AbsorbPointer(
//              absorbing: true,
//              child: Padding(
//                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
//                child: AreaInputField(
//                  labelText: "Observação",
//                  maxLines: 4,
//                  controller: _observacaoController,
//                ),
//              ),
//            ),
//            onTap: () async {
//              var result = await showTextInputDialog(
//                context: context,
//                title: "Observação",
//                message: "Digite aqui sua observação",
//                cancelLabel: CANCELAR,
//                okLabel: SALVAR,
//                textFields: [
//                  DialogTextField(
//                    hintText: "Observação",
//                    initialText: _observacaoController.text,
//                  ),
//                ],
//              );
//              if (result == null) return;
//              var temp = result[0];
//              setState(() {
//                _observacaoController.text = temp;
//              });
//            },
//          ),
//
//          SizedBox(height: 20,),

          saveProductButton(),

          SizedBox(height: 30,),
        ],
      ),
    );
  }

  Widget titleTextWidget(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 30,
          color: Colors.black45,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget costWidget(double cost) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: Text(
        "R\$ ${((count * cost) + additionalCost).toStringAsFixed(2)}",
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 30,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget descriptionTextWidget(String description) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
      child: Text(
        description,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 20,
          color: Colors.black45,
        ),
      ),
    );
  }

  Widget tempoPreparo(String tempo) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: Row(
        children: [
          Text(
            "Tempo de preparo: ",
            style: TextStyle(
              fontSize: 20,
              color: Colors.black54,
            ),
          ),
          Text(
            "20 - 30 min",
            style: TextStyle(
              fontSize: 20,
              color: Colors.black45,
              fontWeight: FontWeight.bold,
            ),
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
        text: "Cadastrar",
        onPressed: () {
          saveOrderItem();
        },
      ),
    );
  }

  void saveOrderItem() async {
    setState(() {
      _loading = true;
    });

    await Future.delayed(Duration(seconds: 1));

    bool foundError = false;

    if (OrderSingleton.instance.id == null) {
      var order = OrderItem();
      order.id = product.id;

      order.name = product.name;
      order.description = product.description;
      order.cost = product.cost;
      order.discount = product.discount;
      order.preparationTime = product.preparationTime;
      order.amount = count;
      order.note = _observacaoController.text;

      product.additional.forEach((element) {
        if (element.amount > 0) {
          order.additionalSelected.add(element);
        }
      });

      selectedChoices.forEach((element) {
        if (element.selectedItem == null) {
          if (element.choice.required) {
            foundError = true;
            return;
          }
        } else {
          order.choicesSelected.add(element.choice.name + " - " + element.selectedItem.toString());
        }
      });

      if (foundError) {
        setState(() {
          _loading = false;
        });
        ScaffoldSnackBar.failure(context, _scaffoldKey, "Selecione todas as opções obrigatórias");
      } else {
        OrderSingleton.instance.id = product.id;
        OrderSingleton.instance.userId = SingletonUser.instance.id;
        OrderSingleton.instance.userName = SingletonUser.instance.name;
        OrderSingleton.instance.items.add(order);
        PageRouter.pop(context, OrderSingleton.instance);
      }

    } else {
      var order = OrderItem();
      order.id = product.id;

      order.name = product.name;
      order.description = product.description;
      order.cost = product.cost;
      order.discount = product.discount;
      order.preparationTime = product.preparationTime;
      order.amount = count;
      order.note = _observacaoController.text;

      product.additional.forEach((element) {
        if (element.amount > 0) {
          order.additionalSelected.add(element);
        }
      });

      selectedChoices.forEach((element) {
        if (element.selectedItem == null) {
          if (element.choice.required) {
            foundError = true;
            return;
          }
        } else {
          order.choicesSelected.add(element.choice.name + " - " + element.selectedItem.toString());
        }
      });

      if (foundError) {
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          _loading = false;
        });
        ScaffoldSnackBar.failure(context, _scaffoldKey, "Selecione todas as opções obrigatórias");
      } else {
        OrderSingleton.instance.items.add(order);
        PageRouter.pop(context, OrderSingleton.instance);
      }
    }
  }

}