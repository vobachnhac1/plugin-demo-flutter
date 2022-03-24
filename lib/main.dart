import 'package:flutter/material.dart';
import 'package:print_pos_blue/src/event_print_pos.dart';
import 'src/bluetooth_code.dart';

import 'dart:collection';
import 'dart:typed_data';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/services.dart';
import 'package:measure_size/measure_size.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key,  this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    if (_connected)
      tips =
      'Đã kết nối'; // Khi vào trang sẽ check xem đã kết nối trước đó hay chưa
    WidgetsBinding.instance?.addPostFrameCallback((_) => initBluetooth());

    // get tín hiệu đầu tiên
    _getMessage().then((message) {
      setState(() {
        _message = message;
      });
    });
  }

  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(
        timeout: Duration(seconds: 4)); // scan trong 4s, tìm device

    bool isConnected = false;
    isConnected =  await bluetoothPrint.isConnected;
    bluetoothPrint.state.listen((state) {
      print('cur device status: $state');
      switch (state) {
        case BluetoothCode.CONNECTED:
          setState(() {
            _connected = true;
            print("bluetooth device state: connected");
            tips = 'bluetooth device state: connected';
          });
          break;
        case BluetoothCode.DISCONNECTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnected");
            tips = "bluetooth device state: disconnected";
          });
          break;
        case BluetoothCode.DISCONNECT_REQUESTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnect requested");
            tips = "bluetooth device state: disconnect requested";
          });
          break;
        case BluetoothCode.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning off");
            tips = "bluetooth device state: bluetooth turning off";
          });
          break;
        case BluetoothCode.STATE_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth off");
            tips = "bluetooth device state: bluetooth off";
          });
          break;
        case BluetoothCode.STATE_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth on");
            tips = "bluetooth device state: bluetooth on";
          });
          break;
        case BluetoothCode.STATE_TURNING_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning on");
            tips = "bluetooth device state: bluetooth turning on";
          });
          break;
        case BluetoothCode.ERROR:
          setState(() {
            _connected = false;
            print("bluetooth device state: error");
            tips = "bluetooth device state: error";
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return; // nếu chưa kết nối thì không làm gì

    if (isConnected != null && isConnected ) {
      setState(() {
        _connected = true;
      });
    }
    bluetoothPrint.stopScan();
  }

  void _onConnect() async {
    // chỗ này đọc lệnh chắc mọi người cũng hiểu được :v
    if (_device != null && _device.address != null) {
      await bluetoothPrint.connect(_device);
    } else {
      setState(() {
        tips = 'Vui lòng chọn thiết bị';
      });
      print('please select device');
    }
  }

  void _onDisconnect() async {
    await bluetoothPrint.disconnect();
    // bool? isConnected = await bluetoothPrint.isConnected;
    setState(() {
      _connected = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child:  SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Text(tips),
                  ),
                ],
              ),
              Divider(),
              StreamBuilder<List<BluetoothDevice>>(
                stream: bluetoothPrint.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data != null && snapshot.data.length >0 ? snapshot.data
                  .map((d) => ListTile(
                    title: Text(d.name ?? ''),
                    subtitle: Text(d.address  ??''),
                    onTap: () async {
                      setState(() {
                        _device = d;
                      });
                    },
                    trailing: _device != null &&
                        _device.address == d.address
                        ? Icon(
                      Icons.check,
                      color: Colors.green,
                    )
                        : null,
                  ))
                      .toList() : [],
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        OutlineButton(
                          child: Text('Kết nối'),
                          onPressed: _connected ? null : _onConnect,
                        ),
                        SizedBox(width: 10.0),
                        OutlineButton(
                          child: Text('Ngắt kết nối'),
                          onPressed: _connected ? _onDisconnect : null,
                        ),
                      ],
                    ),

                    // OutlineButton(
                    //   child: Text('In hóa đơn'),
                    //   onPressed: _connected ? _sendData : null,
                    // ),
                    Text(_message),
                    SizedBox(width: 10.0),
                    OutlineButton(
                      child: Text("Gửi tín hiệu"),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
              ScreenTest()
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: bluetoothPrint.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => bluetoothPrint.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () =>
                    bluetoothPrint.startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }


  bool _connected = false;
  BluetoothDevice _device;
  String tips = 'Không có thiết bị được kết nối';

  Map<String, String> arrState = Map<String, String>();
  static const platform = MethodChannel("com.clv.demo/print");
  String _message = "No message yet";

  Future<String> _getMessage() async {
    String value = "";
    try {
      value = await EventPrintPos.getMessage();
    } catch (e) {
      print(e);
    }
    return value;
  }

  Future<dynamic> _sendMessage() async {
    // kích thước ảnh bitmapInput
    //printerDpi - printerWidthMM -printerNbrCharactersPerLine -widthMax - heightMax
    screenshotController
        .capture(delay: Duration(milliseconds: 10))
        .then((capturedImage) async {
      var _sendData = <String, dynamic>{
        "bitmapInput": capturedImage,
        "printerDpi": 190,
        "printerWidthMM": int.parse('80'),
        "printerNbrCharactersPerLine": 32,
        "widthMax": 580,
        "heightMax": 400,
      };
      var result =  await EventPrintPos.sendSignalPrint(capturedImage);
      print(result);
    }).catchError((onError) {
      print(onError);
    });
  }


  ScreenshotController screenshotController = ScreenshotController();
  Size screenTestSize = Size.zero;
  Widget ScreenTest() {
    var pixRatio = MediaQuery.of(context).devicePixelRatio;
    return MeasureSize(
        onChange: (size) {
          screenTestSize = size;
          print("ScreenTest height ${size.height} / width ${size.width}");
        },
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Screenshot(
                controller: screenshotController,
                child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: RenderFormTable()),
              ),
              SizedBox(
                height: 25,
              ),
              // ElevatedButton(
              //   child: Text(
              //     'Capture Above Widget',
              //   ),
              //   onPressed: () {
              //     screenshotController
              //         .capture(delay: Duration(milliseconds: 10))
              //         .then((capturedImage) async {
              //       ShowCapturedWidget(context, capturedImage);
              //     }).catchError((onError) {
              //       print(onError);
              //     });
              //   },
              // ),
              // ElevatedButton(
              //   child: Text(
              //     'Capture An Invisible Widget',
              //   ),
              //   onPressed: () {
              //     var container = Container(
              //         padding: const EdgeInsets.all(30.0),
              //         decoration: BoxDecoration(
              //           border:
              //               Border.all(color: Colors.blueAccent, width: 5.0),
              //           color: Colors.redAccent,
              //         ),
              //         child: Text(
              //           "This is an invisible widget",
              //           style: Theme.of(context).textTheme.headline6,
              //         ));
              //     screenshotController
              //         .captureFromWidget(
              //             InheritedTheme.captureAll(
              //                 context, Material(child: container)),
              //             delay: Duration(seconds: 1))
              //         .then((capturedImage) {
              //       ShowCapturedWidget(context, capturedImage);
              //     });
              //   },
              // ),
            ],
          ),
        ));
  }

  TableBorder BoderCustom() {
    return TableBorder.all(
      color: Colors.black,
      //style: BorderStyle.solid,
      width: 0.5,
    );
  }

  Future<dynamic> ShowCapturedWidget(
      BuildContext context, Uint8List capturedImage) {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text("Captured widget screenshot"),
        ),
        body: Center(
            child: capturedImage != null
                ? Image.memory(capturedImage)
                : Container()),
      ),
    );
  }

  Size heightCol = Size.zero;
  Size heigthItemCd = Size.zero;
  Size heigthPKG = Size.zero;
  Size heigthCQTY = Size.zero;
  Size heigthCNO = Size.zero;
  Size heigthColor = Size.zero;
  Size heigthAOPO = Size.zero;

  Widget RenderFormTable() {
    double width = MediaQuery.of(context).size.width;
    var widthCol = width * 0.75;
    return Column(
      children: [
        Row(
          children: <Widget>[
            MeasureSize(
              onChange: (size) {
                setState(() {
                  heightCol = size;
                });
                // print("heigth : ${size.height}");
                // print("width : ${size.width}");
              },
              child: Column(children: [
                Container(
                  width: widthCol,
                  child: Table(
                    border: BoderCustom(),
                    children: [
                      TableRow(children: [
                        Container(
                            padding: EdgeInsets.all(10),
                            child: Column(children: [
                              Text("WH-PKS2 (PKS2-C)",
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)
                                //
                                // Theme.of(context)
                                //     .textTheme
                                //     .headline4
                                //     .copyWith(
                                //         color: Colors.black87,
                                //         fontWeight: FontWeight.bold),
                              ),
                              Text("HoChiMinh,VietNam",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 12,
                                  )),
                            ])),
                      ]),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                        width: width - widthCol,
                        alignment: Alignment.topRight,
                        child: Table(
                          border: BoderCustom(),
                          children: [
                            TableRow(children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Text("DO No.",
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)

                                  // Theme.of(context)
                                  //     .textTheme
                                  //     .subtitle1
                                  //     .copyWith(
                                  //         color: Colors.black87,
                                  //         fontWeight: FontWeight.bold),
                                ),
                              ),
                            ]),
                          ],
                        )),
                    Container(
                        width: widthCol - (width - widthCol),
                        alignment: Alignment.topRight,
                        child: Table(
                          border: BoderCustom(),
                          children: [
                            TableRow(children: [
                              Container(
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                    child: Text("DO_20211123_W46_0059",
                                        style: TextStyle(
                                            color: Colors.black87, fontSize: 14)
                                      // Theme.of(context)
                                      //     .textTheme
                                      //     .subtitle1
                                      //     .copyWith(color: Colors.black87)
                                    ),
                                  )),
                            ]),
                          ],
                        )),
                  ],
                ),
                Row(
                  children: [
                    Container(
                        width: width - widthCol,
                        child: Table(
                          border: BoderCustom(),
                          children: [
                            TableRow(children: [
                              Container(
                                height: heigthAOPO.height,
                                padding: EdgeInsets.all(10),
                                alignment: Alignment.center,
                                child: Text("AO /PO No.",
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ]),
                          ],
                        )),
                    MeasureSize(
                      onChange: (size) {
                        heigthAOPO = size;
                      },
                      child: Container(
                        width: widthCol - (width - widthCol),
                        alignment: Alignment.topRight,
                        child: Table(
                          border: BoderCustom(),
                          children: [
                            TableRow(children: [
                              Container(
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                    child:
                                    Text("AD-OSP-0433 / PN-20210708-3194",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                        )),
                                  )),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
            Container(
                height: heightCol.height,
                width: width - widthCol - 20,
                child: Table(
                  border: BoderCustom(),
                  children: [
                    TableRow(children: [
                      Container(
                        child: QrImage(
                          data: "1234567890",
                          version: QrVersions.auto,
                          size: heightCol.height - 40,
                        ),
                        padding: EdgeInsets.only(
                          top: 40,
                        ),
                      ),
                    ]),
                  ],
                )),
          ],
        ),
        Row(children: <Widget>[
          Container(
            width: width - widthCol,
            child: Table(
              border: BoderCustom(),
              children: [
                TableRow(children: [
                  Container(
                    alignment: Alignment.center,
                    height: heigthItemCd.height,
                    padding: EdgeInsets.all(10),
                    child: Text("ITEMCODE",
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ),
                ]),
              ],
            ),
          ),
          MeasureSize(
            onChange: (size) {
              setState(() {
                heigthItemCd = size;
              });
            },
            child: Container(
              width: widthCol - 20,
              child: Table(
                border: BoderCustom(),
                children: [
                  TableRow(children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                          "PSTOSP0000132 /ACETAL MALE BUCKLE PLASTIC WOOJIN 3210-20mm PICCO SINGLE SR",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          )),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ]),
        Row(children: <Widget>[
          MeasureSize(
              onChange: (size) {
                setState(() {
                  heigthColor = size;
                });
              },
              child: Container(
                width: width - widthCol,
                child: Table(
                  border: BoderCustom(),
                  children: [
                    TableRow(children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text("COLOR",
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ),
                    ]),
                  ],
                ),
              )),
          Container(
            width: widthCol - 20,
            child: Table(
              border: BoderCustom(),
              children: [
                TableRow(children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    height: heigthColor.height,
                    child: Text("002/425C GREY",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        )),
                  ),
                ]),
              ],
            ),
          ),
        ]),
        Row(children: <Widget>[
          MeasureSize(
            onChange: (size) {
              setState(() {
                heigthPKG = size;
              });
            },
            child: Container(
              width: width / 4,
              child: Table(
                border: BoderCustom(),
                children: [
                  TableRow(children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text("PKG#CARTON QTY",
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          Container(
            width: width / 4,
            child: Table(
              border: BoderCustom(),
              children: [
                TableRow(children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    height: heigthPKG.height,
                    child: Text("15760",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        )),
                  ),
                ]),
              ],
            ),
          ),
          Container(
            // height: 64,
            width: width / 4,
            child: Table(
              border: BoderCustom(),
              children: [
                TableRow(children: [
                  Container(
                    height: heigthPKG.height,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text("CARGO CLS DATE",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        )),
                  ),
                ]),
              ],
            ),
          ),
          Container(
            // height: 64,
            width: width / 4 - 20,
            child: Table(
              border: BoderCustom(),
              children: [
                TableRow(children: [
                  Container(
                    height: heigthPKG.height,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text("2021-12-01",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        )),
                  ),
                ]),
              ],
            ),
          ),
        ]),
        Row(children: <Widget>[
          MeasureSize(
            onChange: (size) {
              setState(() {
                heigthCQTY = size;
              });
            },
            child: Container(
              width: width / 4,
              child: Table(
                border: BoderCustom(),
                children: [
                  TableRow(children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text("CARTON QTY",
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          Container(
            // height: 64,
            width: width / 4,
            child: Table(
              border: BoderCustom(),
              children: [
                TableRow(children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    height: heigthCQTY.height,
                    child: Text("2700",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        )),
                  ),
                ]),
              ],
            ),
          ),
          Container(
            width: width / 4,
            child: Table(
              border: BoderCustom(),
              children: [
                TableRow(children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    height: heigthCQTY.height,
                    child: Text("LOT NO.",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        )),
                  ),
                ]),
              ],
            ),
          ),
          Container(
            // height: 64,
            width: width / 4 - 20,
            child: Table(
              border: BoderCustom(),
              children: [
                TableRow(children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    height: heigthCQTY.height,
                    child: Text("",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        )),
                  )
                ]),
              ],
            ),
          ),
        ]),
        Row(children: <Widget>[
          Container(
            // height: 64,
            width: width / 4,
            child: Table(
              border: BoderCustom(),
              children: [
                TableRow(children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text("CARTON NO.",
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  )
                ]),
              ],
            ),
          ),
          Container(
            // height: 64,
            width: width / 4,
            child: Table(
              border: BoderCustom(),
              children: [
                TableRow(children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    height: heigthCQTY.height,
                    child: Text("11360353",
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  )
                ]),
              ],
            ),
          ),
          Container(
            // height: 64,
            width: width / 4 * 2 - 20,
            child: Table(
              border: BoderCustom(),
              children: [
                TableRow(children: [
                  Container(
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      height: heigthCQTY.height,
                      child: Column(
                        children: [
                          Text("Made In VietNam",
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                          Text("Woo JIN PLASTIC CO.",
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      )),
                ]),
              ],
            ),
          ),
        ])
      ],
    );
  }
}
