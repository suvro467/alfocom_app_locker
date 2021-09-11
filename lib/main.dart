import 'package:alfocom_app_locker/screens/applist.dart';
import 'package:alfocom_app_locker/screens/check_current_pin.dart';
import 'package:alfocom_app_locker/screens/reconfirm.dart';
import 'package:alfocom_app_locker/screens/unlockscreen.dart';
import 'package:alfocom_app_locker/screens/welcome.dart';
import 'package:alfocom_app_locker/services/database_helpers.dart';
import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';

var blockedAppsList;
bool isPermissionGranted;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: isFirstTime(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          var isPinTableEmpty = snapshot.data;

          if (snapshot.hasData) {
            if (isPinTableEmpty) {
              return WelcomeScreen();
            } else {
              return AppList(blockedAppsList: blockedAppsList);
            }
          } else {
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
      routes: {
        '/welcome': (context) => WelcomeScreen(),
        '/reconfirm_pin': (context) => ReConfirm(),
        '/applist': (context) => AppList(blockedAppsList: blockedAppsList),
        '/unlockscreen': (context) => UnlockScreen(),
        '/checkcurrentpin': (context) => CheckCurrentPin(),
      },
    ),
  );
}

// Check if the app is run for the first time.
Future<bool> isFirstTime() async {
  // We need to provide usage access permission to the app
  // otherwise the app won't work.
  UsageStats.grantUsagePermission();

  DatabaseHelper helper = DatabaseHelper.instance;
  // Check if pintable is empty.
  var isPinTableEmpty =
      await helper.checkTablePinIsEmpty().then((value) => value == true);

  await getBlockedApps();

  return isPinTableEmpty;
}

Future<List<BlockedApps>> getBlockedApps() async {
  DatabaseHelper helper = DatabaseHelper.instance;
  // Check if there are any blocked apps saved in the database.
  blockedAppsList = await helper.queryBlockedApps();

  return blockedAppsList;
}
