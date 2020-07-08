import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:delivery_admin/widgets/scaffold_snackbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../strings.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../contracts/order/order_contract.dart';
import '../../models/address/address.dart';
import '../../models/order/order.dart';
import '../../models/order/order_item.dart';
import '../../models/order/order_status.dart';
import '../../presenters/order/order_presenter.dart';
import '../../utils/date_util.dart';
import '../../widgets/stars_widget.dart';
import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  final dynamic item;

  OrderPage({
    this.item,
  });

  @override
  State<StatefulWidget> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> implements OrderContractView {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  OrderContractPresenter presenter;

  Order order;
  double total = 0;

  List<Widget> ordersItems;
  int currentStatusIndex = 0;
  List<Widget> statusItems = List();

  String title = "";

  @override
  void initState() {
    super.initState();
    presenter = OrdersPresenter(this);
    order = widget.item as Order;
    title = order.id;
    total = order.deliveryCost;
    order.items.forEach((element) {
      total += element.getTotal();
    });
    ordersItems = order.items.map((e) => orderItem(e)).toList();
    int index = 0;
    order.status.values.forEach((element) {
      if (element.name == order.status.current.name) {
        currentStatusIndex = index;
        return;
      }
      index++;
    });
  }

  @override
  listSuccess(List<Order> list) {

  }

  @override
  onFailure(String error)  {
    print(error);
  }

  @override
  onSuccess(Order result) {
    order.updateData(result);
    int index = 0;
    order.status.values.forEach((element) {
      if (element.name == order.status.current.name) {
        setState(() {
          currentStatusIndex = index;
        });
        return;
      }
      index++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.whatsapp,),
            onPressed: () async {
              var whatsAppLink = order.userPhoneNumber.whatsAppLink();
              if (await canLaunch(whatsAppLink)) {
                await launch(whatsAppLink);
              } else {
                ScaffoldSnackBar.failure(context, _scaffoldKey, SOME_ERROR);
              }
            },
          ),
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return ["Cancelar"].map((String choice) {
                return PopupMenuItem(value: choice, child: Text(choice),);
              }).toList();
            },
            onSelected: (value) async {
              switch (value) {
                case "Cancelar":
                  showDialogCancelOrder();
                  break;
              }
            },
          ),
        ],
      ),
      body: nestedScrollView(),
    );
  }

  void showDialogCancelOrder() async {
    final result = await showOkCancelAlertDialog(
      context: context,
      title: CANCELAR,
      okLabel: CANCELAR,
      cancelLabel: "Fechar",
      message: "Deseja realmente cancelar esse pedido?",
    );
    switch(result) {
      case OkCancelResult.ok:
        setState(() => order.canceled = true);
        presenter.update(order);
        break;
      case OkCancelResult.cancel:
        break;
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
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      nestedHeader(),
                    ],
                  ),
                ],
              ),
            ]),
          ),
        ];
      },
      body: order.status.isFirst() ? Container() : body(),
    );
  }

  Widget nestedHeader() {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: titleTextWidget(order.userName),
                ),
                dateTextWidget(DateUtil.formatDateMouthHour(order.createdAt)),
              ],
            ),
            SizedBox(height: 5,),
            Column(children: ordersItems,),
            textDelivery(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                totalTextWidget(),
                costTextWidget("R\$ ${total.toStringAsFixed(2)}"),
              ],
            ),
            textPaymentType(),
            addressDataWidget(order.deliveryAddress),
            SizedBox(height: 10,),
            order.status.isLast() && order.evaluation != null ?
            Column(
              children: [
                avaliationTextWidget(),
                StarsWidget(initialStar: order.evaluation.stars, size: 40,),
                avaliationComenteTextWidget(),
              ],
            ) : Container(),
            deliveryCurrentStatus(),
          ],
        ),
      ),
    );
  }

  Widget deliveryCurrentStatus() {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        children: [
          order.canceled ?
            orderCanceled()
              :
            Column(
              children: [
                order.status.isFirst() ?
                PrimaryButton(
                  text: CONFIRMAR,
                  onPressed: () async {
                    List<Map> times = List();
                    times.add({"hour": 0, "minute": 0, "key": 0, "message": "Está pronto"},);
                    times.add({"hour": 0, "minute": 5, "key": 1, "message": "Daqui 5 minutos"});
                    times.add({"hour": 0, "minute": 10, "key": 2, "message": "Daqui 10 minutos"});
                    times.add({"hour": 0, "minute": 15, "key": 3, "message": "Daqui 15 minutos"});
                    times.add({"hour": 0, "minute": 30, "key": 4, "message": "Daqui 30 minutos"});
                    times.add({"hour": 0, "minute": 45, "key": 5, "message": "Daqui 45 minutos"});
                    times.add({"hour": 1, "minute": 0, "key": 6, "message": "Daqui 1 hora"});
                    times.add({"hour": 1, "minute": 15, "key": 7, "message": "Daqui 1 hora e 15 minutos"});
                    times.add({"hour": 1, "minute": 30, "key": 8, "message": "Daqui 1 hora e 30 minutos"});
                    times.add({"hour": 1, "minute": 45, "key": 9, "message": "Daqui 1 hora e 45 minutos"});
                    times.add({"hour": 2, "minute": 0, "key": 10, "message": "Daqui 2 horas"});
                    times.add({"hour": -1, "minute": -1, "key": 11, "message": "Escolher horário"});
                    final result = await showConfirmationDialog<int>(
                      context: context,
                      title: "Quando o pedido ficará pronto?",
                      okLabel: "Ok",
                      cancelLabel: CANCELAR,
                      barrierDismissible: false,
                      actions: times.map((e) {
                        return AlertDialogAction<int>(
                            label: e["message"],
                            key: e["key"]
                        );
                      }).toList(),
                    );
                    if (result != null) {
                      var now = DateTime.now();
                      int hour = now.hour;
                      int minute = now.minute;

                      if (result == 1) {
                        order.items.forEach((element) {
                          if (element.preparationTime != null) {
                            if ((minute + element.preparationTime.minute) > 59) {
                              hour += element.preparationTime.hour + 1;
                              minute = (minute + element.preparationTime.minute) - 60;
                            } else {
                              minute += element.preparationTime.minute;
                            }
                            if (hour > 23) {
                              hour = 0;
                            } else {
                              hour += element.preparationTime.hour;
                            }
                          }
                        });
                        order.deliveryForecast = DeliveryForecast();
                        order.deliveryForecast.hour = hour;
                        order.deliveryForecast.minute = minute;

                        order.status.values[1].date = DateTime.now();
                        setState(() {
                          order.status.current = order.status.values[1];
                        });
                        presenter.update(order);
                      } else if (result == 11) {
                        order.items.forEach((element) {
                          if (element.preparationTime != null) {
                            if ((minute + element.preparationTime.minute) > 59) {
                              hour += element.preparationTime.hour + 1;
                              minute = (minute + element.preparationTime.minute) - 60;
                            } else {
                              minute += element.preparationTime.minute;
                            }
                            if (hour > 23) {
                              hour = 0;
                            } else {
                              hour += element.preparationTime.hour;
                            }
                          }
                        });
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(hour: hour, minute: minute),
                        ).then((value) {
                          if (value != null) {
                            order.deliveryForecast = DeliveryForecast();
                            order.deliveryForecast.hour = value.hour;
                            order.deliveryForecast.minute = value.minute;

                            order.status.values[1].date = DateTime.now();
                            setState(() {
                              order.status.current = order.status.values[1];
                            });
                            presenter.update(order);
                          }
                        });
                      } else {
                        if ((minute + times[result]["minute"]) > 59) {
                          hour += times[result]["hour"] + 1;
                          minute = (minute + times[result]["minute"]) - 60;
                        } else {
                          minute += times[result]["minute"];
                        }
                        if (hour > 23) {
                          hour = 0;
                        } else {
                          hour += times[result]["hour"];
                        }

                        order.deliveryForecast = DeliveryForecast();
                        order.deliveryForecast.hour = hour;
                        order.deliveryForecast.minute = minute;

                        order.status.values[1].date = DateTime.now();
                        setState(() {
                          order.status.current = order.status.values[1];
                        });
                        presenter.update(order);
                      }
                    }
                  },
                ) : Column(
                  children: [
                    Text(
                      "Previsão de entrega",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.black45,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10,),
                    Text(
                      order.deliveryForecast.toString(),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 35,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget textDelivery() {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Taxa de entrega",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 20,
              color: Colors.black45,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "R\$ ${order.deliveryCost.toStringAsFixed(2)}",
            textAlign: TextAlign.left,
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

  Widget textPaymentType() {
    return Padding(
      padding: EdgeInsets.only(top: 15, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 1,
            child: AutoSizeText(
              order.typePayment.getType(),
              maxLines: 1,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black45,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            order.changeMoney == null ? "Sem troco" : order.changeMoney,
            textAlign: TextAlign.left,
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

  Widget orderCanceled() {
    return Text(
      "Esse pedido foi cancelado",
      style: TextStyle(
        fontSize: 22,
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget orderItem(OrderItem item) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${item.amount}x ${item.name}",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black45,
                ),
              ),
              Text(
                "R\$ ${item.getTotal().toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
          ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: item.choicesSelected.map((choice) {
              return Text(
                "* $choice",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black45,
                  //fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
          ),
          ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: item.additionalSelected.map((additional) {
              return Text(
                "+ ${additional.amount} ${additional.name} R\$ ${(additional.amount * additional.cost).toStringAsFixed(2)}",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black45,
                  //fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
          ),
          item.note.isNotEmpty ?
          Text(
            item.note,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              //fontWeight: FontWeight.bold,
            ),
          ) : Container(),
        ],
      ),
    );
  }

  Widget body() {
    final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () => presenter.read(order),
      child: listView(),
    );
  }

  Widget listView() {
    int index = 0;
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              order.status.values.map((e) {
                return timelineItem(e, index++);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget timelineItem(Status status, int index) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineX: 0.1,
      isFirst: index == 0,
      isLast: index == (order.status.values.length-1),
      indicatorStyle: IndicatorStyle(
        width: 20,
        color: currentStatusIndex > index ? Colors.grey : currentStatusIndex == index ? Colors.green : Colors.grey[300],
        padding: EdgeInsets.all(6),
      ),
      rightChild: Container(
        margin: EdgeInsets.only(left: 10, right: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SecondaryButton(
              child: AutoSizeText(
                status.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  color: this.currentStatusIndex > index ?
                  Colors.grey[500]
                      :
                  this.currentStatusIndex == index ?
                  Colors.green
                      :
                  this.currentStatusIndex + 1 == index ?
                  Colors.black54
                      :
                  Colors.grey[300],
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                if (currentStatusIndex + 1 == index) {
                  setState(() {
                    currentStatusIndex++;
                    order.status.values[currentStatusIndex].date = DateTime.now();
                    order.status.current = order.status.values[currentStatusIndex];
                    presenter.update(order);
                  });
                }
              },
            ),
            SizedBox(height: 5,),
            status.date != null ?
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Text(
                DateUtil.formatDateMouthHour(status.date),
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black38,
                    fontWeight: FontWeight.bold
                ),
              ),
            ) : Container(),
          ],
        ),
      ),
      topLineStyle: const LineStyle(
        color: Color(0xFFDADADA),
      ),
    );
  }

  Widget titleTextWidget(String text) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 25,
          color: Colors.black45,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget dateTextWidget(String text) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 18,
          color: Colors.black45,
        ),
      ),
    );
  }

  Widget totalTextWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Text(
        "Total",
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 25,
          color: Colors.black45,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget addressDataWidget(Address address) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(top: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: order.delivery ? FaIcon(FontAwesomeIcons.motorcycle,) : FaIcon(FontAwesomeIcons.running,),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 5, right: 10),
                      child: Text(
                        order.delivery ? "Endereço de entrega" : "Endereço de retirada",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5, right: 10),
                      child: Text(
                        "${address.street}" + (address.number == null ? "" : ", ${address.number}"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    address.neighborhood != null ? Padding(
                      padding: EdgeInsets.only(top: 5, right: 10),
                      child: Text(
                        address.neighborhood,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ) : Container(),
                    address.reference != null ? Padding(
                      padding: EdgeInsets.only(top: 5, right: 10),
                      child: Text(
                        address.reference,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black38,
                        ),
                      ),
                    ) : Container(),
                    order.note != null && order.note.isNotEmpty ?
                    Padding(
                      padding: EdgeInsets.only(top: 5, right: 10),
                      child: Text(
                        order.note,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ) : Container(),
                    SizedBox(height: 10,),
                  ],
                ),
              ],
            ),
            order.deliveryAddress.location != null ?
            GestureDetector(
              child: Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                ),
                child: Text(
                  "Abrir o Mapa",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              onTap: () async {
                var address = order.deliveryAddress;
                if (address != null) {
                  MapsLauncher.launchCoordinates(address.location.latitude, address.location.longitude);
                } else {
                  ScaffoldSnackBar.failure(context, _scaffoldKey, SOME_ERROR);
                }
              },
            ) : Container(),
          ],
        ),
      ),
    );
  }

  Widget costTextWidget(String text) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 25,
          color: Colors.black45,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget avaliationTextWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Text(
        "Avaliação",
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 25,
          color: Colors.black45,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget avaliationComenteTextWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Text(
        order.evaluation.comment,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 25,
          color: Colors.black45,
        ),
      ),
    );
  }

  Widget statusItemList(Status status, int index) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
      child: Row(
        children: [
          Container(
            width: 50,
            //height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 3,
                  height: 80,
                  color: Colors.grey[350],
                ),
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: this.currentStatusIndex > index ? Colors.grey[350] : this.currentStatusIndex == index ? Colors.green : Colors.grey[300],
                    borderRadius: BorderRadius.all(
                      Radius.circular(25),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10, right: 30),
                  child: SecondaryButton(
                    child: AutoSizeText(
                      status.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        color: this.currentStatusIndex > index ?
                        Colors.grey[500]
                            :
                        this.currentStatusIndex == index ?
                        Colors.green
                            :
                        this.currentStatusIndex + 1 == index ?
                        Colors.black54
                            :
                        Colors.grey[300],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      if (currentStatusIndex + 1 == index) {
                        setState(() {
                          currentStatusIndex++;
                          order.status.values[currentStatusIndex].date = DateTime.now();
                          order.status.current = order.status.values[currentStatusIndex];
                          presenter.update(order);
                        });
                      }
                    },
                  ),
                ),
                status.date != null ?
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Text(
                    DateUtil.formatHourMinute(status.date),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black45,
                    ),
                  ),
                ) : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

}