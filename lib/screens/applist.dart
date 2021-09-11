import 'package:alfocom_app_locker/models/app.dart';
import 'package:alfocom_app_locker/screens/check_current_pin.dart';
import 'package:alfocom_app_locker/services/database_helpers.dart';
import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:usage_stats/usage_stats.dart';

class AppList extends StatefulWidget {
  final List<BlockedApps> blockedAppsList;

  AppList({Key key, this.blockedAppsList}) : super(key: key);

  @override
  _AppListState createState() =>
      _AppListState(blockedAppsList: blockedAppsList);
}

class _AppListState extends State<AppList> {
  MethodChannel methodChannel;
  List<App> applications = List<App>();
  List<String> blockedApps = [];
  List<BlockedApps> blockedAppsList;
  _AppListState({this.blockedAppsList});
  bool isPermissionGranted;

  @override
  void initState() {
    super.initState();
    methodChannel =
        MethodChannel('alfocom_app_locker.alfocom.in/backgroundservice');
  }

  @override
  Widget build(BuildContext context) {
    final spinKit = SpinKitCubeGrid(color: Colors.white24);

    return WillPopScope(
      onWillPop: () async {
        print('onWillPop Called : applist.dart');
        try {
          await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        } on Exception catch (e) {
          print('Inside try catch block.');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[900],
          title: Text(
            'App Locker',
            style: TextStyle(
              color: Colors.lightGreen[50],
            ),
          ),
        ),
        drawer: Drawer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Colors.blueGrey[900],
                  Colors.blue,
                ],
              ),
            ),
            child: ListView(
              children: ListTile.divideTiles(
                  //          <-- ListTile.divideTiles
                  context: context,
                  tiles: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                              'images/drawer_header.png',
                            ),
                            fit: BoxFit.fill),
                      ),
                      child: DrawerHeader(child: Container()),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            Colors.indigo[100],
                            Colors.blue,
                          ],
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.fiber_pin),
                        title: Text(
                          'Change PIN',
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CheckCurrentPin()),
                          );
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            Colors.indigo[100],
                            Colors.blue,
                          ],
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.close_sharp),
                        title: Text(
                          'Exit',
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () async {
                          await SystemChannels.platform
                              .invokeMethod('SystemNavigator.pop');
                        },
                      ),
                    ),
                  ]).toList(),
            ),
          ),
        ),
        body: Container(
          child: FutureBuilder(
            future: retrieveApplications(),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? Stack(children: <Widget>[
                      ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          final item = snapshot.data[index];
                          return ChangeNotifierProvider.value(
                            value: item as App,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: <Color>[
                                    Colors.blueGrey[900],
                                    Colors.blue[200]
                                  ],
                                ),
                              ),
                              child: ListTile(
                                leading: item.application is ApplicationWithIcon
                                    ? CircleAvatar(
                                        backgroundImage:
                                            MemoryImage(item.application.icon),
                                        backgroundColor: Colors.white,
                                      )
                                    : null,
                                title: Text(
                                  '${item.application.appName}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                subtitle: Text(
                                  '${item.application.category.toString().substring(20) != 'undefined' ? item.application.category.toString().substring(20) : ''}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                trailing: Consumer<App>(
                                  builder: (context, provider, _) =>
                                      CircularCheckBox(
                                          activeColor: Colors.blueGrey[900],
                                          checkColor: Colors.red[50],
                                          value: item.selected,
                                          onChanged: (value) {
                                            // Select or deselect the application.
                                            provider.toggleSelected();
                                          }),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        right: 60,
                        bottom: 40,
                        child: Visibility(
                          visible: snapshot.hasData ? true : false,
                          child: RaisedButton(
                            onPressed: () async {
                              // Only selected apps are required to be locked.
                              blockedApps = applications
                                  .where((element) => element.selected == true)
                                  .map((e) => e.application.packageName)
                                  .toList();

                              // If no apps are selected then no need to start the service
                              bool needToStartService =
                                  blockedApps.length > 0 ? true : false;

                              // Pass the blockedApps list to the method
                              // which is passed to the java code.

                              await _save(blockedApps, needToStartService);

                              await SystemChannels.platform
                                  .invokeMethod('SystemNavigator.pop');
                            },
                            //color: Colors.indigo[400],
                            color: Colors.blueGrey[900],
                            elevation: 5.0,
                            child: Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.yellow[200],
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(90.0),
                              side: BorderSide(color: Colors.blueGrey[800]),
                            ),
                          ),
                        ),
                      ),
                    ])
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[Colors.blueGrey[900], Colors.blue],
                        ),
                      ),
                      child: Center(
                        child: spinKit,
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }

  Future<List<App>> retrieveApplications() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
      onlyAppsWithLaunchIntent: true,
      includeSystemApps: true,
      includeAppIcons: true,
    );

    // Sort the package name in ascending order.
    apps.sort((a, b) => a.appName.compareTo(b.appName));

    // Remove this app (alfocom_app_locker) from the list of apps.
    apps.removeWhere(
        (element) => element.packageName == 'in.alfocom.alfocom_app_locker');

    // Load the objects of the Application class into the
    // list of custom App objects.
    for (var app in apps) {
      var theApp = App(application: app, selected: false);
      applications.add(theApp);
    }

    if (blockedAppsList != null) {
      if (blockedAppsList.length > 0) {
        for (var app in blockedAppsList) {
          for (var installedApps in applications) {
            if (installedApps.application.packageName == app.packageName) {
              installedApps.selected = true;
            }
          }
        }
      }
    }
    // check if usage access permission is granted
    isPermissionGranted =
        await UsageStats.checkUsagePermission().then((value) => value == true);

    // If User Access Permission is not granted
    // show a message to the user.
    if (!isPermissionGranted) {
      await showAlertDialogueForPermissions();
      UsageStats.grantUsagePermission();
    }

    // Return the list of applications
    return applications;
  }

  Future<void> _save(List<String> selectedApps, bool needToStartService) async {
    await createBackgroundService(selectedApps, needToStartService);
  }

  Future<void> createBackgroundService(
      List<String> selectedApps, bool needToStartService) async {
    try {
      Map<String, dynamic> data = {};

      // Build the data to be sent to Java code from here
      // The key names are 0,1,2 .....
      // and the values are the name of the selected packages.
      for (int i = 0; i < selectedApps.length; i++) {
        data['$i'] = selectedApps[i];
      }

      data['needToStartService'] = needToStartService;
      final int result =
          await methodChannel.invokeMethod('createBackgroundService', data);
      print('Number of packages selected : $result');
    } on Exception catch (e) {
      print('Exception : ${e.toString()}');
    }
  }

  Future<void> showAlertDialogueForPermissions() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Permissions'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Usage Access Permission.'),
                Text(
                    'You have to provide usage access permission to the app to work.'),
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
