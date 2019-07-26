import 'package:ble_scan/beacon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble/flutter_ble.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Scan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool isScanning = false;

  FlutterBle flutterBlue = FlutterBle.instance;

  Map<String, Beacon> scanMap = Map();
  List<Beacon> scanList = List();

  var scanSubscription;

  AnimationController _animationController;
  Animation<Color> _animateColor;
  Animation<double> _animateIcon;
  Curve _curve = Curves.easeOut;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });

    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _animateColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: _curve,
      ),
    ));

    scanBLE();
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    stopBLE();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView.builder(
          itemBuilder: (context, length) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                    scanList[length].address,
                    style: TextStyle(fontSize: 22.0),
                  ),
                  SizedBox(
                      width: 20.0,
                    ),
                    Text(
                      "RSSI: ${scanList[length].rssi}",
                      style: TextStyle(fontSize: 16.0),
                    ),
                    
                    
                  ],
                ),
              ),
            );
          },
          itemCount: scanList.length,
        ).build(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _animateColor.value,
        label: Text(isScanning ? 'Stop' : 'Scan'),
        elevation: 10.0,
        icon: AnimatedIcon(
          icon: AnimatedIcons.play_pause,
          progress: _animateIcon,
        ),
        onPressed: () {
          isScanning ? stopBLE() : scanBLE();
        },
        tooltip: 'Toggle',
      ),
    );
  }

  /// Stop scanning
  void stopBLE() {
    _animationController.reverse();

    setState(() {
      isScanning = false;
    });
    scanSubscription.cancel();
  }

  void scanBLE() {
    _animationController.forward();

    setState(() {
      isScanning = true;
    });

    scanSubscription = flutterBlue.scan().listen((scanResult) {
      Beacon beacon = Beacon(
          scanResult.device.id.id,
          scanResult.rssi,
          scanResult.device,
          scanResult.advertisementData,
          new DateTime.now().millisecondsSinceEpoch);
      scanMap[scanResult.device.id.id] = beacon;
      updateScanList();
    });
  }

  void updateScanList() {
    scanMap.forEach((String key, Beacon value) => {
          if (scanList.contains(value)){
              if ((new DateTime.now().millisecondsSinceEpoch -
                      value.timestamp) >
                  5000){
                  setState(() {
                    scanMap.remove(key);
                    scanList.remove(value);
                  })
                }
              else {
                setState(() {
                  scanMap[key] = value;
                  Beacon beacon = value;
                  beacon.timestamp = new DateTime.now().millisecondsSinceEpoch;
                  scanList.remove(value);
                  scanList.add(beacon);
                })
                }
            }
          else {
              setState(() {
                scanList.add(value);
              })
            }
        });
  }
}
