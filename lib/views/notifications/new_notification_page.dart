import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../contracts/notification/push_notification_contract.dart';
import '../../models/notification/push_notification.dart';
import '../../presenters/notification/push_notification_presenter.dart';
import '../../views/page_router.dart';
import '../../widgets/scaffold_snackbar.dart';
import '../../widgets/secondary_button.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
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
  bool _loading = false;

  PushNotificationContractPresenter presenter;

  TextEditingController titleController;
  String title, message, observacao, imgURL, data;

  var topics = {
    Singletons
        .company()
        .topic : {
      "label": "Meus clientes",
      "key": Singletons
          .company()
          .topic
    },
//    "com.navan.kideliver-android": {
//      "label": "Todos clientes",
//      "key": "com.navan.kideliver-android"
//    }
  };
  var topicSelected;

  @override
  void initState() {
    super.initState();
    presenter = PushNotificationPresenter(this);
    topicSelected = topics[Singletons.company().topic];
    titleController = TextEditingController(text: Singletons.company().name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Nova notificação", style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        progressIndicator: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),
          child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(),),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              formPushNotification(),
              topic(),
              testButton(),
              sendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget formPushNotification() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          textTitleWidget(),
          textMessageWidget(),
        ],
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
                            topicSelected["label"],
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
            String topicSelected = await showConfirmationDialog<String>(
              context: context,
              title: "Escolha um tópico",
              okLabel: "Ok",
              cancelLabel: CANCELAR,
              barrierDismissible: false,
              actions: topics.values.map((e) {
                return AlertDialogAction<String>(label: e["label"], key: e["key"]);
              }).toList(),
            );
            if (topicSelected != null) {
              setState(() {
                this.topicSelected = topics[topicSelected];
              });
            }
          },
        ),
      ),
    );
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget testButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
      child: SecondaryButton(
        text: "Testar nesse celular",
        onPressed: () {
          if (validateAndSave()) {
            Singletons.pushNotification().pushLocalNotification(titleController.text, message);
          }
        },
      ),
    );
  }

  Widget sendButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 20, 10, 50),
      child: PrimaryButton(
        text: "Enviar notificação",
        onPressed: () {
          if (validateAndSave()) {
            var pushNotification = PushNotification();
            pushNotification.title = titleController.text;
            pushNotification.message = message;
            pushNotification.senderCompany = Singletons.company();
            pushNotification.senderUser = Singletons.user();
            pushNotification.topic = topicSelected["key"];

            setState(() => _loading = true);
            presenter.create(pushNotification);
          }
        },
      ),
    );
  }

  @override
  listSuccess(List<PushNotification> list) {

  }

  @override
  onFailure(String error) {
    setState(() => _loading = false);
    ScaffoldSnackBar.failure(context, _scaffoldKey, error);
  }

  @override
  onSuccess(PushNotification result) async {
    setState(() => _loading = false);
    ScaffoldSnackBar.success(context, _scaffoldKey, "Notificação enviada!");
    await Future.delayed(Duration(seconds: 1));
    PageRouter.pop(context, result);
  }

}
