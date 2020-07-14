import 'package:delivery_admin/utils/date_util.dart';
import 'package:delivery_admin/utils/log_util.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../contracts/user/user_contract.dart';
import '../../models/company/company.dart';
import '../../presenters/user/user_presenter.dart';
import '../../services/notifications/firebase_push_notification.dart';
import '../../utils/preferences_util.dart';
import '../../widgets/scaffold_snackbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/singleton/singletons.dart';
import '../../contracts/order/order_contract.dart';
import '../../models/order/order.dart';
import '../../presenters/order/order_presenter.dart';
import '../../views/home/order_page.dart';
import '../../views/historico/historic_widget.dart';
import '../../contracts/company/company_contract.dart';
import '../../presenters/company/company_presenter.dart';
import '../../widgets/empty_list_widget.dart';
import '../../widgets/loading_shimmer_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../widgets/background_card.dart';
import '../page_router.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback loginCallback;
  final VoidCallback orderCallback;

  HomePage({
    @required this.loginCallback,
    @required this.orderCallback
  });

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

  static DateTime date = DateUtil.todayTime(0, 0);
  
  @override
  void initState() {
    super.initState();
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
        orderPresenter.listDayOrdersSnapshot(date);
        orderPresenter.listDayOrders(date);
      } else {
        listSuccess(Singletons.orders());
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    userPresenter.dispose();
    companyPresenter.dispose();
    orderPresenter.dispose();
  }

  void getCompany() async {
    Company result = await companyPresenter.getFromAdmin(Singletons.user());
    if (result != null) {
      Singletons.company().updateData(result);
      setState(() => companyName = result.name);
      orderPresenter.listDayOrdersSnapshot(date);
      orderPresenter.listDayOrders(date);
      var companyTopic = result.id;
      if (!Singletons.user().notificationToken.topics.contains(companyTopic)) {
        var saved = await FirebasePushNotifications.subscribeToTopic(companyTopic);
        if (saved) {
          Singletons.user().notificationToken.topics.add(companyTopic);
          PreferencesUtil.setUserData(Singletons.user().toMap());
          userPresenter.update(Singletons.user());
        }
      }
    }
  }

  @override
  listSuccess(List<Order> list) {
    if (Singletons.orders().isNotEmpty) {
      list.forEach((item) {
        var temp;
        for (var element in Singletons.orders()) {
          print("${item.id} - ${element.id}");
          if (item.id == element.id) {
            temp = element;
            break;
          }
        }
        print("passou");
        print(item);
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
    setState(() => _loading = false);
  }

  @override
  onFailure(String error)  {
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
        title: Text(companyName, style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: nestedScrollView(),
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
                          BackgroundCard(height: 120,),
                          Column(
                            children: [
                              search(),
                              Text(
                                Singletons.company().getOpenTime(date),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).backgroundColor
                                ),
                              ),
                            ],
                          ),
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

  Widget search() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: RaisedButton(
          elevation: 5.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),
          color: Colors.white,
          child: Row(
            children: <Widget>[
              FaIcon(FontAwesomeIcons.calendarAlt, color: Colors.grey,),
              SizedBox(width: 10,),
              Flexible(
                flex: 1,
                child: Text(
                  "Pedidos ${DateUtil.getWeekDat(date)} - ${date.day} de ${DateUtil.getMounth(date)}",
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
              initialDate: date,
              firstDate: date.subtract(Duration(days: 365)),
              lastDate: date.add(Duration(days: 365)),
              builder: (BuildContext context, Widget child) {
                return Theme(data: Theme.of(context), child: child,);
              },
            ).then((value) {
              if (value != null) {
                orderPresenter.unSubscribe();
                setState(() {
                  _loading = true;
                  date = value;
                  Singletons.orders().clear();
                });
                orderPresenter.listDayOrdersSnapshot(date);
                orderPresenter.listDayOrders(date);
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
        return orderPresenter.listDayOrders(date);
      },
      child: Center(
        child: _loading ?
          LoadingShimmerList()
            :
          Singletons.orders().isEmpty ?
            EmptyListWidget(
              message: "Nenhum pedido foi encontrado",
              //assetsImage: "assets/notification.png",
            )
              :
            listView(),
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
          child: HistoricWidget(
            item: item,
          ),
          onTap: () async {
            orderPresenter.pause();
            await PageRouter.push(context, OrderPage(item: item,));
            orderPresenter.resume();
          },
        ),
      ),
    );
  }

}