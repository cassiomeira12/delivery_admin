import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:delivery_admin/contracts/company/company_contract.dart';
import 'package:delivery_admin/models/company/company.dart';
import 'package:delivery_admin/models/company/opening_hour.dart';
import 'package:delivery_admin/models/singleton/singletons.dart';
import 'package:delivery_admin/presenters/company/company_presenter.dart';
import 'package:delivery_admin/views/settings/opening_hour_dialog.dart';
import 'package:delivery_admin/widgets/empty_list_widget.dart';
import 'package:delivery_admin/widgets/loading_shimmer_list.dart';
import 'package:delivery_admin/widgets/primary_button.dart';
import 'package:delivery_admin/widgets/scaffold_snackbar.dart';
import 'package:delivery_admin/widgets/text_input_field.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../models/version_app.dart';
import '../../presenters/version_app_presenter.dart';
import '../../strings.dart';
import '../../widgets/background_card.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenningHoursPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _OpenningHoursState();
}

class _OpenningHoursState extends State<OpenningHoursPage> implements CompanyContractView {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<OpeningHour> openingHourList;

  CompanyContractPresenter companyPresenter;

  @override
  void initState() {
    super.initState();
    companyPresenter = CompanyPresenter(this);
    openingHourList = Singletons.company().openHours;
    if (openingHourList == null) {
      openingHourList = List();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Horários", style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: openingHourList == null ?
        LoadingShimmerList()
            :
        openingHourList.isEmpty ?
        EmptyListWidget(
          message: "Nenhum horário foi encontrado",
          //assetsImage: "assets/notification.png",
        )
            :
        listView(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white,),
        onPressed: () async {
          OpeningHour openingHour = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => OpeningHourDialog(),
          );

          if (openingHour != null) {

          }

//          final categoriesSelected = await showConfirmationDialog<String>(
//            context: context,
//            title: "Escolha uma categoria",
//            okLabel: "Ok",
//            cancelLabel: CANCELAR,
//            barrierDismissible: false,
//            //message: "Deseja sair do $APP_NAME ?",
//            actions: menu.categories.map((e) {
//              return AlertDialogAction<String>(label: e.name, key: e.name);
//            }).toList(),
//          );
//
//          if (categoriesSelected != null) {
//            var newProduct = await PageRouter.push(context, NewProductPage());
//            if (newProduct != null) {
//              menu.categories.forEach((element) {
//                if (element.name == categoriesSelected) {
//                  setState(() {
//                    element.products.add(newProduct);
//                  });
//                  return;
//                }
//              });
//            }
//            menuPresenter.update(menu);
//          }

        },
      ),
    );
  }

  Widget listView() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate(
              openingHourList.map<Widget>((item) {
                return listItem(item);
              }).toList()
          ),
        ),
      ],
    );
  }

  Widget listItem(OpeningHour openingHour) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: openingHourWidget(openingHour),
//      actions: <Widget>[
//        IconSlideAction(
//          caption: "Lido",
//          color: Colors.blue,
//          icon: Icons.archive,
//          onTap: () {
//            setState(() {
//              item.read = true;
//              presenter.update(item);
//            });
//          },
//        ),
//      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: DELETAR,
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            setState(() {
              openingHourList.remove(openingHour);
              Singletons.company().openHours = openingHourList;
              companyPresenter.update(Singletons.company());
            });
          },
        ),
      ],
    );
  }

  Widget openingHourWidget(OpeningHour openingHour) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Card(
        elevation: 3,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Text(openingHour.getDay()),
              Text("Abre às ${openingHour.openTime()}"),
              Text("Fecha às ${openingHour.closeTime()}"),
            ],
          ),
        ),
      ),
    );
  }

  @override
  listSuccess(List<Company> list) {
    // TODO: implement listSuccess
    throw UnimplementedError();
  }

  @override
  onFailure(String error)  {
    ScaffoldSnackBar.failure(context, _scaffoldKey, error);
  }

  @override
  onSuccess(Company result) {
    ScaffoldSnackBar.success(context, _scaffoldKey, "Atualizado com sucesso!");
  }

}