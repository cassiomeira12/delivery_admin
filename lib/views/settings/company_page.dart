import 'package:delivery_admin/widgets/primary_button.dart';
import 'package:delivery_admin/widgets/text_input_field.dart';

import '../../models/version_app.dart';
import '../../presenters/version_app_presenter.dart';
import '../../strings.dart';
import '../../widgets/background_card.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _CompanyState();
}

class _CompanyState extends State<CompanyPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Estabelecimento", style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                BackgroundCard(height: 200,),
                _showForm(),
              ],
            ),
            txtAboutApp(),
          ],
        ),
      ),
    );
  }

  Widget _showForm() {
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            imgApp(),
            txtAppName(),
          ],
        ),
      ),
    );
  }

  Widget imgApp() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: Center(
        child: Hero(
          tag: "about",
          child: Padding(
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 80.0,
              child: Image.asset("assets/logo_app.png"),
            ),
          ),
        ),
      ),
    );
  }

  Widget txtAppName() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: Center(
        child: Text(
          APP_NAME,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.body1,
        ),
      ),
    );
  }

  Widget txtAboutApp() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      width: double.maxFinite,
      child: Text(
        "About App",
        style: Theme.of(context).textTheme.body1,
      ),
    );
  }

  Widget showEmailInput() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: TextInputField(
        labelText: EMAIL,
        keyboardType: TextInputType.emailAddress,
        onSaved: (value) => value = value.trim(),
      ),
    );
  }

  Widget changePasswordButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 16.0, 12, 0.0),
      child: PrimaryButton(
        text: ALTERAR_SENHA,
        onPressed: () {

        },
      ),
    );
  }

}