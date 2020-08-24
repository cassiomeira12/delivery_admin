import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kidelivercompany/widgets/scaffold_snackbar.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../contracts/menu/menu_contract.dart';
import '../../models/company/company.dart';
import '../../models/menu/category.dart';
import '../../models/menu/menu.dart';
import '../../models/menu/product.dart';
import '../../models/singleton/singletons.dart';
import '../../presenters/company/company_presenter.dart';
import '../../presenters/menu/menu_presenter.dart';
import '../../strings.dart';
import '../../views/historico/new_product_page.dart';
import '../../views/home/order_slidding_widget.dart';
import '../../widgets/background_card.dart';
import '../../widgets/empty_list_widget.dart';
import '../../widgets/image_network_widget.dart';
import '../../widgets/loading_shimmer_list.dart';
import '../page_router.dart';
import 'product_page.dart';
import 'product_widget.dart';

class HistoricPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HistoricPageState();
}

class _HistoricPageState extends State<HistoricPage>
    implements MenuContractView {
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Company company;

  CompanyPresenter companyPresenter;
  MenuContractPresenter menuPresenter;

  bool _loading = false;

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
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Cardápio"),
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
        child: nestedScrollView(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          var categorySelect = [
            {"name": "Nova categoria"}
          ];
          menu.categories.forEach((element) {
            categorySelect.add({"name": element.name});
          });
          final categoriesSelected = await showConfirmationDialog<String>(
            context: context,
            title: "Escolha uma categoria",
            okLabel: "Ok",
            cancelLabel: CANCELAR,
            barrierDismissible: false,
            //message: "Deseja sair do $APP_NAME ?",
            actions: categorySelect.map((e) {
              return AlertDialogAction<String>(
                  label: e["name"], key: e["name"]);
            }).toList(),
          );

          if (categoriesSelected != null) {
            if (categoriesSelected == "Nova categoria") {
              var newCategory = await showTextInputDialog(
                context: context,
                textFields: const [
                  DialogTextField(
                    hintText: "Categoria",
                  )
                ],
                title: 'Nova categoria',
                message: 'Digite aqui a nova categoria',
              );
              var category = Category(name: newCategory[0]);
              setState(() {
                menu.categories.add(category);
                _loading = true;
              });
              print(menu.objectId);
              if (menu.objectId == null) {
                menuPresenter.create(menu);
              } else {
                menuPresenter.update(menu);
              }
            } else {
              var newProduct = await PageRouter.push(context, NewProductPage());
              if (newProduct != null) {
                menu.categories.forEach((element) {
                  if (element.name == categoriesSelected) {
                    element.products.add(newProduct);
                    return;
                  }
                });
                setState(() => _loading = true);
                menuPresenter.update(menu);
              }
            }
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
        menu = Menu();
        menu.company = Singletons.company();
        menu.categories = List();
      });
      return;
    }

    List<Product> temp = List();

    list[0].categories.forEach((product) {
      temp.addAll(product.products);
    });

    setState(() {
      _loading = false;
      menu = list[0];
      this.list = temp;
    });
  }

  @override
  onFailure(String error) {
    print(error);
    setState(() {
      _loading = false;
      list = [];
    });
    ScaffoldSnackBar.failure(context, _scaffoldKey, error);
  }

  @override
  onSuccess(Menu result) {
    List<Product> temp = List();
    result.categories.forEach((category) {
      temp.addAll(category.products);
    });
    setState(() {
      _loading = false;
      menu = result;
      this.list = temp;
    });
  }

  Widget notificationCount(int notifications) {
    return notifications > 0
        ? Align(
            //alignment: Alignment.topCenter,
            child: ClipOval(
              child: Container(
                height: 40,
                width: 40,
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
          )
        : Container();
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
                              BackgroundCard(
                                height: 100,
                              ),
                              //infoCompanyWidget(),
                            ],
                          ),
                          bannerURL == null
                              ? Container()
                              : Container(
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
      onRefresh: () {
        setState(() {
          list = null;
        });
        return menuPresenter.read(menu);
      },
      child: Center(
        child: list == null
            ? LoadingShimmerList()
            : Stack(
                children: [
                  listView(),
                  list.isEmpty
                      ? EmptyListWidget(
                          message: "Nenhum item foi encontrado",
                          //assetsImage: "assets/notification.png",
                        )
                      : Container(),
                ],
              ),
      ),
    );
  }

  Widget listView() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(list.map<Widget>((item) {
              return listItem(item);
            }).toList()),
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
            var result = await PageRouter.push(
                context,
                ProductPage(
                  item: item,
                  menu: menu,
                ));
            onSuccess(menu);
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
          company.delivery.pickup
              ? Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.running,
                    size: 16,
                    color: Theme.of(context).errorColor,
                  ),
                )
              : Container(),
          SizedBox(
            width: 5,
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.motorcycle,
                  size: 16,
                  color: Theme.of(context).errorColor,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  company.delivery.cost == 0
                      ? "Grátis"
                      : "R\$ ${(company.delivery.cost / 100).toStringAsFixed(2)}",
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
    switch (result) {
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
        var compressedFile =
            await FlutterNativeImage.compressImage(file.path, percentage: 50);
        setState(() => _loading = true);
        var result = await companyPresenter.changeLogoPhoto(compressedFile);
        setState(() {
          logoURL = result;
          _loading = false;
        });
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
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
              ),
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
          child: url == null
              ? Padding(
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                  child: Image.asset("assets/logo_app.png"),
                )
              : Container(),
        ),
        url == null ? Container() : imageNetworkURL(url),
      ],
    );
  }

  Widget imageNetworkURL(String url) {
    return Container(
      margin: EdgeInsets.only(top: 40),
      child: ImageNetworkWidget(
        url: url,
        size: 98,
      ),
    );
  }

  void showDialog() async {
    final result = await showOkCancelAlertDialog(
      context: context,
      title: "Você tem peidos selecionados",
      okLabel: "Limpar",
      cancelLabel: CANCELAR,
      message:
          "Deseja realmente limpar os pedidos selecionados de ${company.name} ?",
    );
    switch (result) {
      case OkCancelResult.ok:
        Singletons.order().clear();
        PageRouter.pop(context);
        break;
      case OkCancelResult.cancel:
        break;
    }
  }
}
