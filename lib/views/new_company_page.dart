import '../views/page_router.dart';
import '../contracts/company/company_contract.dart';
import '../models/company/company.dart';
import '../presenters/company/company_presenter.dart';
import '../widgets/scaffold_snackbar.dart';
import '../widgets/text_input_field.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../utils/preferences_util.dart';
import '../models/singleton/singletons.dart';
import '../widgets/background_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/shape_round.dart';
import '../strings.dart';
import '../views/login/company/new_company_page.dart' as CompanyPage;

class NewCompanyPage extends StatefulWidget {
  NewCompanyPage({this.loginCallback, this.logoutCallback});

  final VoidCallback loginCallback;
  final VoidCallback logoutCallback;

  @override
  State<StatefulWidget> createState() => _NewCompanyPageState();
}

class _NewCompanyPageState extends State<NewCompanyPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String email = "";
  String imgEmail = "assets/error.png";
  bool loading = true;
  String textMessage = "Adicione o código do estabelecimento";

  String codigo;
  bool notCompany = false;

  CompanyContractPresenter companyPresenter;

  Company company;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    companyPresenter = CompanyPresenter(null);
    getCompany();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: ShapeRound(notCompany ? formCompany() : _showForm()),
                  ),
                  notCompany ? toBackButton() : Container(),
                  notCompany ? newCompany() : Container(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showForm() {
    return Container(
      padding: EdgeInsets.all(12.0),
      child: Column(
        children: <Widget>[
          textTitle(),
          showLogo(),
          textObservacao(),
        ],
      ),
    );
  }

  Widget formCompany() {
    return Container(
      padding: EdgeInsets.all(12.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            textTitle(),
            textMensagem(),
            codigoTextInput(),
            saveButton(),
          ],
        ),
      ),
    );
  }

  Widget toBackButton() {
    return Padding(
      padding: EdgeInsets.all(30),
      child: SecondaryButton(
        text: "Voltar",
        onPressed: () => widget.logoutCallback(),
      ),
    );
  }

  Widget newCompany() {
    return Padding(
      padding: EdgeInsets.all(30),
      child: PrimaryButton(
        text: "Cadastrar estabelecimento",
        onPressed: () {
          PageRouter.push(context, CompanyPage.NewCompanyPage());
        },
      ),
    );
  }

  Widget textTitle() {
    return Center(
      child: Text(
        "Meu Estabelecimento",
        style: Theme.of(context).textTheme.subtitle,
      ),
    );
  }

  Widget showLogo() {
    return loading ?
    Padding(
      padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 25.0),
      child: CircularProgressIndicator(),
    ) :
    Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset(imgEmail),
        ),
      ),
    );
  }

  Widget textObservacao() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 16, 0, 0),
      child: Text(
        "Procurando o seu estabelecimento...",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.display1,
      ),
    );
  }

  Widget textMensagem() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
      child: Center(
        child: Column(
          children: <Widget>[
            Text(
              textMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.body2,
            ),
            Text(
              email,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget codigoTextInput() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: TextInputField(
        labelText: "Código",
        keyboardType: TextInputType.text,
        onSaved: (value) => codigo = value.trim(),
      ),
    );
  }

  Widget saveButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: PrimaryButton(
        text: SALVAR,
        onPressed: validateAndSubmit,
      ),
    );
  }

  void getCompany() async {
    setState(() => loading = true);
    Company result = await companyPresenter.getFromAdmin(Singletons.user());
    if (result == null) {
      setState(() {
        loading = false;
        notCompany = true;
      });
    } else {
      setState(() {
        loading = false;
        imgEmail = "assets/sucesso.png";
      });
      PreferencesUtil.setAdminCompany(result.id);
      await Future.delayed(Duration(seconds: 1));
      widget.loginCallback();
    }
  }

//  @override
//  onFailure(String error) {
//    ScaffoldSnackBar.failure(context, _scaffoldKey, error);
//    setState(() {
//      loading = false;
//      _loading = false;
//      imgEmail = "assets/error.png";
//    });
//  }
//
//  @override
//  onSuccess(Company result) {
//    ScaffoldSnackBar.success(context, _scaffoldKey, SUCCESS_UPDATE_DATA);
//  }
//
//  @override
//  listSuccess(List<Company> list) {
//
//  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<bool> checkCompanyExist(String id) async {
    var company = Company();
    company.id = id;
    company.objectId = id;
    var result = await companyPresenter.read(company);
    return result != null;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      setState(() => _loading = true);
      var companyExist = await checkCompanyExist(codigo);
      if (companyExist) {
        var result = await companyPresenter.createAdminCompany(Singletons.user().id, codigo);
        setState(() => _loading = false);
        if (result == null || !result) {
          ScaffoldSnackBar.failure(context, _scaffoldKey, SOME_ERROR);
        } else {
          ScaffoldSnackBar.success(context, _scaffoldKey, SUCCESS_UPDATE_DATA);
          PreferencesUtil.setAdminCompany(codigo);
          await Future.delayed(Duration(seconds: 1));
          widget.loginCallback();
        }
      } else {
        setState(() => _loading = false);
        ScaffoldSnackBar.failure(context, _scaffoldKey, "Código inválido");
      }
    }
  }

}