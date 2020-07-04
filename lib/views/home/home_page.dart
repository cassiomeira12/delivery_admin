import 'package:delivery_admin/contracts/user/user_contract.dart';
import 'package:delivery_admin/models/company/company.dart';
import 'package:delivery_admin/presenters/user/user_presenter.dart';
import 'package:delivery_admin/services/notifications/firebase_push_notification.dart';
import 'package:delivery_admin/utils/preferences_util.dart';

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

  UserContractPresenter userPresenter;
  CompanyContractPresenter companyPresenter;
  String companyName = "";

  OrdersPresenter orderPresenter;
  List<Order> ordersList;
  
  @override
  void initState() {
    super.initState();
    userPresenter = UserPresenter(null);
    companyPresenter = CompanyPresenter(null);
    orderPresenter = OrdersPresenter(this);
    if (Singletons.company().id == null) {
      getCompany();
    } else {
      companyName = Singletons.company().name;
      orderPresenter.listTodayOrders();
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
      orderPresenter.listTodayOrders();
      var companyTopic = result.id;
      if (!Singletons.user().notificationToken.topics.contains(companyTopic)) {
        var saved = await FirebaseNotifications.subscribeToTopic(companyTopic);
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
    if (ordersList != null && ordersList.isNotEmpty) {
      list.forEach((item) {
        var temp = ordersList.singleWhere((element) => element.id == item.id, orElse: null);
        setState(() {
          if (temp == null) {
            setState(() {
              ordersList.insert(0, item);
            });
          } else {
            setState(() {
              temp.updateData(item);
            });
          }
        });
      });
    } else {
      setState(() {
        ordersList = list;
      });
      Singletons.orders().addAll(list);
    }
  }

  @override
  onFailure(String error)  {
    print(error);
  }

  @override
  onSuccess(Order result) {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: _scaffoldKey,
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
                          BackgroundCard(height: 100,),
                          search(),
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
              Icon(Icons.search, color: Colors.grey,),
              SizedBox(width: 10,),
              Text(
                "Pesquise aqui",
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.grey,
                  //fontWeight: FontWeight.bold,
                )
              )
            ],
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchPage()));
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
        setState(() => ordersList = null);
        return orderPresenter.listTodayOrders();
      },
      child: Center(
        child: ordersList == null ?
          LoadingShimmerList()
            :
          ordersList.isEmpty ?
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
      children: ordersList.map<Widget>((item) {
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