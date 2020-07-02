import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../widgets/background_card.dart';
import '../../models/singleton/singletons.dart';
import '../../widgets/scaffold_snackbar.dart';
import '../../views/image_view_page.dart';
import '../../widgets/image_network_widget.dart';
import '../../contracts/user/user_contract.dart';
import '../../models/base_user.dart';
import '../../presenters/user/user_presenter.dart';
import '../../strings.dart';
import '../../themes/my_themes.dart';
import '../../themes/custom_theme.dart';
import '../../views/notifications/notifications_settings_page.dart';
import '../../views/page_router.dart';
import '../../views/settings/about_app_page.dart';
import '../../views/settings/disable_account_page.dart';
import '../../views/settings/termos_app_page.dart';
import '../../views/settings/user_page.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({this.logoutCallback});

  final VoidCallback logoutCallback;

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> implements UserContractView {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;

  UserContractPresenter presenter;

  bool darkMode;
  String userName, userPhoto;

  @override
  void initState() {
    super.initState();
    presenter = UserPresenter(this);
    userName = Singletons.user().name;
    userPhoto = Singletons.user().avatarURL;
  }

  @override
  Widget build(BuildContext context) {
    darkMode = CustomTheme.instanceOf(context).isDarkTheme();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(TAB4, style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        progressIndicator: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),
          child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(),),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  BackgroundCard(height: 150,),
                  imgUser(),
                ],
              ),
              textNameWidget(),
              listConfigWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget imgUser() {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            alignment: Alignment.bottomRight,
            width: 120,
            child: Hero(
              tag: ImageViewPage.HERO_TAG,
              child: GestureDetector(
                child: Stack(
                  children: <Widget>[
                    defaultImageUser(),
                    userPhoto == null ? Container() : ImageNetworkWidget(url: userPhoto, size: 120,),
                  ],
                ),
                onTap: () {
                  if (Singletons.user().isAnonymous()) {
                    ScaffoldSnackBar.failure(context, _scaffoldKey, USER_ANONYMOUS);
                    return;
                  }
                  PageRouter.push(context, UserPage());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget defaultImageUser() {
    return Container(
      width: 120,
      height: 120,
      child: Image.asset("assets/user_default_img_white.png"),
    );
  }

  Widget imageUserURL() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(userPhoto),
        ),
      ),
    );
  }

  Widget listConfigWidget() {
    return Column(
      children: <Widget>[
        perfilButton(),
        notificationsSettingsButton(),
        //darkModeButton(),
        aboutAppButton(),
        //termosButton(),
        //disableAccountButton(),
        signOutButton(),
        Padding(padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 40),),
      ],
    );
  }

  Widget textNameWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 12, 0, 8),
      child: Center(
        child: Text(
          userName,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.body1,
        ),
      ),
    );
  }

  Widget perfilButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 1.0, 0.0, 0.0),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: RaisedButton(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
            //side: BorderSide(color: Colors.black26),
          ),
          color: Theme.of(context).backgroundColor,
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
                child: FaIcon(FontAwesomeIcons.userAlt, color: Theme.of(context).iconTheme.color,),
              ),
              Expanded(
                child: Text(
                  PERFIL,
                  style: Theme.of(context).textTheme.body2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                child: Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color,),
              ),
            ],
          ),
          onPressed: () async {
            if (Singletons.user().isAnonymous()) {
              ScaffoldSnackBar.failure(context, _scaffoldKey, USER_ANONYMOUS);
              return;
            }
            await PageRouter.push(context, UserPage());
            setState(() {
              userName = Singletons.user().name;
              userPhoto = Singletons.user().avatarURL;
            });
          },
        ),
      ),
    );
  }

  Widget notificationsSettingsButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 1.0, 0.0, 0.0),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: RaisedButton(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
            //side: BorderSide(color: Colors.black26),
          ),
          color: Theme.of(context).backgroundColor,
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
                child: FaIcon(FontAwesomeIcons.solidBell, color: Theme.of(context).iconTheme.color,),
              ),
              Expanded(
                child: Text(
                  TAB2,
                  style: Theme.of(context).textTheme.body2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                child: Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color,),
              ),
            ],
          ),
          onPressed: () {
            if (Singletons.user().isAnonymous()) {
              ScaffoldSnackBar.failure(context, _scaffoldKey, USER_ANONYMOUS);
              return;
            }
            PageRouter.push(context, NotificationsSettingsPage());
          },
        ),
      ),
    );
  }

  Widget darkModeButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 1.0, 0.0, 0.0),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: RaisedButton(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
            //side: BorderSide(color: Colors.black26),
          ),
          color: Theme.of(context).backgroundColor,
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
                child: FaIcon(FontAwesomeIcons.palette, color: Theme.of(context).iconTheme.color,),
              ),
              Expanded(
                child: Text(
                  DARK_MODE,
                  style: Theme.of(context).textTheme.body2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                child: Switch(
                  value: darkMode,
                  activeColor: Theme.of(context).accentColor,
                  onChanged: (value) {
                    setState(() {
                      darkMode = !darkMode;
                      if (darkMode) {
                        CustomTheme.instanceOf(context).changeTheme(MyThemeKeys.DARK);
                      } else {
                        CustomTheme.instanceOf(context).changeTheme(MyThemeKeys.LIGHT);
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          onPressed: () {
            setState(() {
              darkMode = !darkMode;
              if (darkMode) {
                CustomTheme.instanceOf(context).changeTheme(MyThemeKeys.DARK);
              } else {
                CustomTheme.instanceOf(context).changeTheme(MyThemeKeys.LIGHT);
              }
            });
          },
        ),
      ),
    );
  }

  Widget aboutAppButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 1.0, 0.0, 0.0),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: RaisedButton(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
            //side: BorderSide(color: Colors.black26),
          ),
          color: Theme.of(context).backgroundColor,
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
                child: FaIcon(FontAwesomeIcons.infoCircle, color: Theme.of(context).iconTheme.color,),
              ),
              Expanded(
                child: Text(
                  ABOUT,
                  style: Theme.of(context).textTheme.body2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                child: Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color,),
              ),
            ],
          ),
          onPressed: () {
            PageRouter.push(context, AboutAppPage());
          },
        ),
      ),
    );
  }

  Widget termosButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 1.0, 0.0, 0.0),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: RaisedButton(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
            //side: BorderSide(color: Colors.black26),
          ),
          color: Theme.of(context).backgroundColor,
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
                child: FaIcon(FontAwesomeIcons.solidQuestionCircle, color: Theme.of(context).iconTheme.color,),
              ),
              Expanded(
                child: Text(
                  TERMOS,
                  style: Theme.of(context).textTheme.body2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                child: Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color,),
              ),
            ],
          ),
          onPressed: () {
            PageRouter.push(context, TermosAppPage());
          },
        ),
      ),
    );
  }

  Widget disableAccountButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 1.0, 0.0, 0.0),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: RaisedButton(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
            //side: BorderSide(color: Colors.black26),
          ),
          color: Theme.of(context).backgroundColor,
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
                child: FaIcon(FontAwesomeIcons.userTimes, color: Theme.of(context).iconTheme.color,),
              ),
              Expanded(
                child: Text(
                  DISABLE_ACCOUNT,
                  style: Theme.of(context).textTheme.body2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                child: Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color,),
              ),
            ],
          ),
          onPressed: () {
            PageRouter.push(context, DisableAccountPage());
          },
        ),
      ),
    );
  }

  Widget signOutButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 1.0, 0.0, 0.0),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: RaisedButton(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
            //side: BorderSide(color: Colors.black26),
          ),
          color: Theme.of(context).backgroundColor,
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
                child: FaIcon(FontAwesomeIcons.signOutAlt, color: Theme.of(context).iconTheme.color,),
              ),
              Expanded(
                child: Text(
                  SIGNOUT,
                  style: Theme.of(context).textTheme.body2,
                ),
              ),
              Container(
                child: Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color,),
              ),
            ],
          ),
          onPressed: () {
            showDialogLogOut();
          },
        ),
      ),
    );
  }

  void showDialogLogOut() async {
    final result = await showOkCancelAlertDialog(
      context: context,
      title: SIGNOUT,
      okLabel: SIGNOUT,
      cancelLabel: CANCELAR,
      message: "Deseja sair do $APP_NAME ?",
    );
    switch(result) {
      case OkCancelResult.ok:
        setState(() => _loading = true);
        presenter.signOut().then((value) {
          widget.logoutCallback();
        }).catchError((error) {
          setState(() => _loading = false);
          ScaffoldSnackBar.failure(context, _scaffoldKey, SOME_ERROR);
        });
        break;
      case OkCancelResult.cancel:
        break;
    }
  }

  @override
  onFailure(String error) {
    setState(() {
      _loading = false;
    });
    ScaffoldSnackBar.failure(context, _scaffoldKey, error);
  }

  @override
  onSuccess(BaseUser user) {

  }

}