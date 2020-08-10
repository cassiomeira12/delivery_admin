import '../../models/notification/push_notification.dart';
import '../../utils/date_util.dart';
import 'package:flutter/material.dart';

class NotificationWidget extends StatefulWidget {
  final PushNotification notification;
  final VoidCallback onPressed;

  const NotificationWidget({
    this.notification,
    this.onPressed,
  });

  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {

  Color _colorButton, _colorTextButton;

  @override
  void initState() {
    super.initState();
    _colorTextButton = Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        color: Theme.of(context).backgroundColor,
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            widget.notification.title == null ? Container() : titleWidget(),
            widget.notification.message == null ? Container() : messageWidget(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                stateWidget(),
                dataWidget(),
              ],
            ),
          ],
        ),
        onPressed: widget.onPressed,
      ),
    );
  }

  Widget titleWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Text(
        widget.notification.title,
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.bodyText2,
      ),
    );
  }

  Widget messageWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Text(
        widget.notification.message,
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.display4,
      ),
    );
  }

  Widget stateWidget() {
    return Container(
      child: Text(
        widget.notification.getStateName(),
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: widget.notification.denied ?
            Colors.red
              :
            widget.notification.validated ?
              Colors.green
                :
              Colors.black54,
        ),
      ),
    );
  }

  Widget dataWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: Text(
        "${DateUtil.formatDateMouthHour(widget.notification.createdAt)}",
        style: Theme.of(context).textTheme.display2,
      ),
    );
  }

  Widget buttonAction() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        height: 28,
        child: RaisedButton(
          elevation: 1.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: _colorButton == null ? Theme.of(context).buttonColor : _colorButton,
          child: Text(
            "Action",
            style: TextStyle(
              color: _colorTextButton,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            setState(() {
              _colorButton = Colors.white;
              _colorTextButton = Colors.grey;
            });
          },
        ),
      ),
    );
  }

  Widget imageNetworkURL(String url) {
    return Container(
      width: 37,
      height: 37,
      margin: EdgeInsets.only(top: 2, right: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          width: 1,
          color: Theme.of(context).hintColor,
        ),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(url),
        ),
      ),
    );
  }

}

