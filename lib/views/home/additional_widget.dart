import 'package:flutter_slidable/flutter_slidable.dart';

import '../../models/menu/additional.dart';
import '../../strings.dart';
import '../../widgets/count_widget.dart';
import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class AdditionalWidget extends StatefulWidget {
  final List<Additional> additional;
  final ValueChanged<List<Additional>> changedCount;

  AdditionalWidget({this.additional, this.changedCount});

  @override
  _AdditionalWidgetState createState() => _AdditionalWidgetState();
}

class _AdditionalWidgetState extends State<AdditionalWidget> {

  @override
  Widget build(BuildContext context) {
    return StickyHeader(
      header: widget.additional.length > 0 ?
      Container(
        height: 50,
        color: Colors.grey[200],
        padding: EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Text(
              "Adicionais",
            ),
          ],
        ),
      ) : Container(),
      content: Column(
        children: widget.additional.map((e) {
          return Column(
            children: [
              listItem(e),
              Divider(color: Colors.grey, height: 0,),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget listItem(Additional item) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: additionalItemWidget(item),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: DELETAR,
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            setState(() {
              widget.additional.remove(item);
            });
          },
        ),
      ],
    );
  }

  Widget additionalItemWidget(Additional item) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 15, 0, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.body1,
                ),
                item.description != null ?
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.body2,
                ) : Container(),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                "Max ${item.maxQuantity}",
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.body2,
              ),
              SizedBox(width: 10,),
              Text(
                "R\$ ${ item.amount == 0 ? item.cost.toStringAsFixed(2) : (item.amount * item.cost).toStringAsFixed(2)}",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 10,),
            ],
          ),
        ],
      ),
    );
  }

}
