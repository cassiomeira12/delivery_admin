import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../contracts/company/company_contract.dart';
import '../../contracts/order/order_contract.dart';
import '../../contracts/user/user_contract.dart';
import '../../models/company/company.dart';
import '../../models/order/order.dart';
import '../../models/singleton/singletons.dart';
import '../../presenters/company/company_presenter.dart';
import '../../presenters/order/order_presenter.dart';
import '../../presenters/user/user_presenter.dart';
import '../../services/notifications/firebase_push_notification.dart';
import '../../strings.dart';
import '../../utils/date_util.dart';
import '../../utils/preferences_util.dart';
import '../../views/historico/historic_widget.dart';
import '../../views/home/order_page.dart';
import '../../widgets/empty_list_widget.dart';
import '../../widgets/loading_shimmer_list.dart';
import '../../widgets/scaffold_snackbar.dart';
import '../page_router.dart';

class HomePage extends StatefulWidget {
  final VoidCallback loginCallback;
  final VoidCallback orderCallback;

  HomePage({@required this.loginCallback, @required this.orderCallback});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> implements OrderContractView {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  UserContractPresenter userPresenter;
  CompanyContractPresenter companyPresenter;
  String companyName = "";

  bool _loading = false;
  OrdersPresenter orderPresenter;
  //List<Order> ordersList;

  DateTime dateNow = DateUtil.todayTime(0, 0);

  String filterName;

  double totalToday = 0;

  @override
  void initState() {
    super.initState();
    getFilter();
    userPresenter = UserPresenter(null);
    companyPresenter = CompanyPresenter(null);
    orderPresenter = OrdersPresenter(this);
    if (Singletons.company().id == null) {
      setState(() => _loading = true);
      getCompany();
    } else {
      companyName = Singletons.company().name;
      if (Singletons.orders().isEmpty) {
        setState(() => _loading = true);
        orderPresenter.listDayOrders(dateNow);
      } else {
        listSuccess(Singletons.orders());
      }
      orderPresenter.listDayOrdersSnapshot(dateNow);
    }
  }

  @override
  void dispose() {
    super.dispose();
    userPresenter.dispose();
    companyPresenter.dispose();
    orderPresenter.dispose();
  }

  void getFilter() async {
    int filter = await PreferencesUtil.getOrderFilter();
    if (filter == null) {
      filterName = "Todos";
    } else {
      switch (filter) {
        case 0:
          filterName = "Todos";
          break;
        case 1:
          filterName = "Cozinha";
          break;
        case 2:
          filterName = "Entrega";
          break;
      }
    }
  }

  void getCompany() async {
    Company result = await companyPresenter.getFromAdmin(Singletons.user());
    if (result != null) {
      Singletons.company().updateData(result);
      setState(() => companyName = result.name);
      orderPresenter.listDayOrdersSnapshot(dateNow);
      orderPresenter.listDayOrders(dateNow);
      var companyTopic = result.id;
      if (!Singletons.user().notificationToken.topics.contains(companyTopic)) {
        var saved =
            await FirebasePushNotifications.subscribeToTopic(companyTopic);
        if (saved) {
          Singletons.user().notificationToken.topics.add(companyTopic);
          PreferencesUtil.setUserData(Singletons.user().toMap());
          userPresenter.update(Singletons.user());
        }
      }
    }
  }

  @override
  removeOrder(Order order) {
    try {
      var item =
          Singletons.orders().singleWhere((element) => element.id == order.id);
      setState(() {
        Singletons.orders().remove(item);
      });
    } catch (error) {}
  }

  @override
  listSuccess(List<Order> list) {
    if (Singletons.orders().isNotEmpty) {
      list.forEach((item) {
        var temp;
        for (var element in Singletons.orders()) {
          if (item.id == element.id) {
            temp = element;
            break;
          }
        }
        if (temp == null) {
          setState(() {
            Singletons.orders().insert(0, item);
          });
        } else {
          setState(() {
            temp.updateData(item);
          });
        }
      });
    } else {
      setState(() {
        Singletons.orders().addAll(list);
      });
    }
    calculateTotalToday(list);
    setState(() => _loading = false);
  }

  void calculateTotalToday(List<Order> list) {
    totalToday = 0;
    for (var value in list) {
      double parcialTotal = 0;
      if (!value.canceled && !value.status.isFirst()) {
        parcialTotal += value.deliveryCost;
        value.items.forEach((element) {
          setState(() {
            parcialTotal += element.getTotal();
          });
        });
        if (value.cupon != null) {
          parcialTotal += -value.cupon.calcPercentDiscount(parcialTotal) -
              value.cupon.getMoneyDiscount();
        }
      }
      totalToday += parcialTotal;
    }
  }

  @override
  onFailure(String error) {
    setState(() {
      Singletons.orders().clear();
    });
    ScaffoldSnackBar.failure(context, _scaffoldKey, error);
    setState(() => _loading = false);
  }

  @override
  onSuccess(Order result) {
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          companyName,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return ["Filtro"].map((String choice) {
                return PopupMenuItem(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
            onSelected: (value) async {
              switch (value) {
                case "Filtro":
                  filterOrders();
                  break;
              }
            },
          ),
        ],
      ),
      body: nestedScrollView(),
    );
  }

