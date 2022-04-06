import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pusher_channels/pusher_channels.dart';
import 'helper.dart';

import 'notification_service.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  NotificationService _notificationService = NotificationService();
  await _notificationService.showNotifications(title:'', message:'background message ${message.notification!.body}');

  print('background message ${message.notification!.body}');
}

main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_messageHandler);

  //Helper helper = new Helper();
  // Future<Map> _userData;
  // Future<Map> get userData => _userData ??= helper.getUserDetailsFromSharedPreference();


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Relationship pusher notify',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      debugShowCheckedModeBanner: false,
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
  late FirebaseMessaging _messaging;

  void initState() {

    super.initState();

    NotificationService().init();
    NotificationService _notificationService = NotificationService();

    /// Firebase
    registerNotification(_notificationService);


    //////////////////////////



    bindPusherNotification(_notificationService);
  }

  ///////////////////////////////
  void registerNotification(NotificationService _notificationService) async {

    // 2. Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;

    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Helper.log('User granted permission');
      // TODO: handle the received notifications
    } else {
      Helper.log('User declined or has not accepted permission');
    }

    _messaging.getToken().then((value){
      print(value);
    });

    // Handling Message In Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Helper.log("message recieved");
      print(message.notification!.body);
      _notificationService.showNotifications(title:'', message:'background message ${message.notification!.body}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Helper.log('Message clicked!');
    });
  }
  ////////////////////////////////////
  Future<void> bindPusherNotification(NotificationService _notificationService) async {
    final pusher = Pusher(key: 'ecd279b8357d739168ee');
    await pusher.connect();
    final channel = pusher.subscribe('my-channel');
    
    
    channel.bind('my-event', (event) async {

      Helper.log('event: ${event.runtimeType} $event');

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
