import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import '../../models/menu/choice.dart';
import '../../models/menu/item.dart';

class ChoiceWidget extends StatefulWidget {
  final Choice choice;
  final bool editable;
  Item selectedItem;

  ChoiceWidget(this.choice, {this.editable = false});

  @override
  _ChoiceWidgetState createState() => _ChoiceWidgetState();
}

class _ChoiceWidgetState extends State<ChoiceWidget> {
  @override
  Widget build(BuildContext context) {
    return StickyHeader(
      header: Container(
        color: Colors.grey[200],
        padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "${widget.choice.name}",
                  style: Theme.of(context).textTheme.body1,
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
            widget.choice.description != null ?
              Text(
                widget.choice.description,
                style: Theme.of(context).textTheme.body2,
              )
                  :
              Container(),
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
      padding: EdgeInsets.fromLTRB(10, 2.5, 10, 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FaIcon(
                      item.visible ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
                      size: 20,
                      color: Colors.black45,
                    ),
                    SizedBox(width: 5,),
                    Expanded(
                      child: Text(
                        item.name,
                        style: Theme.of(context).textTheme.body1,
                      ),
                    ),
                  ],
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
              widget.editable ?
               GestureDetector(
                 child: Container(
                   padding: EdgeInsets.only(left: 20, right: 20),
                   child: FaIcon(FontAwesomeIcons.trashAlt,),
                 ),
                 onTap: () {
                   setState(() {
                     widget.choice.itens.remove(item);
                   });
                 },
               ) : Container(),
            ],
          ),
        ],
      ),
//      onPressed: () {
//        print("1");
//        if (widget.selectedItem != null && widget.selectedItem == item) {
//          setState(() {
//            widget.selectedItem = null;
//          });
//        } else {
//          setState(() {
//            widget.selectedItem = item;
//          });
//        }
//      },
    );
  }

}
