import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:delivery_admin/presenters/company/company_presenter.dart';
import 'package:delivery_admin/presenters/file_presenter.dart';
import 'package:delivery_admin/utils/log_util.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/singleton/singletons.dart';
import '../../views/historico/new_product_page.dart';
import '../../views/home/product_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter/material.dart';
import '../../contracts/menu/menu_contract.dart';
import '../../models/menu/additional.dart';
import '../../models/menu/category.dart';
import '../../models/menu/choice.dart';
import '../../models/menu/item.dart';
import '../../models/menu/product.dart';
import '../../models/menu/menu.dart';
import '../../presenters/menu/menu_presenter.dart';
import '../../views/home/order_slidding_widget.dart';
import '../../views/home/product_widget.dart';
import '../../widgets/empty_list_widget.dart';
import '../../widgets/image_network_widget.dart';
import '../../widgets/loading_shimmer_list.dart';
import '../../models/company/company.dart';
import '../../strings.dart';
import '../../widgets/background_card.dart';
import '../page_router.dart';

class HistoricPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _HistoricPageState();
}

class _HistoricPageState extends State<HistoricPage> implements MenuContractView {
  final _formKey = new GlobalKey<FormState>();

  Company company;

  CompanyPresenter companyPresenter;
  MenuContractPresenter menuPresenter;

  Menu menu;

  String logoURL;
  String bannerURL;
  bool favotito = false;

  List<Product> list;

  bool orderSelected = false;
  int orderItens = 0;

  OrderSliddingWidget sliddingPage;

  @override
  void initState() {
    super.initState();
    company = Singletons.company();
    logoURL = company.logoURL;
    bannerURL = company.bannerURL;
    menuPresenter = MenuPresenter(this);
    companyPresenter = CompanyPresenter(null);
    menuPresenter.findBy("company", Singletons.company().toPointer());
  }

