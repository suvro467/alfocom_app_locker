import 'package:alfocom_app_locker/shared_widgets/pin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alfocom_app_locker/services/database_helpers.dart';

class UnlockScreen extends StatefulWidget {
  @override
  _UnlockScreenState createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  final _sendToBackgroundChannel = const MethodChannel(
      'alfocom_app_locker.alfocom.in/pinscreensendtobackground');
  final pinScreen =
      PinScreen(securityText: 'Please enter the PIN to un-lock :');
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
      onWillPop: () {
        print('onActivityResult Called : onWillPoP');
        _sendToBackgroundChannel.invokeMethod('sendToBackground');
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
                      if (!isPinEmpty) {
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

                        var isAuthenticated =
                            await authenticatePin(confirmedPin);
                        if (isAuthenticated) {
                          await SystemChannels.platform
                              .invokeMethod('SystemNavigator.pop');
                          print(
                              'onActivityResult Called : isAuthenticated:  Is this printing?');
                          dispose();
                        } else {
                          await showMessageDialogue();
                          print('Incorrect Pin entered.');
                        }
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
    print(
        'onActivityResult Called : From Dart : Checking when this is being printed');
    super.dispose();
  }

  // If user enters wrong pin, alert the user.
  Future<void> showMessageDialogue() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Wrong PIN.'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Incorrect PIN entered.'),
              ],
            ),
          ),
          backgroundColor: Colors.amber[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.elliptical(20, 20),
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              color: Colors.yellow[100],
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(45.0),
                side: BorderSide(color: Colors.teal),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Ok',
              ),
            ),
          ],
        );
      },
    );
  }
}

// Check pin from the db
Future<bool> authenticatePin(String pin) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  // Check if pintable is empty.
  var isPinCorrect = await helper.checkPin(pin).then((value) => value == true);

  return isPinCorrect;
}
