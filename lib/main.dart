import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 這是一個使用MethodChannel 溝通Flutter 與Swift 的範例
/// 主要文件lib/main.dart, ios/Runner/AppDelegate.swift
/// 注意：ChannelName, MethodName, 以及Method 參數、回傳值，必須一致

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// 定義Channel Name，注意必須與AppDelegate.swift 內用的相同
  static const String _batteryChannel = "samples.flutter.dev/battery";
  static const String _toastChannel = "samples.flutter.dev/toast";
  static const String _presentChannel = "samples.flutter.dev/present";

  /// 宣告Channel 物件，並給予Channel Name
  static const MethodChannel batteryMethodChannel = MethodChannel(
    _batteryChannel,
  );
  static const MethodChannel toastMethodChannel = MethodChannel(
    _toastChannel,
  );
  static const MethodChannel presentMethodChannel = MethodChannel(
    _presentChannel,
  );

  /// 當前電量值
  String _batteryLevel = 'unknown';

  /// 取得電量值
  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      /// 使用 batteryMethodChannel 呼叫getBatteryLevel method，注意這邊的method name 必須與AppDelegate.swift 內的相同
      int result = await batteryMethodChannel.invokeMethod('getBatteryLevel');
      batteryLevel = "Bettery level at $result %. ";
    } on PlatformException catch (e) {
      batteryLevel = 'faild ${e.message}';
    }

    /// 取得後透過setState 刷新畫面
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  void _showToast(String text, int type) {
    /// 使用 toastMethodChannel 呼叫showToast method，並帶入參數，注意這邊的method name 必須與AppDelegate.swift 內的相同
    toastMethodChannel.invokeMethod('showToast', {
      "msg": text,
      "type": type,
    });
  }

  void _presentOnIOS() {
    /// 使用 toastMethodChannel 呼叫present method，注意這邊的method name 必須與AppDelegate.swift 內的相同
    presentMethodChannel.invokeMethod('present');
  }

  @override
  void initState() {
    super.initState();

    ///初始化後執行取得電量值
    _getBatteryLevel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _batteryLevel,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Row(
              children: [
                TextButton(
                    onPressed: () {
                      _presentOnIOS();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text('present swift view'),
                    )),
                TextButton(
                    onPressed: () {
                      _showToast("YA!", 0);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text('show swift toast'),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
