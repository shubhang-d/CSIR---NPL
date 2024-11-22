import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as fbs;
import 'package:new_flutter_app/datapage.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const BluetoothSetupPage());
}


class BluetoothSetupPage extends StatefulWidget {
  const BluetoothSetupPage({Key? key}) : super(key: key);

  @override
  _BluetoothSetupPageState createState() => _BluetoothSetupPageState();
}

class _BluetoothSetupPageState extends State<BluetoothSetupPage> with WidgetsBindingObserver{
  late fbs.BluetoothConnection _connection;
  String gauss = "";
  bool isBluetoothEnabled = false;
  static const platform =  MethodChannel('com.example.open_bluetooth');
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();




  Future<void> _openBluetoothSettings() async {
    try {
      await platform.invokeMethod('openBluetoothSettings');
    } on PlatformException catch (e) {
      print("Failed to open Bluetooth settings: '${e.message}'.");
    }
  }

  @override
  void initState(){
    super.initState();
    checkBluetoothStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
       checkBluetoothStatus();
    }
  }

  void checkBluetoothStatus() async {
    fbs.BluetoothState state = await fbs.FlutterBluetoothSerial.instance.state;
    if (state == fbs.BluetoothState.STATE_ON) {
      setState(() {
        isBluetoothEnabled = state.isEnabled;
      });
    } else if (state == fbs.BluetoothState.STATE_OFF) {
      setState(() {
        isBluetoothEnabled = state.isEnabled;
      });
      print("Bluetooth is disabled.");
    }
  }

  void startBluetoothOperations() async{
    await requestPermissions();

    // _connectToDevice();
  }

  

  Future<void> requestPermissions() async {
  // Request Bluetooth Scan and Connect permissions together
  var bluetoothPermissions = await Future.wait([
    Permission.bluetoothScan.request(),
    Permission.bluetoothConnect.request(),
  ]);

  // Check if any Bluetooth permission is denied
  if (bluetoothPermissions.any((permission) => permission.isDenied)) {
    print('Bluetooth permissions denied');
    return;
  }

  // Request location permission
  var locationPermission = await Permission.locationWhenInUse.request();
  if (locationPermission.isDenied) {
    print('Location permission denied');
    return;
  }

  // If all permissions are granted, proceed with Bluetooth functionality
  print('All necessary permissions granted');
  navigatorKey.currentState?.pushNamed('/dataScreen');
  // You can now start scanning for Bluetooth devices
}


  
  


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      routes: {
        // '/': (context) => BluetoothSetupPage(),
        '/dataScreen': (context) => SecondRoute(),
      },
      home: Scaffold(
      appBar: AppBar(
        title: Text('CSIR - NPL'),
        backgroundColor: Colors.white,
        shadowColor: Colors.brown,
        elevation: 4,
        centerTitle: true,
      ),
      body: Center(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(gauss),
                  Text("Bluetooth Status: ${isBluetoothEnabled ? "ON": "OFF"}"),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 150),
                    child: ElevatedButton(onPressed:() {
                                    _openBluetoothSettings();
                                    checkBluetoothStatus();
                                  },
                                   child: Text("Change Settings")
                                  ),
                  ),
                ],
              ),
              
              isBluetoothEnabled ? FilledButton(onPressed: () {
                startBluetoothOperations();
              }, child: Text("Next")) :Padding(
                padding: const EdgeInsets.only(left: 50, right: 50),
                child: Text("Note: Please click on 'Change Settings' and enable Bluetooth and connect to HC-05. The pairing pin is 1234."),
              )
            ],
          )
        )
      ),
    ),
    );
  }
}
