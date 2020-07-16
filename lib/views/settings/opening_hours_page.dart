import 'package:delivery_admin/contracts/company/company_contract.dart';
import 'package:delivery_admin/models/company/company.dart';
import 'package:delivery_admin/models/company/opening_hour.dart';
import 'package:delivery_admin/models/singleton/singletons.dart';
import 'package:delivery_admin/presenters/company/company_presenter.dart';
import 'package:delivery_admin/views/settings/opening_hour_dialog.dart';
import 'package:delivery_admin/widgets/empty_list_widget.dart';
import 'package:delivery_admin/widgets/loading_shimmer_list.dart';
import 'package:delivery_admin/widgets/scaffold_snackbar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../../strings.dart';
import 'package:flutter/material.dart';

class OpenningHoursPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _OpenningHoursState();
}

class _OpenningHoursState extends State<OpenningHoursPage> implements CompanyContractView {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;

  List<OpeningHour> openingHourList;

  CompanyContractPresenter companyPresenter;

  @override
  void initState() {
    super.initState();
    companyPresenter = CompanyPresenter(this);
    if (Singletons.company().openHours == null) {
      Singletons.company().openHours = List();
    }
    openingHourList = Singletons.company().openHours;
    openingHourList.sort((a, b) => a.weekDay.compareTo(b.weekDay));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Horários", style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        progressIndicator: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),
          child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(),),
        ),
        child: Center(
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
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white,),
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => OpeningHourDialog(),
          ).then((value) {
            setState(() {
              openingHourList.add(value);
              openingHourList.sort((a, b) => a.weekDay.compareTo(b.weekDay));
              _loading = true;
            });
            var result = companyPresenter.update(Singletons.company());
            if (result == null) {
              setState(() {
                openingHourList.remove(value);
              });
            }
          });
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
                return Padding(
                  padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: GestureDetector(
                    child: listItem(item),
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => OpeningHourDialog(openingHour: item,),
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            item = value;
                            _loading = true;
                          });
                          companyPresenter.update(Singletons.company());
                        }
                      });
                    },
                  ),
                );
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
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: DELETAR,
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            setState(() {
              openingHourList.remove(openingHour);
              _loading = true;
            });
            var result = companyPresenter.update(Singletons.company());
            if (result == null) {
              setState(() {
                openingHourList.add(openingHour);
              });
            }
          },
        ),
      ],
    );
  }

  Widget openingHourWidget(OpeningHour openingHour) {
    return Card(
      margin: EdgeInsets.all(0),
      elevation: 3,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10, top: 5),
              child: Text(
                openingHour.getDay(),
                style: Theme.of(context).textTheme.body1,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 5),
              child: Text(
                "Abre às ${openingHour.openTime()}",
                style: Theme.of(context).textTheme.body1,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
              child: Text(
                "Fecha às ${openingHour.closeTime()}",
                style: Theme.of(context).textTheme.body1,
              ),
            ),
          ],
        ),
      ),
    );
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
    ScaffoldSnackBar.success(context, _scaffoldKey, "Atualizado com sucesso!");
  }

}