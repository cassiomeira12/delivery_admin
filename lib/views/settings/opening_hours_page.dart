import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../contracts/company/company_contract.dart';
import '../../models/company/opening_hour.dart';
import '../../models/singleton/singletons.dart';
import '../../presenters/company/company_presenter.dart';
import '../../strings.dart';
import '../../views/settings/opening_hour_dialog.dart';
import '../../widgets/empty_list_widget.dart';
import '../../widgets/loading_shimmer_list.dart';
import '../../widgets/scaffold_snackbar.dart';

class OpenningHoursPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OpenningHoursState();
}

class _OpenningHoursState extends State<OpenningHoursPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;

  CompanyContractPresenter companyPresenter;

  @override
  void initState() {
    super.initState();
    companyPresenter = CompanyPresenter(null);
    Singletons.company()
        .openHours
        .sort((a, b) => a.weekDay.compareTo(b.weekDay));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Horários",
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
        child: Center(
          child: _loading
              ? LoadingShimmerList()
              : Singletons.company().openHours.isEmpty
                  ? EmptyListWidget(
                      message: "Nenhum horário foi encontrado",
                      //assetsImage: "assets/notification.png",
                    )
                  : listView(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => OpeningHourDialog(),
          ).then((value) async {
            if (value != null) {
              setState(() {
                _loading = true;
                Singletons.company().openHours.add(value);
                Singletons.company()
                    .openHours
                    .sort((a, b) => a.weekDay.compareTo(b.weekDay));
              });
              var result = await companyPresenter.update(Singletons.company());
              if (result == null) {
                setState(() {
                  Singletons.company().openHours.remove(value);
                });
                onFailure(SOME_ERROR);
              } else {
                onSuccess();
              }
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
              Singletons.company().openHours.map<Widget>((item) {
            return Padding(
              padding: EdgeInsets.only(left: 10, top: 10, right: 10),
              child: GestureDetector(
                child: listItem(item),
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) =>
                        OpeningHourDialog(openingHour: item),
                  ).then((value) async {
                    if (value != null) {
                      var temp = OpeningHour();
                      temp.updateData(item);
                      setState(() => _loading = true);
                      setState(() => item = value);
                      var result =
                          await companyPresenter.update(Singletons.company());
                      if (result == null) {
                        setState(() => item = temp);
                        onFailure(SOME_ERROR);
                      } else {
                        onSuccess();
                      }
                    }
                  });
                },
              ),
            );
          }).toList()),
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
          onTap: () async {
            setState(() => _loading = true);
            setState(() {
              Singletons.company().openHours.remove(openingHour);
            });
            var result = await companyPresenter.update(Singletons.company());
            if (result == null) {
              setState(() {
                Singletons.company().openHours.add(openingHour);
                Singletons.company()
                    .openHours
                    .sort((a, b) => a.weekDay.compareTo(b.weekDay));
              });
              onFailure(SOME_ERROR);
            } else {
              onSuccess();
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

  onFailure(String error) {
    setState(() => _loading = false);
    ScaffoldSnackBar.failure(context, _scaffoldKey, error);
  }

  onSuccess() {
    setState(() => _loading = false);
    ScaffoldSnackBar.success(context, _scaffoldKey, "Atualizado com sucesso!");
  }
}
