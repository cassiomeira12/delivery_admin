import 'package:sembast/sembast.dart';

import '../../models/order/order.dart';
import '../../utils/date_util.dart';
import '../../widgets/stars_widget.dart';
import 'package:flutter/material.dart';
import '../page_router.dart';
import '../home/order_page.dart';

class HistoricWidget extends StatefulWidget {
  final dynamic item;

  HistoricWidget({
    this.item
  });

  @override
  _HistoricWidgetState createState() => _HistoricWidgetState();
}

class _HistoricWidgetState extends State<HistoricWidget> {

  Order order;

  double total = 0;

  @override
  void initState() {
    super.initState();
    order = widget.item as Order;
    total = order.deliveryCost;
    order.items.forEach((element) {
      total += element.getTotal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(5, 5, 5, 10),
      elevation: 5,
      shadowColor: order.status.isFirst() ? Colors.green : Colors.white,
      color: order.status.isFirst() ? Colors.green[50] : Colors.white,
      borderOnForeground: true,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                titleTextWidget(order.userName),
                dateTextWidget(DateUtil.formatDateCalendar(order.createdAt)),
              ],
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                order.evaluation == null ? Text(order.status.current.name) : StarsWidget(initialStar: order.evaluation.stars, size: 30,),
                costTextWidget("R\$ ${total.toStringAsFixed(2)}"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget titleTextWidget(String text) {
    return Flexible(
      child: Text(
        text,
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
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

  Widget costTextWidget(String text) {
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

}