  @override
  void dispose() {
    super.dispose();
    menuPresenter.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cardápio"),
      ),
      body: nestedScrollView(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white,),
        onPressed: () async {
          final categoriesSelected = await showConfirmationDialog<String>(
            context: context,
            title: "Escolha uma categoria",
            okLabel: "Ok",
            cancelLabel: CANCELAR,
            barrierDismissible: false,
            //message: "Deseja sair do $APP_NAME ?",
            actions: menu.categories.map((e) {
              return AlertDialogAction<String>(label: e.name, key: e.name);
            }).toList(),
          );

          if (categoriesSelected != null) {
            var newProduct = await PageRouter.push(context, NewProductPage());
            if (newProduct != null) {
              menu.categories.forEach((element) {
                if (element.name == categoriesSelected) {
                  element.products.add(newProduct);
                  return;
                }
              });
            }
            menuPresenter.update(menu);
          }

        },
      ),
    );
  }

  @override
  listSuccess(List<Menu> list) {
    if (list == null || list.isEmpty) {
      setState(() {
        this.list = List();
      });
      return;
    }

    List<Product> temp = List();

    list[0].categories.forEach((product) {
      temp.addAll(product.products);
    });

    setState(() {
      menu = list[0];
      this.list = temp;
    });
  }

  @override
  onFailure(String error)  {
    print(error);
    setState(() {
      list = [];
    });
  }

  @override
  onSuccess(Menu result) {
    print("update");
    List<Product> temp = List();

    result.categories.forEach((product) {
      temp.addAll(product.products);
    });

    setState(() {
      menu = result;
      this.list = temp;
    });
  }

  Widget notificationCount(int notifications) {
    return notifications > 0 ?
    Align(
      //alignment: Alignment.topCenter,
      child: ClipOval(
        child: Container(
          height: 40, width: 40,
          color: Colors.white,
          alignment: Alignment.center,
          child: Text(
            notifications.toString(),
            style: TextStyle(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ) : Container();
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
                          Column(
                            children: [
                              BackgroundCard(height: 100,),
                              //infoCompanyWidget(),
                            ],
                          ),
                          bannerURL == null ?
                          Container()
                              :
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              image: DecorationImage(
                                fit: BoxFit.fitWidth,
                                image: NetworkImage(bannerURL),
                              ),
                            ),
                          ),
                          //imageUser(logoURL),
                          imageCircle(),
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
      body: body(),
    );
  }

  Widget body() {
    final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () => menuPresenter.read(menu),
      child: Center(
        child: list == null ?
        LoadingShimmerList()
            :
        list.isEmpty ?
        Stack(
          children: [
            EmptyListWidget(
              message: "Nenhum item foi encontrado",
              //assetsImage: "assets/notification.png",
            ),
            listView(),
          ],
        )
            :
        listView(),
      ),
    );
  }

  Widget listView() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, orderSelected ? 180 : 0),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
                list.map<Widget>((item) {
                  return listItem(item);
                }).toList()
            ),
          ),
        ],
      ),
    );
  }

  Widget listItem(Product item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: ProductWidget(
          item: item,
          onPressed: (value) async {
            var result = await PageRouter.push(context, ProductPage(item: item,));
            if (result != null) {
              //updateOrders();
            }
          },
        ),
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: "Excluir",
            color: Colors.red,
            icon: Icons.delete,
            onTap: () {
              Category categoryProduct;
              menu.categories.forEach((category) {
                category.products.forEach((product) {
                  if (product.name == item.name) {
                    categoryProduct = category;
                    return;
                  }
                });
                if (categoryProduct != null) {
                  return;
                }
              });
              categoryProduct.products.remove(item);
              menuPresenter.update(menu);
            },
          ),
        ],
      ),
    );
  }

  Product adicionar() {

    var item = Item()
      ..name = "100ml"
      ..description = "asdf"
      ..cost = 10.5;

    var item2 = Item()
      ..name = "200ml"
      ..description = "asdf"
      ..cost = 12.5;

    var choice = Choice()
      ..name = "Tamanho"
      ..description = "escolha um tamanho"
      ..required = true
      ..maxQuantity = 1
      ..minQuantity = 1
      ..itens = [item, item2];

    var additional1 = Additional()
      ..name = "Blend"
      ..description = "Carne bolvina 120g"
      ..maxQuantity = 3
      ..cost = 4.0;

    var additional2 = Additional()
      ..name = "Bacon"
    //..description = "Carne bolvina 120g"
      ..maxQuantity = 5
      ..cost = 1.0;

    var product = Product()
      ..id = "0"
      ..name = "Hamburger Super Cheddar"
      ..description = "Pão de hamnúguer, blend bolvino 120g, fatia de cheddar e creme de cheddar."
      ..cost = 12.0
      ..discount = 0
      ..choices = []
      ..additional = [additional1];


    var categoria = Category()
      ..id = "2"
      ..name = "Hamburger"
      ..products = [product];

//    print(product.toMap());
//
//    setState(() {
//      list.add(product);
//    });

    return product;
  }

  Widget infoCompanyWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Flexible(
            flex: 3,
            child: openingCompanyWidget(),
          ),
          Flexible(
            flex: 2,
            child: Container(),
          ),
          Flexible(
            flex: 3,
            child: deliveryCostCompanyWidget(),
          ),
          //openingCompanyWidget(),
          //deliveryCostCompanyWidget(),
        ],
      ),
    );
  }

  Widget openingCompanyWidget() {
    return Container(
      //color: Colors.red,
      alignment: Alignment.center,
      child: Text(
        company.getOpenTime(DateTime.now()),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).errorColor,
        ),
      ),
    );
  }

  Widget deliveryCostCompanyWidget() {
    return Container(
      //color: Colors.green,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[

          company.delivery.pickup ?
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: FaIcon(FontAwesomeIcons.running, size: 16, color: Theme.of(context).errorColor,),
          ) : Container(),

          SizedBox(width: 5,),

          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.motorcycle, size: 16, color: Theme.of(context).errorColor,),
                SizedBox(width: 5,),
                Text(
                  company.delivery.cost == 0 ? "Grátis" : "R\$ ${(company.delivery.cost/100).toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).errorColor,
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  void changeImgUser() async {
    final result = await showOkCancelAlertDialog(
      context: context,
      title: SELECIONE_IMAGEM,
      okLabel: CAMERA,
      cancelLabel: GALERIA,
    );
    var imageSource;
    switch(result) {
      case OkCancelResult.ok:
        imageSource = ImageSource.camera;
        break;
      case OkCancelResult.cancel:
        imageSource = ImageSource.gallery;
        break;
    }
    if (imageSource != null) {
      final file = await ImagePicker.pickImage(source: imageSource);
      if (file != null) {
        var compressedFile = await FlutterNativeImage.compressImage(file.path, percentage: 50);
//        setState(() {
//          _loading = true;
//        });
        await companyPresenter.changeLogoPhoto(compressedFile);
        compressedFile.deleteSync();
      }
    }
  }

  Widget imageCircle() {
    return Container(
      width: 180,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          imageUser(logoURL),
          Align(
            alignment: Alignment.bottomRight,
            child: RawMaterialButton(
              child: Icon(Icons.camera_alt, color: Colors.white,),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: Theme.of(context).primaryColorDark,
              padding: const EdgeInsets.all(10),
              onPressed: () {
                changeImgUser();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget imageUser(String url) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 40, bottom: 10),
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              width: 1,
              color: Theme.of(context).hintColor,
            ),
          ),
          child: url == null ?
          Padding(
            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: Image.asset("assets/logo_app.png"),
          )
              :
          Container(),
        ),
        url == null ? Container() : imageNetworkURL(url),
      ],
    );
  }

  Widget imageNetworkURL(String url) {
    return Container(
      margin: EdgeInsets.only(top: 40),
      child: ImageNetworkWidget(url: url, size: 98,),
    );
  }

  void showDialog() async {
    final result = await showOkCancelAlertDialog(
      context: context,
      title: "Você tem peidos selecionados",
      okLabel: "Limpar",
      cancelLabel: CANCELAR,
      message: "Deseja realmente limpar os pedidos selecionados de ${company.name} ?",
    );
    switch(result) {
      case OkCancelResult.ok:
        Singletons.order().clear();
        PageRouter.pop(context);
        break;
      case OkCancelResult.cancel:
        break;
    }
  }

}