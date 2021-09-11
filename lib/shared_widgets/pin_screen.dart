import 'package:alfocom_app_locker/shared_widgets/keyboard_number.dart';
import 'package:alfocom_app_locker/shared_widgets/pin_number.dart';
import 'package:flutter/material.dart';

class PinScreen extends StatelessWidget {
  final List<String> currentPin = ['', '', '', ''];
  TextEditingController pinOneController; // = TextEditingController();
  TextEditingController pinTwoController; // = TextEditingController();
  TextEditingController pinThreeController; // = TextEditingController();
  TextEditingController pinFourController;
  String securityText;

  PinScreen(
      {this.pinOneController,
      this.pinTwoController,
      this.pinThreeController,
      this.pinFourController,
      this.securityText});

  final outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: BorderSide(
      color: Colors.transparent,
    ),
  );

  int pinIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          //buildExitButton(),
          SizedBox(
            height: 170.0,
          ),
          Container(
            alignment: Alignment(0, 0.5),
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                buildSecurityText(),
                SizedBox(
                  height: 40.0,
                ),
                buildPinRow(),
              ],
            ),
          ),
          buildNumberPad(),
        ],
      ),
    );
  }

  buildExitButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: MaterialButton(
            onPressed: () {
              //Navigator.pop(context);
            },
            height: 50.0,
            minWidth: 50.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: Icon(
              Icons.clear,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  buildSecurityText() {
    return Text(
      securityText,
      style: TextStyle(
          color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 18.0),
    );
  }

  buildPinRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        PINNumber(
          outlineInputBorder: outlineInputBorder,
          textEditingController: pinOneController,
        ),
        PINNumber(
          outlineInputBorder: outlineInputBorder,
          textEditingController: pinTwoController,
        ),
        PINNumber(
          outlineInputBorder: outlineInputBorder,
          textEditingController: pinThreeController,
        ),
        PINNumber(
          outlineInputBorder: outlineInputBorder,
          textEditingController: pinFourController,
        ),
      ],
    );
  }

  buildNumberPad() {
    return Expanded(
      child: Container(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  KeyboardNumber(
                    n: 1,
                    onPressed: () {
                      pinIndexSetup('1');
                    },
                  ),
                  KeyboardNumber(
                    n: 2,
                    onPressed: () {
                      pinIndexSetup('2');
                    },
                  ),
                  KeyboardNumber(
                    n: 3,
                    onPressed: () {
                      pinIndexSetup('3');
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  KeyboardNumber(
                    n: 4,
                    onPressed: () {
                      pinIndexSetup('4');
                    },
                  ),
                  KeyboardNumber(
                    n: 5,
                    onPressed: () {
                      pinIndexSetup('5');
                    },
                  ),
                  KeyboardNumber(
                    n: 6,
                    onPressed: () {
                      pinIndexSetup('6');
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  KeyboardNumber(
                    n: 7,
                    onPressed: () {
                      pinIndexSetup('7');
                    },
                  ),
                  KeyboardNumber(
                    n: 8,
                    onPressed: () {
                      pinIndexSetup('8');
                    },
                  ),
                  KeyboardNumber(
                    n: 9,
                    onPressed: () {
                      pinIndexSetup('9');
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: 60.0,
                    child: MaterialButton(
                      onPressed: () {},
                      child: SizedBox(),
                    ),
                  ),
                  KeyboardNumber(
                    n: 0,
                    onPressed: () {
                      pinIndexSetup('0');
                    },
                  ),
                  Container(
                    width: 60.0,
                    child: MaterialButton(
                      height: 60.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60.0),
                      ),
                      onPressed: () {
                        clearPin();
                      },
                      child: Icon(
                        Icons.backspace,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void pinIndexSetup(String s) {
    // If number of pins entered is greater than 4 then do not do anything
    int numberOfBlankPINs = 0;

    // We are starting from index 1 to ensure that the "currentPin" contains at least one
    // entered string
    for (var index = 0; index < currentPin.length; index++) {
      if (currentPin[index] == "") numberOfBlankPINs++;
    }

    // Only if any of the pins is empty in "currentPin" then only procees with the next steps
    // otherwise not, because if all the pins are entered then we do not want to proceed with
    // the following proceedings
    if (numberOfBlankPINs > 0 && numberOfBlankPINs <= 4) {
      if (pinIndex == 0)
        pinIndex = 1;
      else if (pinIndex < 4) pinIndex++;

      setPin(pinIndex, s);
      currentPin[pinIndex - 1] = s;
      String strPin = '';
      currentPin.forEach((element) {
        strPin += element;
      });
      if (pinIndex == 4) {
        // TODO
        print(strPin);
      }
    }
  }

  void setPin(int n, String s) {
    switch (n) {
      case 1:
        pinOneController.text = s;
        break;
      case 2:
        pinTwoController.text = s;
        break;
      case 3:
        pinThreeController.text = s;
        break;
      case 4:
        pinFourController.text = s;
        break;

      default:
    }
  }

  void clearPin() {
    if (pinIndex == 0)
      pinIndex = 0;
    else if (pinIndex == 4) {
      setPin(pinIndex, '');
      currentPin[pinIndex - 1] = '';
      pinIndex--;
    } else {
      setPin(pinIndex, '');
      currentPin[pinIndex - 1] = '';
      pinIndex--;
    }
  }
}