  void filterOrders() async {
    List<Map> times = List();
    times.add(
      {"key": 0, "title": "Todos"},
    );
    times.add({"key": 1, "title": "Cozinha"});
    times.add({"key": 2, "title": "Entrega/Retirada"});
    times.add({"key": 3, "title": "Finalizados"});
    final result = await showConfirmationDialog<int>(
      context: context,
      title: "Escolha um filtro dos pedidos?",
      okLabel: "Ok",
      cancelLabel: CANCELAR,
      barrierDismissible: false,
      actions: times.map((e) {
        return AlertDialogAction<int>(label: e["title"], key: e["key"]);
      }).toList(),
    );
    if (result != null) {
      PreferencesUtil.setOrderFilter(result);
      switch (result) {
        case 0:
          setState(() => filterName = "Todos");
          break;
        case 1:
          setState(() => filterName = "Cozinha");
          break;
        case 2:
          setState(() => filterName = "Entrega/Retirada");
          break;
        case 3:
          setState(() => filterName = "Finalizados");
      }
      setState(() {
        _loading = true;
        Singletons.orders().clear();
      });
      orderPresenter.unSubscribe();
      await Future.delayed(Duration(milliseconds: 500));
      orderPresenter.listDayOrders(dateNow);
      orderPresenter.listDayOrdersSnapshot(dateNow);
    }
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
                  Container(
                    color: Theme.of(context).primaryColor,
                    padding: EdgeInsets.only(bottom: 10),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        Column(
                          children: [
                            search(),
                            Text(
                              Singletons.company().id != null
                                  ? Singletons.company()
                                      .getOpenCloseTime(day: dateNow)
                                  : "",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).backgroundColor),
                            ),
                            filterName != null
                                ? Text(
                                    "Filtro - $filterName",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(context).backgroundColor),
                                  )
                                : Container(),
                            Text(
                              "Total vendido hoje: R\$: ${totalToday.toStringAsFixed(2)}",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).backgroundColor),
                            ),
                          ],
                        ),
                      ],
                    ),
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

  Widget search() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: RaisedButton(
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Colors.white,
          child: Row(
            children: <Widget>[
              FaIcon(
                FontAwesomeIcons.calendarAlt,
                color: Colors.grey,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  "${DateUtil.getWeekDat(dateNow)} - ${dateNow.day} de ${DateUtil.getMounth(dateNow)}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            showDatePicker(
              context: context,
              initialDate: dateNow,
              firstDate: dateNow.subtract(Duration(days: 365)),
              lastDate: dateNow.add(Duration(days: 365)),
              builder: (BuildContext context, Widget child) {
                return Theme(
                  data: Theme.of(context),
                  child: child,
                );
              },
            ).then((value) {
              if (value != null) {
                orderPresenter.unSubscribe();
                setState(() {
                  _loading = true;
                  dateNow = value;
                  Singletons.orders().clear();
                });
                orderPresenter.listDayOrdersSnapshot(dateNow);
                orderPresenter.listDayOrders(dateNow);
              }
            });
          },
        ),
      ),
    );
  }

  Widget body() {
    final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () {
        setState(() {
          _loading = true;
          Singletons.orders().clear();
        });
        return orderPresenter.listDayOrders(dateNow);
      },
      child: Center(
        child: _loading
            ? LoadingShimmerList()
            : Stack(
                children: [
                  listView(),
                  Singletons.orders().isEmpty
                      ? EmptyListWidget(
                          message: "Você ainda não recebeu pedidos hoje",
                          //assetsImage: "assets/notification.png",
                        )
                      : Container(),
                ],
              ),
      ),
    );
  }

  Widget listView() {
    return ListView(
      children: Singletons.orders().map<Widget>((item) {
        return listItem(item);
      }).toList(),
    );
  }

  Widget listItem(item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: GestureDetector(
          child: HistoricWidget(item: item),
          onTap: () async {
            orderPresenter.unSubscribe();
            var result = await PageRouter.push(
                context,
                OrderPage(
                  item: item,
                ));
            setState(() => item = result);
            orderPresenter.listDayOrdersSnapshot(dateNow);
          },
        ),
      ),
    );
  }
}
