import '../../contracts/company/company_contract.dart';
import '../../models/company/company.dart';
import '../../models/company/delivery.dart';
import '../../models/singleton/singletons.dart';
import '../../presenters/company/company_presenter.dart';
import '../../utils/log_util.dart';
import '../../widgets/scaffold_snackbar.dart';
import '../../widgets/shape_round.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/text_input_field.dart';
import '../../strings.dart';
import '../../widgets/background_card.dart';

class DeliveryPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _DeliveryState();
}

class _DeliveryState extends State<DeliveryPage> implements CompanyContractView {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;

  MoneyMaskedTextController deliveryCostController;
  bool deliveryType = false;
  bool pickupType = false;
  Delivery delivery;

  CompanyContractPresenter companyPresenter;

  @override
  void initState() {
    super.initState();
    companyPresenter = CompanyPresenter(this);
    deliveryCostController = MoneyMaskedTextController(leftSymbol: "R\$ ");
    delivery = Singletons.company().delivery;
    deliveryType = delivery != null;
    if (delivery == null) {
      deliveryType = false;
    } else {
      deliveryCostController.updateValue(delivery.cost/100);
      pickupType = delivery.pickup;
    }
  }

  @override
  void dispose() {
    super.dispose();
    companyPresenter.dispose();
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
          child: Column(
            children: [
              Stack(
                children: <Widget>[
                  BackgroundCard(),
                  Column(
                    children: [
                      deliveryButton(),
                      deliveryType ? bodyAppScrollView() : textPickup(),
                    ],
                  ),
                ],
              ),
              saveButton(),
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
            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: ShapeRound(_showForm(context)),
          ),
        ],
      ),
    );
  }

  Widget _showForm(context) {
    return Container(
      padding: EdgeInsets.all(0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            textTitle(),
            textMessage(),
            showNumberInput(),
            pickupButton(),
          ],
        ),
      ),
    );
  }

  Widget textPickup() {
    return ShapeRound(
      Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            "Seu estabelecimento está aceitando apenas retirada",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.body2,
          ),
        ),
      )
    );
  }

  Widget textTitle() {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 10, right: 10),
      child: Text(
        "Delivery",
        style: Theme.of(context).textTheme.subtitle,
      ),
    );
  }

  Widget textMessage() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Center(
        child: Text(
          "Entrega a domicílio",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.body2,
        ),
      ),
    );
  }

  Widget deliveryButton() {
    return Padding(
      padding: EdgeInsets.only(left: 16, top: 10, right: 16),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: RaisedButton(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          color: Theme.of(context).backgroundColor,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  "Faz Delivery",
                  style: Theme.of(context).textTheme.body2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                child: Switch(
                  value: deliveryType,
                  activeColor: Theme.of(context).accentColor,
                  onChanged: (value) {
                    setState(() => deliveryType = value);
                  },
                ),
              ),
            ],
          ),
          onPressed: () {
            setState(() => deliveryType = !deliveryType);
          },
        ),
      ),
    );
  }

  Widget pickupButton() {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 6),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: RaisedButton(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          color: Theme.of(context).backgroundColor,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  "Aceitar retirada",
                  style: Theme.of(context).textTheme.body2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                child: Switch(
                  value: pickupType,
                  activeColor: Theme.of(context).accentColor,
                  onChanged: (value) {
                    setState(() => pickupType = value);
                  },
                ),
              ),
            ],
          ),
          onPressed: () {
            setState(() => pickupType = !pickupType);
          },
        ),
      ),
    );
  }

  Widget showNumberInput () {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 10, right: 10),
      child: TextInputField(
        controller: deliveryCostController,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.phone,
        labelText: "Taxa de entrega",
        hintText: "R\$ 0.00",
        validator: (value) => value.isEmpty ? "Digite um valor" : null,
        //onSaved: (value) => _phoneNumber = value.trim(),
      ),
    );
  }

  Widget saveButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 16, 10, 16),
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

  void validateAndSubmit() {
    if (deliveryType) {
      if (validateAndSave()) {
        var cost = deliveryCostController.numberValue * 100;
        delivery.cost = cost;
        delivery.pickup = pickupType;
        Singletons.company().delivery = delivery;
        setState(() => _loading = true);
        companyPresenter.update(Singletons.company());
      }
    } else {
      Singletons.company().delivery = null;
      setState(() => _loading = true);
      companyPresenter.update(Singletons.company());
    }
  }

  @override
  listSuccess(List<Company> list) {

  }

  @override
  onFailure(String error)  {
    Log.d(error);
    setState(() => _loading = false);
    ScaffoldSnackBar.failure(context, _scaffoldKey, error);
  }

  @override
  onSuccess(Company result) {
    setState(() => _loading = false);
    ScaffoldSnackBar.success(context, _scaffoldKey, SUCCESS_UPDATE_DATA);
  }

}