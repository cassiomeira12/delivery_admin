import '../../models/order/order_item.dart';
import '../../models/singleton/order_singleton.dart';
import '../../models/singleton/user_singleton.dart';
import '../../widgets/scaffold_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../models/menu/item.dart';
import '../../models/menu/product.dart';
import '../../views/home/additional_widget.dart';
import '../../views/image_view_page.dart';
import '../../widgets/primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:progress_state_button/progress_button.dart';
import '../../widgets/background_card.dart';
import '../page_router.dart';
import 'choice_widget.dart';

class ProductPage extends StatefulWidget {
  final dynamic item;

  const ProductPage({
    this.item,
  });

  @override
  State<StatefulWidget> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
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

  List<ChoiceWidget> selectedChoices = List();

  ButtonState buttonState = ButtonState.idle;

  @override
  void initState() {
    super.initState();
    product = widget.item as Product;
    _observacaoController = TextEditingController();
    selectedChoices = product.choices.map((e) => ChoiceWidget(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(product.name),
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
//                          bannerURL == null ?
//                            Container()
//                                :
//                            Container(
//                              height: 100,
//                              decoration: BoxDecoration(
//                                shape: BoxShape.rectangle,
//                                image: DecorationImage(
//                                  fit: BoxFit.fitWidth,
//                                  image: NetworkImage(bannerURL),
//                                ),
//                              ),
//                            ),
                          slidesImages(),
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
      padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          titleTextWidget(product.name),

          costWidget(product.cost),

          product.description == null ? Container() : descriptionTextWidget(product.description),

          tempoPreparo(product.preparationTime),

          SizedBox(height: 20,),

          choicesWidget(),

          additionalWidget(),

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

  Widget tempoPreparo(PreparationTime preparationTime) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: GestureDetector(
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
              preparationTime == null ? "Adicionar" : preparationTime.toString(),
              style: TextStyle(
                fontSize: 20,
                color: Colors.black45,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
                product.preparationTime = preparationTime;
              });
            }
          });
        },
      ),
    );
  }

  Widget choicesWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: selectedChoices,
      ),
    );
  }

  Widget additionalWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: AdditionalWidget(
        additional: product.additional,
        changedCount: (value) {
          double temp = 0;
          value.forEach((element) {
            if (element.amount > 0) {
              temp += element.amount * element.cost;
            }
          });
          setState(() {
            additionalCost = temp;
          });
        },
      ),
    );
  }

  Widget adicionarButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      alignment: Alignment.center,
      child: PrimaryButton(
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: FaIcon(FontAwesomeIcons.shoppingCart, color: Colors.white,),
            ),
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  "Adicionar pedido",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
          ],
        ),
        onPressed: () {
          saveOrderItem();
        },
      ),
    );
  }

  void saveOrderItem() async {
//    final database = LocalDB.MemoryDatabaseAdapter().database();
//    //await database.collection("orders").document(product.id).insert(data: product.toMap());
//    var item = await database.collection("asdf").insert(data: product.toMap(), reach: LocalDB.Reach.local);
//    print(item.documentId);
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
      //order.preparationTime = product.preparationTime;
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
        OrderSingleton.instance.userId = UserSingleton.instance.id;
        OrderSingleton.instance.userName = UserSingleton.instance.name;
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
      //order.preparationTime = product.preparationTime;
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