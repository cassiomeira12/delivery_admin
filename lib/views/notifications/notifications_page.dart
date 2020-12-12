import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../contracts/notification/push_notification_contract.dart';
import '../../models/notification/push_notification.dart';
import '../../models/singleton/singletons.dart';
import '../../presenters/notification/push_notification_presenter.dart';
import '../../strings.dart';
import '../../views/notifications/notification_widget.dart';
import '../../views/notifications/notifications_settings_page.dart';
import '../../views/notifications/push_notification_page.dart';
import '../../views/page_router.dart';
import '../../widgets/scaffold_snackbar.dart';
import 'new_notification_page.dart';

class NotificationsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    implements PushNotificationContractView {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool _loading = false;

  PushNotificationContractPresenter presenter;

  List<PushNotification> notificationsList;

  @override
  void initState() {
    super.initState();
    presenter = PushNotificationPresenter(this);
    listNotifications();
  }

  listNotifications() {
    if (kDebugMode) {
      return presenter.list();
    } else {
      return presenter.findBy(
        "senderCompany",
        Singletons.company().toPointer(),
      );
    }
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
    setState(() => _loading = false);
    ScaffoldSnackBar.failure(context, _scaffoldKey, error);
  }

  @override
  onSuccess(PushNotification result) {
    setState(() => _loading = false);
    ScaffoldSnackBar.success(context, _scaffoldKey, SUCCESS_UPDATE_DATA);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          TAB2,
          style: TextStyle(color: Colors.white),
        ),
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
            onPressed: () =>
                PageRouter.push(context, NotificationsSettingsPage()),
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        progressIndicator: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: CircularProgressIndicator(),
          ),
        ),
        child: body(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          var result = await PageRouter.push(context, NewNotificationPage());
          if (result != null) {
            setState(() {
              notificationsList.add(result);
            });
          }
        },
      ),
    );
  }

  Widget body() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () {
        Singletons.notifications().clear();
        return listNotifications();
      },
      child: Center(
        child: notificationsList == null
            ? showCircularProgress()
            : Stack(
                children: [
                  CustomScrollView(
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildListDelegate(
                            notificationsList.map<Widget>((item) {
                          return Padding(
                            padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
                            child: listItem(item),
                          );
                        }).toList()),
                      ),
                    ],
                  ),
                  notificationsList.isEmpty ? semNotificacoes() : Container(),
                ],
              ),
      ),
    );
  }

  Widget listItem(PushNotification item) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: NotificationWidget(
        notification: item,
        onPressed: () async {
          await PageRouter.push(
            context,
            PushNotificationPage(notification: item),
          );
          listNotifications();
        },
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: DELETAR,
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            showDialogDeleteItem(item);
          },
        ),
      ],
    );
  }

  void showDialogDeleteItem(PushNotification item) async {
    final result = await showOkCancelAlertDialog(
      context: context,
      title: DELETAR,
      okLabel: DELETAR,
      cancelLabel: CANCELAR,
      message: "Deseja realmente deletar essa notificação?",
    );
    switch (result) {
      case OkCancelResult.ok:
        setState(() => _loading = true);
        setState(() {
          presenter.delete(item);
          notificationsList.remove(item);
        });
        break;
      case OkCancelResult.cancel:
        break;
    }
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
