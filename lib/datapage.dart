import 'dart:async';

import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:new_flutter_app/utils/string_formatter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SecondRoute extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Datapage();
  }
}

class Datapage extends StatefulWidget{
  const Datapage({super.key});

  @override
  _DataPage createState() => _DataPage();
}

class _DataPage extends State<Datapage>{
  late BluetoothConnection _connection;
  String gauss = "";
  int index = 1;
  double minV = 0;
  double maxV = 0;
  double avgV = 0;
  double minG = 0;
  double maxG = 0;
  double avgG = 0;
  int count = 0;
  List<List<double>> servArr = [];

  final List<FlSpot> data2 = [FlSpot(0, 0)];
    final List<FlSpot> data3 = [FlSpot(0, 0)];
  

  @override
  void initState(){

    super.initState();
    _connectToDevice();
    // listenForData();
  }
  

  Future<void> _connectToDevice() async {
    List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    
    String deviceAddress = '00:23:00:00:EE:BA'; 
    BluetoothDevice device = devices.firstWhere((d) => d.address == deviceAddress);
    
    
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      print('Connected to ${device.name}');
    } catch (error) {
      print('Error connecting to device: $error');
    }
    listenForData();
    
  }
  

  void listenForData(){
  _connection?.input?.listen((data) {

    print('Received data: ${String.fromCharCodes(data)}');
      if(mounted){
        setState(() {
          gauss = String.fromCharCodes(data); // Update your data
      // Update your chart data (e.g., data2 and data3)
      var arr = stringFormatter(gauss);
      data2.add(FlSpot(index + 1, arr[0]));
      data3.add(FlSpot(index + 1, arr[1]));
      if(arr[0] < minV){
        minV = arr[0];
      }else if(arr[0]> maxV){
        maxV = arr[0];
      }
      if(arr[1] < minG){
        minG = arr[1];
      }else if(arr[1]> maxG){
        maxG = arr[1];
      }
      index = index + 1;
      avgV = (avgV+arr[0])/index;
      avgG = (avgG+arr[1])/index;

      
     
      if (data2.length > 10) data2.removeAt(0);
      if (data3.length > 20) data3.removeAt(0);
      
      if(count == 250){
        sendDataToServer(userId: "141", data: servArr.toString());
        count = 0;
      }else{
        servArr.add([arr[0], arr[1]]);
        count = count+1;
      }
    }
    );
    }

    
  });
}
  Future<void> sendDataToServer({
  required String userId,
  required String data,
}) async {
  try {
    final uri = Uri.parse('https://getwebup.com/data.php').replace(
      queryParameters: {
        'user_id': userId,
        'data': data,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('Success: ${responseData['message']}');
    } else {
      print('Error: ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}

  
  @override
  Widget build(BuildContext context) {
    
    
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(tabs: [
              Tab(text: "Volts",),
              Tab(text: "Gauss",),
              Tab(text: "Server"),
            ]),
            title: const Text('CSIR - NPL'),
            backgroundColor: Colors.white,
        shadowColor: Colors.brown,
        elevation: 4,
        centerTitle: true,
          ),
          body: TabBarView(
            children: [Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 10),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Volts  ", style: TextStyle(fontWeight: FontWeight.bold),), 
                            Image(image: AssetImage('assets/high-voltage.png'),
                            width: 20,
                            height: 20,),
                            Text(": ", style: TextStyle(fontWeight: FontWeight.bold),),
                            Text("${data2.last.y}"),
                            SizedBox(width: 50,),
                            Text("Gauss  ", style: TextStyle(fontWeight: FontWeight.bold),), 
                            Image(image: AssetImage('assets/magnet.png'),
                            width: 20,
                            height: 20,),
                            Text(": ", style: TextStyle(fontWeight: FontWeight.bold),),
                            Text("${data3.last.y}"),
                          ],
                        ),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Average Volts: ",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                            Text("${avgV.toStringAsFixed(2)}", style: TextStyle(fontSize: 16),)
                          ],
                        ),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Min Volts: ",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                            Text("${minV.toString()}", style: TextStyle(fontSize: 16),),
                            SizedBox(width: 20,),
                            Text("Max Volts: ",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                            Text("${maxV.toStringAsFixed(2)}", style: TextStyle(fontSize: 16),)
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                // Text(gauss),
                Container(
                  // color: Color.fromARGB(255, 40, 40, 43),
                  height: 500,
                  width: MediaQuery.of(context).size.width,
                  child: LineChart(
                  LineChartData(
                    minY: -1.5,
                    maxY: 5.5,
                    // gridData: FlGridData(show: false),
                    // titlesData: FlTitlesData(show: false),
                  
                    // borderData: FlBorderData(show: false),
                    lineBarsData: [LineChartBarData(
                      spots: data2,
                      barWidth: 7.0,
                      isCurved: true,
                      belowBarData: BarAreaData(show: false),
                      gradient: LinearGradient(colors: <Color>[
                        Color(0xff1f005c),
                        Color(0xff5b0060),
                        Color(0xff870160),
                        Color(0xffac255e),
                        Color(0xffca485c),
                        Color(0xffe16b5c),
                        Color(0xfff39060),
                        Color(0xffffb56b),
                      ],)
                  
                    ),
                    ],
                    backgroundColor: Color.fromARGB(255, 18, 29, 47),
                    clipData: FlClipData.all(),
                  ),
                  duration: Duration(milliseconds: 150), // Optional
                  curve: Curves.linear, // Optional
                  ),
                ),
                
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 10),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Volts  ", style: TextStyle(fontWeight: FontWeight.bold),), 
                            Image(image: AssetImage('assets/high-voltage.png'),
                            width: 20,
                            height: 20,),
                            Text(": ", style: TextStyle(fontWeight: FontWeight.bold),),
                            Text("${data2.last.y}"),
                            SizedBox(width: 50,),
                            Text("Gauss  ", style: TextStyle(fontWeight: FontWeight.bold),), 
                            Image(image: AssetImage('assets/magnet.png'),
                            width: 20,
                            height: 20,),
                            Text(": ", style: TextStyle(fontWeight: FontWeight.bold),),
                            Text("${data3.last.y}"),
                          ],
                        ),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Average Gauss: ",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                            Text("${avgG.toStringAsFixed(2)}", style: TextStyle(fontSize: 16),)
                          ],
                        ),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Min Gauss: ",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                            Text("${minG.toString()}", style: TextStyle(fontSize: 16),),
                            SizedBox(width: 20,),
                            Text("Max Gauss: ",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                            Text("${maxG.toStringAsFixed(2)}", style: TextStyle(fontSize: 16),)
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  // color: Color.fromARGB(255, 40, 40, 43),
                  height: 500,
                  width: MediaQuery.of(context).size.width,
                  child: LineChart(
                  LineChartData(
                    minY: -400,
                    maxY: 600,
                    // gridData: FlGridData(show: false),
                    // titlesData: FlTitlesData(show: false),
                  
                    // borderData: FlBorderData(show: false),
                    lineBarsData: [LineChartBarData(
                      spots: data3,
                      barWidth: 7.0,
                      isCurved: true,
                      belowBarData: BarAreaData(show: false),
                      gradient: LinearGradient(colors: <Color>[
                        Color(0xff1f005c),
                        Color(0xff5b0060),
                        Color(0xff870160),
                        Color(0xffac255e),
                        Color(0xffca485c),
                        Color(0xffe16b5c),
                        Color(0xfff39060),
                        Color(0xffffb56b),
                      ],)
                  
                    ),
                    ],
                    backgroundColor: Color.fromARGB(255, 18, 29, 47),
                    clipData: FlClipData.all(),
                  ),
                  duration: Duration(milliseconds: 150), // Optional
                  curve: Curves.linear, // Optional
                  ),
                ),
                
              ],
            ),
            Center(
              child: BlinkText("Sending data to the Server.....",),
            ),
          ]
          ),
        ),
      ),
    );
  }
}