import '../../contracts/company/company_contract.dart';
import '../../models/company/company.dart';
import '../../models/singleton/singletons.dart';
import '../../presenters/company/company_presenter.dart';
import '../../widgets/scaffold_snackbar.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../../widgets/text_input_field.dart';
import 'package:flutter/material.dart';
import '../../models/phone_number.dart';
import '../../strings.dart';
import '../../widgets/background_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/shape_round.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

import '../page_router.dart';
import 'verified_phone_number_page.dart';

class CompanyPhoneNumberPage extends StatefulWidget {
  final bool authenticate;

  CompanyPhoneNumberPage({this.authenticate = true});

  @override
  State<StatefulWidget> createState() => _CompanyPhoneNumberPageState();
}

class _CompanyPhoneNumberPageState extends State<CompanyPhoneNumberPage> implements CompanyContractView {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;

  var controller = MaskedTextController(mask: '(00) 0 0000-0000');
  String _phoneNumber;

  CompanyContractPresenter companyPresenter;

  @override
  void initState() {
    super.initState();
    companyPresenter = CompanyPresenter(this);
    if (Singletons.company().phoneNumber != null) {
      controller.text = Singletons.company().phoneNumber.toString().substring(4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar( iconTheme: IconThemeData(color: Colors.white), elevation: 0,),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        progressIndicator: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),
          child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(),),
        ),
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              BackgroundCard(),
              bodyAppScrollView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget bodyAppScrollView() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(0.0, 60.0, 0.0, 0.0),
            child: ShapeRound(_showForm(context)),
          ),
        ],
      ),
    );
  }

  Widget _showForm(context) {
    return Container(
      padding: EdgeInsets.all(12.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            textTitle(),
            textMessage(),
            showNumberInput(),
            enviarSMSButton(),
          ],
        ),
      ),
    );
  }

  Widget textTitle() {
    return Center(
      child: Text(
        NUMERO_CELULAR,
        style: Theme.of(context).textTheme.subtitle,
      ),
    );
  }

  Widget textMessage() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
      child: Center(
        child: Text(
          "Adicione aqui o seu telefone para contato",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.body2,
        ),
      ),
    );
  }

  Widget showNumberInput () {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
      child: TextInputField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.phone,
        labelText: NUMERO_CELULAR,
        hintText: "(XX) X XXXX-XXXX",
        validator: (value) => value.isEmpty ? DIGITE_NUMERO_TELEFONE : null,
        onSaved: (value) => _phoneNumber = value.trim(),
      ),
    );
  }

  Widget enviarSMSButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
      child: PrimaryButton(
        text: SALVAR,
        onPressed: validateAndSubmit,
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

  PhoneNumber createNumber(String phoneNumber) {
    PhoneNumber phone = PhoneNumber();
    phone.countryCode = "+55";
    phone.ddd = _phoneNumber.substring(1, 3);
    phone.number = _phoneNumber.substring(5);
    return phone;
  }

  void validateAndSubmit() {
    if (validateAndSave()) {
      PhoneNumber phone = createNumber(_phoneNumber);
      Singletons.company().phoneNumber = phone;
      setState(() => _loading = true);
      companyPresenter.update(Singletons.company());
    }
  }

  @override
  listSuccess(List<Company> list) {

  }

  @override
  onFailure(String error)  {
    setState(() => _loading = false);
    ScaffoldSnackBar.failure(context, _scaffoldKey, error);
  }

  @override
  onSuccess(Company result) {
    setState(() => _loading = false);
    ScaffoldSnackBar.success(context, _scaffoldKey, SUCCESS_UPDATE_DATA);
  }

}