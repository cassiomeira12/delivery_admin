import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kideliver_admin/contracts/notification/push_notification_contract.dart';
import 'package:kideliver_admin/models/notification/push_notification.dart';
import 'package:kideliver_admin/widgets/secondary_button.dart';
import '../../models/singleton/singletons.dart';
import '../../widgets/area_input_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/text_input_field.dart';
import '../../strings.dart';
import 'package:flutter/material.dart';

class NewNotificationPage extends StatefulWidget {

  @override
  _NewNotificationPageState createState() => _NewNotificationPageState();
}

class _NewNotificationPageState extends State<NewNotificationPage> implements PushNotificationContractView {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController titleController;
  String title, message, observacao, imgURL, data;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: Singletons.company().name);
//    message = widget.notification.message;
//    observacao = widget.notification.observacao;
//    imgURL = widget.notification.avatarURL;
//    data = DateUtil.formatDateMonth(widget.notification.createdAt);
//
//    if (!widget.notification.read) {
//      widget.notification.read = true;
//      updateNotification();
//    }
  }

  void updateNotification() async {
//    UserNotification temp = await widget.presenter.update(widget.notification);
////    if (temp != null) {
////      setState(() {
////        //widget.notification.updateData(temp);
////      });
////    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Nova notificação", style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            textTitleWidget(),
            textMessageWidget(),
            topic(),
            testButton(),
            sendButton(),
          ],
        ),
      ),
    );
  }

  Widget textTitleWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: Center(
        child: TextInputField(
          labelText: "Título",
          enable: false,
          controller: titleController,
        ),
      ),
    );
  }

  Widget textMessageWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: Center(
        child: AreaInputField(
          labelText: "Mensagem",
          maxLines: 5,
          onChanged: (value) => message = value,
        ),
      ),
    );
  }

  Widget topic() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: RaisedButton(
          elevation: 2,
          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    //FaIcon(FontAwesomeIcons.searchLocation, color: Colors.grey,),
                    SizedBox(width: 10,),
                    Flexible(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tópico",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              FaIcon(FontAwesomeIcons.caretDown, color: Colors.grey[400], ),
            ],
          ),
          onPressed: () async {
            var topics = [
              {
                "label": "Meus clientes",
                "key": Singletons.company().topic
              },
              {
                "label": "Todos clientes",
                "key": "com.navan.kideliver-android"
              }
            ];
            final topicSelected = await showConfirmationDialog<String>(
              context: context,
              title: "Escolha um tópico",
              okLabel: "Ok",
              cancelLabel: CANCELAR,
              barrierDismissible: false,
              actions: topics.map((e) {
                return AlertDialogAction<String>(label: e["label"], key: e["key"]);
              }).toList(),
            );
            print(topicSelected);

          },
        ),
      ),
    );
  }

  Widget testButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
      child: SecondaryButton(
        text: "Testar",
        onPressed: () {
          Singletons.pushNotification().pushLocalNotification(titleController.text, message);
        },
      ),
    );
  }

  Widget sendButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 20, 10, 50),
      child: PrimaryButton(
        text: "Enviar",
        onPressed: () {
          //Singletons.pushNotification().pushLocalNotification(title, message);
        },
      ),
    );
  }

  @override
  listSuccess(List<PushNotification> list) {

  }

  @override
  onFailure(String error) {

  }

  @override
  onSuccess(PushNotification result) {

  }

}
