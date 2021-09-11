import 'package:alfocom_app_locker/screens/applist.dart';
import 'package:alfocom_app_locker/screens/reconfirm.dart';
import 'package:alfocom_app_locker/services/database_helpers.dart';
import 'package:alfocom_app_locker/shared_widgets/pin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final pinScreen =
      PinScreen(securityText: 'Please select a PIN to lock your apps :');
  List<String> confirmedPinFromPinScreen;
  String confirmedPin = '';
  bool isPinEmpty = false;

  void initState() {
    super.initState();
    confirmedPinFromPinScreen = null;
    confirmedPin = '';
    isPinEmpty = false;
    pinScreen.pinOneController = TextEditingController();
    pinScreen.pinTwoController = TextEditingController();
    pinScreen.pinThreeController = TextEditingController();
    pinScreen.pinFourController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        DatabaseHelper helper = DatabaseHelper.instance;
        // Check if pintable is empty.
        bool isPinTableEmpty =
            await helper.checkTablePinIsEmpty().then((value) => value == true);

        // If pin table is empty, that means pin is not set up
        // do not allow the user to see the list of apps
        // User first needs to setup the pin to use this application

        if (!isPinTableEmpty) {
          var blockedAppsList = await getBlockedApps();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AppList(blockedAppsList: blockedAppsList)),
              (route) => false);
        } else {
          await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurpleAccent,
                Colors.deepPurple,
              ],
              begin: Alignment.topRight,
            ),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: pinScreen,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ButtonTheme(
                  minWidth: 120.0,
                  height: 45.0,
                  child: RaisedButton(
                    color: Colors.yellow[50],
                    elevation: 5.0,
                    onPressed: () async {
                      isPinEmpty = false;
                      confirmedPin = '';

                      confirmedPinFromPinScreen =
                          List.from(pinScreen.currentPin);

                      if (confirmedPinFromPinScreen.length == 4) {
                        confirmedPinFromPinScreen.forEach((element) {
                          if (element != '') {
                            confirmedPin += element;
                          } else {
                            isPinEmpty = true;
                          }
                        });
                      }
                      if (!isPinEmpty &&
                          confirmedPinFromPinScreen.length == 4) {
                        print(confirmedPin);
                        isPinEmpty = true;
                        confirmedPinFromPinScreen = null;
                        pinScreen.currentPin.clear();
                        pinScreen.currentPin.addAll(['', '', '', '']);
                        pinScreen.pinOneController.text = '';
                        pinScreen.pinTwoController.text = '';
                        pinScreen.pinThreeController.text = '';
                        pinScreen.pinFourController.text = '';
                        pinScreen.pinIndex = 0;

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReConfirm(
                                    pinFromWelcomeScreen: confirmedPin)),
                            (route) => false);
                      } else {
                        print('Incomplete Pin');
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Colors.teal[900]),
                    ),
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void dispose() {
    pinScreen.pinOneController.dispose();
    pinScreen.pinTwoController.dispose();
    pinScreen.pinThreeController.dispose();
    pinScreen.pinFourController.dispose();
    super.dispose();
  }
}

Future<List<BlockedApps>> getBlockedApps() async {
  DatabaseHelper helper = DatabaseHelper.instance;
  // Check if there are any blocked apps saved in the database.
  var blockedAppsList = await helper.queryBlockedApps();

  return blockedAppsList;
}
