import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../contracts/company/company_contract.dart';
import '../../models/company/company.dart';
import '../../models/company/type_payment.dart';
import '../../models/singleton/singletons.dart';
import '../../presenters/company/company_presenter.dart';
import '../../strings.dart';
import '../../widgets/scaffold_snackbar.dart';

class PaymentTypePage extends StatefulWidget {
  @override
  _PaymentTypePageState createState() => _PaymentTypePageState();
}

class _PaymentTypePageState extends State<PaymentTypePage>
    implements CompanyContractView {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;

  List<TypePayment> paymentsType;

  var paymentTypeList = List();

  CompanyContractPresenter companyPresenter;

  @override
  void initState() {
    super.initState();
    companyPresenter = CompanyPresenter(this);
    paymentsType = Singletons.company().typePayments;
    if (Singletons.company().typePayments == null) {
      Singletons.company().typePayments = List();
    }
    listPaymentType();
  }

  void listPaymentType() {
    paymentTypeList.clear();

    int index = 0;

    try {
      paymentsType.firstWhere((element) => element.paymentType == Type.MONEY,
          orElse: null);
    } catch (error) {
      paymentTypeList.add({
        "key": index++,
        "name": "Dinheiro",
        "type": Type.MONEY.toString().split('.').last,
        "taxa": 7,
        "maxInstallments": 1
      });
    }

    try {
      paymentsType.firstWhere((element) => element.paymentType == Type.CARD,
          orElse: null);
    } catch (error) {
      paymentTypeList.add({
        "key": index++,
        "name": "Cartão",
        "type": Type.CARD.toString().split('.').last,
        "taxa": 7,
        "maxInstallments": 1
      });
    }

//    try {
//      paymentsType.firstWhere((element) => element.paymentType == Type.PIC_PAY,
//          orElse: null);
//    } catch (error) {
//      paymentTypeList.add({
//        "key": index++,
//        "name": "PicPay",
//        "type": Type.PIC_PAY.toString().split('.').last,
//        "taxa": 7,
//        "maxInstallments": 1
//      });
//    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Forma de pagamento",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
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
        onPressed: () {
          showConfirmationDialog<int>(
            context: context,
            title: "Escolha uma forma de pagamento",
            okLabel: "Ok",
            cancelLabel: CANCELAR,
            barrierDismissible: false,
            actions: paymentTypeList.map((e) {
              return AlertDialogAction<int>(label: e["name"], key: e["key"]);
            }).toList(),
          ).then((value) {
            if (value != null) {
              var typeJson = paymentTypeList[value];
              var typePayment = TypePayment.fromMap(typeJson);
              setState(() {
                paymentsType.add(typePayment);
                _loading = true;
              });
              var result = companyPresenter.update(Singletons.company());
              if (result == null) {
                setState(() {
                  paymentsType.remove(typePayment);
                });
              }
            }
          });
        },
      ),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          textTitleWidget(),
          paymentListView(),
        ],
      ),
    );
  }

  Widget textTitleWidget() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        "Pagar na entrega",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget paymentListView() {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: paymentsType.map((e) {
        return Padding(
          padding: EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
          child: listItem(e),
        );
      }).toList(),
    );
  }

  Widget listItem(TypePayment payment) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: paymentListItem(payment),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: DELETAR,
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            setState(() {
              paymentsType.remove(payment);
              _loading = true;
            });
            var result = companyPresenter.update(Singletons.company());
            if (result == null) {
              setState(() {
                paymentsType.add(payment);
              });
            }
          },
        ),
      ],
    );
  }

  Widget paymentListItem(TypePayment payment) {
    IconData icon = findIcon(payment.paymentType);
    String name = payment.getType();
    return Card(
      margin: EdgeInsets.all(0),
      child: FlatButton(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 25, 15, 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  icon != null
                      ? Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: FaIcon(icon, color: Colors.green),
                        )
                      : Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: Container(
                            width: 30,
                            child: Image.asset(findImage(payment.paymentType)),
                          ),
                        ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black45,
                        ),
                      ),
//                      Text(
//                        "teste",
//                        style: Theme.of(context).textTheme.bodyText1,
//                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        onPressed: () async {
//          bool valid =
//              await canLaunch("https://picpay.me/cassio.meira.silva/10");
//          if (valid) {
//            launch("https://picpay.me/cassio.meira.silva/10");
//          }
        },
      ),
    );
  }

  String findImage(Type type) {
    String image;
    switch (type) {
      case Type.PIC_PAY:
        image = "assets/picpay.png";
        break;
      default:
        image = "assets/default_image.png";
    }
    return image;
  }

  IconData findIcon(Type type) {
    IconData icon;
    switch (type) {
      case Type.MONEY:
        icon = FontAwesomeIcons.moneyBill;
        break;
      case Type.CARD:
        icon = FontAwesomeIcons.creditCard;
        break;
      case Type.APP_PAYMENT:
        icon = FontAwesomeIcons.mobileAlt;
        break;
      case Type.CASHBACK:
        icon = FontAwesomeIcons.handHoldingUsd;
        break;
    }
    return icon;
  }

  @override
  listSuccess(List<Company> list) {}

  @override
  onFailure(String error) {
    setState(() => _loading = false);
    ScaffoldSnackBar.failure(context, _scaffoldKey, error);
    listPaymentType();
  }

  @override
  onSuccess(Company result) {
    setState(() => _loading = false);
    ScaffoldSnackBar.success(context, _scaffoldKey, SUCCESS_UPDATE_DATA);
    listPaymentType();
  }
}
