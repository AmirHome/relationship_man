import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pusher_channels/pusher_channels.dart';

import 'notification_service.dart';

main() async{
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

void log(String string){
  print("Log: $string");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Relationship pusher notify',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Relationship pusher notify'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void initState() {
    super.initState();
    
    NotificationService().init();
    NotificationService _notificationService = NotificationService();

    bindPusherNotification(_notificationService);
  }

  Future<void> bindPusherNotification(NotificationService _notificationService) async {
    final pusher = Pusher(key: 'ecd279b8357d739168ee');
    await pusher.connect();
    final channel = pusher.subscribe('my-channel');
    
    
    channel.bind('my-event', (event) async {

      log('event: ${event.runtimeType} $event');

      Map<String, dynamic> jsonData = Map<String, dynamic>.from(event);
      await _notificationService.showNotifications(title:"Notification Title", message: jsonData['message'].toString());
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
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
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
