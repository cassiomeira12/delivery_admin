import 'package:delivery_admin/utils/log_util.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/material.dart';
import '../../models/singleton/singletons.dart';
import '../../widgets/area_input_field.dart';
import '../../contracts/address/address_contract.dart';
import '../../models/address/address.dart';
import '../../models/address/city.dart';
import '../../models/address/small_town.dart';
import '../../presenters/address/address_presenter.dart';
import '../../strings.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/scaffold_snackbar.dart';
import '../../widgets/text_input_field.dart';
import '../page_router.dart';

class CompanyAddressPage extends StatefulWidget {

  @override
  _CompanyAddressPageState createState() => _CompanyAddressPageState();
}

class _CompanyAddressPageState extends State<CompanyAddressPage> implements AddressContractView {
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String bairro, rua, numero, referencia;

  AddressContractPresenter presenter;

  bool loading = false;

  TextEditingController neighborhoodController, streetController, numberController, referenceController;

  @override
  void initState() {
    super.initState();
    presenter = AddressPresenter(this);
    neighborhoodController = TextEditingController();
    streetController = TextEditingController();
    numberController = TextEditingController();
    referenceController = TextEditingController();
    if (Singletons.company().address != null) {
      setCurrentAddress(Singletons.company().address);
    }
  }

  void setCurrentAddress(Address address) {
    neighborhoodController.text = address.neighborhood;
    streetController.text = address.street;
    numberController.text = address.number;
    referenceController.text = address.reference;
  }

  @override
  void dispose() {
    super.dispose();
    presenter.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Endereço", style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ModalProgressHUD(
        inAsyncCall: loading,
        progressIndicator: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),
          child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(),),
        ),
        child: body(),
      ),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 10,),
          Singletons.company().address.city != null ? textCityWidget() : Container(),
          Singletons.company().address.smallTown != null ? textDistritoWidget() : Container(),

          Singletons.company().address.smallTown == null ? cityForm() : smallTomForm(),
          saveButton(),
        ],
      ),
    );
  }

  Widget cityForm() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            textInputNeighborhood(),
            textInputStreet(),
            textInputNumber(),
            textInputReference(),
          ],
        ),
      ),
    );
  }

  Widget smallTomForm() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            textInputStreet(),
            textInputNumber(),
            textInputReference(),
          ],
        ),
      ),
    );
  }

  Widget textCityWidget() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Text(
        Singletons.company().address.city.name,
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget textDistritoWidget() {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Text(
        Singletons.company().address.smallTown.name,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget textInputNeighborhood() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: TextInputField(
        labelText: "Bairro",
        controller: neighborhoodController,
        textCapitalization: TextCapitalization.sentences,
        onSaved: (value) => bairro = value.trim(),
      ),
    );
  }

  Widget textInputStreet() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: TextInputField(
        labelText: "Rua",
        controller: streetController,
        textCapitalization: TextCapitalization.sentences,
        onSaved: (value) => rua = value.trim(),
      ),
    );
  }

  Widget textInputNumber() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: TextInputField(
        labelText: "Número",
        controller: numberController,
        textCapitalization: TextCapitalization.sentences,
        validator: (value) => null,
        onSaved: (value) => numero = value.trim(),
      ),
    );
  }

  Widget textInputReference() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: AreaInputField(
        labelText: "Referência",
        controller: referenceController,
        textCapitalization: TextCapitalization.sentences,
        maxLines: 3,
        validator: (value) => null,
        onSaved: (value) => referencia = value.trim(),
      ),
    );
  }

  Widget saveButton() {
    return Padding(
      padding: EdgeInsets.all(10),
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
    if (validateAndSave()) {
      var address = create();
      setState(() {
        loading = true;
      });
      if (Singletons.company().address == null) {
        presenter.create(address);
      } else {
        address.id = Singletons.company().address.id;
        address.objectId = Singletons.company().address.objectId;
        presenter.update(address);
      }
    }
  }

  Address create() {
    Address address = Address()
      ..user = Singletons.user()
      ..neighborhood = bairro
      ..street = rua
      ..number = numero.isEmpty ? null : numero
      ..reference = referencia.isEmpty ? null : referencia;
    if (Singletons.company().address != null) {
      address.city = Singletons.company().address.city;
      address.smallTown = Singletons.company().address.smallTown;
    }
    return address;
  }

  @override
  listSuccess(List<Address> list) {

  }

  @override
  onFailure(String error)  {
    setState(() {
      loading = false;
    });
    ScaffoldSnackBar.failure(context, _scaffoldKey, error);
  }

  @override
  onSuccess(Address result) {
    var city = Singletons.company().address.city;
    var smallTown = Singletons.company().address.smallTown;
    result.city = city;
    result.smallTown = smallTown;
    setState(() {
      Singletons.company().address = result;
    });
    setState(() {
      loading = false;
    });
    ScaffoldSnackBar.success(context, _scaffoldKey, SUCCESS_UPDATE_DATA);
  }

}
