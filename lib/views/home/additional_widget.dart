import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kidelivercompany/views/historico/new_additional_page.dart';

import '../../models/menu/additional.dart';
import '../../strings.dart';
import '../../widgets/count_widget.dart';
import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../page_router.dart';

class AdditionalWidget extends StatefulWidget {
  final List<Additional> additional;
  final ValueChanged<List<Additional>> changedCount;
  final bool editable;

  AdditionalWidget({
    this.additional,
    this.changedCount,
    this.editable = false,
  });

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
              additionalItemWidget(e),
              Divider(color: Colors.grey, height: 0,),
            ],
          );
        }).toList(),
      ),
    );
  }

//  Widget listItem(Additional item) {
//    return Slidable(
//      actionPane: SlidableDrawerActionPane(),
//      actionExtentRatio: 0.25,
//      child: additionalItemWidget(item),
//      secondaryActions: <Widget>[
//        IconSlideAction(
//          caption: DELETAR,
//          color: Colors.red,
//          icon: Icons.delete,
//          onTap: () {
//            setState(() {
//              widget.additional.remove(item);
//            });
//          },
//        ),
//      ],
//    );
//  }

  Widget additionalItemWidget(Additional item) {
    return Container(
      padding: EdgeInsets.all(0),
      child: FlatButton(
        padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
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
                Text(
                  "Max ${item.maxQuantity}",
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.body2,
                ),
                SizedBox(width: 10,),

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
                        widget.additional.remove(item);
                      });
                    },
                  ) : Container(),
              ],
            ),
          ],
        ),
        onPressed: () async {
          if (widget.editable) {
            var result = await PageRouter.push(context, NewAdditionalPage(additional: item,));
            setState(() {
              item = result;
            });
          }
        },
      ),
    );
  }

}
