import 'package:delivery_admin/contracts/order/order_contract.dart';
import 'package:delivery_admin/models/order/order.dart';
import 'package:delivery_admin/models/singleton/company_singleton.dart';
import 'package:delivery_admin/models/singleton/order_singleton.dart';
import 'package:delivery_admin/models/singleton/user_singleton.dart';
import 'package:delivery_admin/presenters/order/order_presenter.dart';
import 'package:delivery_admin/utils/log_util.dart';
import 'package:delivery_admin/views/home/order_page.dart';
import 'package:delivery_admin/views/historico/historic_widget.dart';

import '../../contracts/company/company_contract.dart';
import '../../models/company/company.dart';
import '../../presenters/company/company_presenter.dart';
import '../../views/home/company_widget.dart';
import '../../widgets/empty_list_widget.dart';
import '../../widgets/loading_shimmer_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../strings.dart';
import '../../widgets/background_card.dart';

import '../page_router.dart';
import 'company_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback orderCallback;

  HomePage({
    @required this.orderCallback
  });

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> implements OrderContractView {
  final _formKey = GlobalKey<FormState>();

  CompanyContractPresenter companyPresenter;
  String companyName = "";

  OrdersPresenter orderPresenter;
  List<Order> ordersList = List();
  
  @override
  void initState() {
    super.initState();
    companyPresenter = CompanyPresenter(null);
    orderPresenter = OrdersPresenter(this);
    if (CompanySingleton.instance.id == null) {
      getCompany();
    } else {
      companyName = CompanySingleton.instance.name;
      orderPresenter.listTodayOrders();
    }
  }

  @override
  void dispose() {
    super.dispose();
    companyPresenter.dispose();
    orderPresenter.dispose();
  }

  void getCompany() async {
    CompanySingleton.instance.id = UserSingleton.instance.companyId;
    var result = await companyPresenter.read(CompanySingleton.instance);
    CompanySingleton.instance.update(result);
    setState(() {
      companyName = result.name;
    });
    orderPresenter.listTodayOrders();
  }

  @override
  listSuccess(List<Order> list) {
    print("update list");
//    print("antes");
//    ordersList.forEach((element) {
//      print(element.companyName);
//    });
    var temp = ordersList;
    list.forEach((element) {
      temp.removeWhere((item) => item.id == element.id);
    });
//    print("depois");
//    temp.forEach((element) {
//      print(element.companyName);
//    });
    temp.insertAll(0, list);
    setState(() {
      ordersList = temp;
    });
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
        return companyPresenter.list();
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