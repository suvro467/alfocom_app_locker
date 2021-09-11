import 'package:device_apps/device_apps.dart';
import 'package:flutter/foundation.dart';

class App extends ChangeNotifier {
  Application application;
  bool selected;

  App({this.application, this.selected});

  void toggleSelected() {
    selected = !selected;
    notifyListeners();
  }
}
