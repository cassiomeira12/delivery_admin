import 'package:flutter/material.dart';
import '../../widgets/text_input_field.dart';
import '../../models/base_user.dart';
import '../../strings.dart';
import '../../views/login/create_account_page.dart';
import '../../widgets/background_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/shape_round.dart';

import '../page_router.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({this.loginCallback});

  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>{
  final _formKey = new GlobalKey<FormState>();

  String _name;
  String _email;
  String _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( iconTheme: IconThemeData(color: Colors.white), elevation: 0,),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            BackgroundCard(),
            SingleChildScrollView(
              child: ShapeRound(
                  _showForm()
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showForm() {
    return Container(
      padding: EdgeInsets.all(12.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            textTitle(),
            nameInput(),
            emailInput(),
            passwordInput(),
            confirmPasswordInput(),
            textData(),
            createAccountButton(),
          ],
        ),
      ),
    );
  }

  Widget textTitle() {
    return Center(
      child: Text(
        CRIAR_CONTA,
        style: Theme.of(context).textTheme.subtitle,
      ),
    );
  }

  Widget nameInput() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: TextInputField(
        labelText: NOME,
        textCapitalization: TextCapitalization.words,
        onSaved: (value) => _name = value.trim(),
      ),
    );
  }

  Widget emailInput() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
      child: TextInputField(
        labelText: EMAIL,
        inputType: TextInputType.emailAddress,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget passwordInput() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: TextInputField(
        labelText: SENHA,
        obscureText: true,
        validator: (value) {
          if (value.isEmpty || value.length < 6) {
            return SENHA_MUITO_CURTA;
          }
          _password = value;
          return null;
        },
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget confirmPasswordInput() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: TextInputField(
        labelText: REPITA_SENHA,
        obscureText: true,
        validator: (value) {
          if (value.isEmpty || value.length < 6) {
            return SENHA_MUITO_CURTA;
          }
          if (_password != value) {
            return SENHA_NAO_SAO_IGUAIS;
          }
          return null;
        },
      ),
    );
  }

  Widget textData() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
      child: Center(
        child: Text(
          TEXT_DADOS,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.body2,
        ),
      ),
    );
  }

  Widget createAccountButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: PrimaryButton(
        text: CRIAR_CONTA,
        onPressed: createAccount,
      ),
    );
  }

  bool validateData() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  BaseUser createBaseUser() {
    BaseUser user = BaseUser();
    user.name = _name;
    user.email = _email;
    user.password = _password;
    user.createAt = DateTime.now();
    return user;
  }

  void createAccount() {
    if (validateData()) {
      var user = createBaseUser();
      PageRouter.pop(context);
      PageRouter.push(context, CreateAccountPage(loginCallback: widget.loginCallback, user: user,));
    }
  }

}
