import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import '../../models/company/opening_hour.dart';
import '../../widgets/secondary_button.dart';
import '../../strings.dart';
import '../../widgets/primary_button.dart';
import '../page_router.dart';

class OpeningHourDialog extends StatefulWidget {
  final OpeningHour openingHour;

  OpeningHourDialog({this.openingHour});

  @override
  _OpeningHourDialogState createState() => _OpeningHourDialogState();
}

class _OpeningHourDialogState extends State<OpeningHourDialog> {
  final _formKey = GlobalKey<FormState>();
  int selectedStart = 1;
  String coment;

  var weekList = List();

  OpeningHour openingHour;

  @override
  void initState() {
    super.initState();
    openingHour = widget.openingHour == null ? OpeningHour() : widget.openingHour;
    weekList.add({"title": "Segunda", "day": 1});
    weekList.add({"title": "Terça", "day": 2});
    weekList.add({"title": "Quarta", "day": 3});
    weekList.add({"title": "Quinta", "day": 4});
    weekList.add({"title": "Sexta", "day": 5});
    weekList.add({"title": "Sábado", "day": 6});
    weekList.add({"title": "Domingo", "day": 7});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 5,
      backgroundColor: Colors.white,
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10,),
              Text(
                "Novo horário de funcionamento",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black45,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10,),
              SecondaryButton(
                text: "Dia da semana",
                onPressed: () async {
                  final result = await showConfirmationDialog<int>(
                    context: context,
                    title: "Escolha um dia da semana",
                    okLabel: "Ok",
                    cancelLabel: CANCELAR,
                    barrierDismissible: false,
                    actions: weekList.map((e) {
                      return AlertDialogAction<int>(label: e["title"], key: e["day"]);
                    }).toList(),
                  );
                  if (result != null) {
                    setState(() {
                      openingHour.weekDay = result;
                    });
                  }
                },
              ),
              SizedBox(height: 20,),
              SecondaryButton(
                text: "Horário abertura",
                onPressed: () {
                  showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: 0, minute: 0),
                  ).then((value) {
                    if (value != null) {
                      setState(() {
                        openingHour.openHour = value.hour;
                        openingHour.openMinute = value.minute;
                      });
                    }
                  });
                },
              ),
              SizedBox(height: 20,),
              SecondaryButton(
                text: "Horário fechamento",
                onPressed: () {
                  showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: 0, minute: 0),
                  ).then((value) {
                    if (value != null) {
                      setState(() {
                        openingHour.closeHour = value.hour;
                        openingHour.closeMinute = value.minute;
                      });
                    }
                  });
                },
              ),
              SizedBox(height: 30,),
              PrimaryButton(
                text: "Salvar",
                onPressed: () async {
                  if (openingHour.weekDay == null) {
                    return;
                  }

                  if (openingHour.openHour == null || openingHour.openMinute == null) {
                    return;
                  }

                  if (openingHour.closeHour == null || openingHour.closeMinute == null) {
                    return;
                  }

                  PageRouter.pop(context, openingHour);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
