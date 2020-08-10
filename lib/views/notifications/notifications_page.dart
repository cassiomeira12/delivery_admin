import '../../views/notifications/push_notification_page.dart';
import '../../contracts/notification/push_notification_contract.dart';
import '../../models/notification/push_notification.dart';
import '../../presenters/notification/push_notification_presenter.dart';
import '../../models/singleton/singletons.dart';
import '../../strings.dart';
import '../../views/notifications/notification_widget.dart';
import '../../views/notifications/notifications_settings_page.dart';
import '../../views/page_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NotificationsPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> implements PushNotificationContractView {
  final _formKey = GlobalKey<FormState>();
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  PushNotificationContractPresenter presenter;

  List<PushNotification> notificationsList;

  @override
  void initState() {
    super.initState();
    presenter = PushNotificationPresenter(this);
    //presenter.list();
    presenter.findBy("senderCompany", Singletons.company().toPointer());
  }

  @override
  void dispose() {
    super.dispose();
    presenter.dispose();
  }

  @override
  listSuccess(List<PushNotification> list) {
    setState(() {
      notificationsList = list;
    });
  }

  @override
  onFailure(String error) {
    return null;
  }

  @override
  onSuccess(PushNotification result) {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: _scaffoldKey,
      appBar: AppBar(
        title: Text(TAB2, style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          MaterialButton(
            child: Text(
              CONFIGURAR,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => PageRouter.push(context, NotificationsSettingsPage()),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () {
          Singletons.notifications().clear();
          return presenter.findBy("senderCompany", Singletons.company().toPointer());
        },
        child: Center(
          child: notificationsList == null ?
          showCircularProgress()
              :
          notificationsList.isEmpty ?
          semNotificacoes()
              :
          CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate(
                    notificationsList.map<Widget>((item) {
                      return listItem(item);
                    }).toList()
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white,),
        onPressed: () async {
          //await PageRouter.push(context, NewNotificationPage());
        },
      ),
    );
  }

  Widget listItem(PushNotification item) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: NotificationWidget(
        notification: item,
        onPressed: () {
          PageRouter.push(context, PushNotificationPage(notification: item));
        },
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: DELETAR,
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            setState(() {
              presenter.delete(item);
              notificationsList.remove(item);
            });
          },
        ),
      ],
    );
  }

  Widget showCircularProgress() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }

  Widget semNotificacoes() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 80,
          height: 80,
          child: Image.asset("assets/notification.png"),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 12, 0, 8),
          child: Center(
            child: Text(
              SEM_NOTIFICACOES,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.body2,
            ),
          ),
        )
      ],
    );
  }

}