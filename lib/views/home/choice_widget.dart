import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import '../../models/menu/choice.dart';
import '../../models/menu/item.dart';

class ChoiceWidget extends StatefulWidget {
  final Choice choice;
  Item selectedItem;

  ChoiceWidget(this.choice);

  @override
  _ChoiceWidgetState createState() => _ChoiceWidgetState();
}

class _ChoiceWidgetState extends State<ChoiceWidget> {
  @override
  Widget build(BuildContext context) {
    return StickyHeader(
      header: Container(
        height: 50,
        color: Colors.grey[200],
        padding: EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Text(
              "${widget.choice.name}",
            ),
            widget.choice.required ?
              Text(
                "*",
                style: TextStyle(
                  color: Colors.red,
                ),
              ) : Container(),
          ],
        ),
      ),
      content: Column(
        children: widget.choice.itens.map((e) {
          return Column(
            children: [
              choiceItemWidget(e),
              Divider(color: Colors.grey, height: 0,),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget choiceItemWidget(Item item) {
    return FlatButton(
      padding: EdgeInsets.fromLTRB(10, 2.5, 0, 2.5),
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
              item.cost != null ?
              Text(
                "R\$ ${item.cost.toStringAsFixed(2)}",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                ),
              ) : Container(),
              Radio(
                value: item,
                groupValue: widget.selectedItem,
                activeColor: Theme.of(context).primaryColor,
                toggleable: true,
                onChanged: (value) {
                  if (widget.selectedItem != null && widget.selectedItem == item) {
                    setState(() {
                      widget.selectedItem = null;
                    });
                  } else {
                    setState(() {
                      widget.selectedItem = item;
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
      onPressed: () {
        if (widget.selectedItem != null && widget.selectedItem == item) {
          setState(() {
            widget.selectedItem = null;
          });
        } else {
          setState(() {
            widget.selectedItem = item;
          });
        }
      },
    );
  }

}
