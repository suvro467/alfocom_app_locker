import 'package:alfocom_app_locker/screens/applist.dart';
import 'package:alfocom_app_locker/screens/welcome.dart';
import 'package:alfocom_app_locker/services/database_helpers.dart';
import 'package:alfocom_app_locker/shared_widgets/pin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReConfirm extends StatefulWidget {
  final String pinFromWelcomeScreen;

  ReConfirm({this.pinFromWelcomeScreen});
  @override
  _ReConfirmState createState() => _ReConfirmState();
}

class _ReConfirmState extends State<ReConfirm> {
  final pinScreen = PinScreen(securityText: 'Please re-confirm the PIN :');
  List<String> confirmedPinFromPinScreen;
  String confirmedPin = '';
  bool isPinEmpty = false;

  void initState() {
    super.initState();
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
                      confirmedPinFromPinScreen.forEach((element) {
                        if (element != '') {
                          confirmedPin += element;
                        } else {
                          isPinEmpty = true;
                        }
                      });
                      if (!isPinEmpty &&
                          confirmedPin == widget.pinFromWelcomeScreen) {
                        print('Both pins are equal');

                        // Store the pin the database.
                        _savePin(confirmedPin);

                        var blockedAppsList = await getBlockedApps();

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AppList(blockedAppsList: blockedAppsList)),
                            (route) => false);
                      } else {
                        print('Sorry, pins are not the same.');
                        showMessageDialogue();
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Colors.teal[900]),
                    ),
                    child: Text(
                      'Re-Confirm',
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

  void showMessageDialogue() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            content: Text(
              'Please try again.',
            ),
            backgroundColor: Colors.amber[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.elliptical(20, 20),
              ),
            ),
            title: Text(
              'PIN mismatch.',
            ),
            actions: [
              RaisedButton(
                color: Colors.yellow[100],
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45.0),
                  side: BorderSide(color: Colors.teal),
                ),
                onPressed: () {
                  // If pins do not match go to the welcome screen
                  // where the user has to re-enter the PINS from the beginning.
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => WelcomeScreen()),
                      (route) => false);
                },
                child: Text(
                  'Ok',
                ),
              ),
            ],
          );
        });
  }

  void _savePin(String confirmedPin) async {
    DatabaseHelper databaseHelper = DatabaseHelper.instance;

    try {
      await databaseHelper.insertPin(confirmedPin);
      print('Pin saved successfully.');
    } on Exception catch (e) {
      print('Pin could not be saved: ${e.toString()}');
    }
  }

  Future<List<BlockedApps>> getBlockedApps() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    // Check if there are any blocked apps saved in the database.
    var blockedAppsList = await helper.queryBlockedApps();

    return blockedAppsList;
  }
}
