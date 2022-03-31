import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

///           Guid        ////////////////////////////////////////////////
/// - Install
/// {flutter pub add flutter_local_notifications}
///
/// - Initial class by add blow line befor runApp() in main
/// {WidgetsFlutterBinding.ensureInitialized();}
/// {NotificationService().init();}
///
/// - Declare variabel in state page by
/// {NotificationService _notificationService = NotificationService();}
///
/// - Use methods showNotifications, scheduleNotifications like
/// RaisedButton(
///   child: Text('Show Notification'),
///   padding: const EdgeInsets.all(10),
///   onPressed: () async {
///     await _notificationService.showNotifications(title:"Notification Title", message:"This is the Notification Body!");
///   },
/// ),
///  ////////////////////////////////////////////////////////////////////////


class NotificationService {
  //NotificationService a singleton object
  static final NotificationService _notificationService =
  NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  static const channelId = '123';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings("@mipmap/ic_launcher");

    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: null);

    tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  AndroidNotificationDetails _androidNotificationDetails =
  AndroidNotificationDetails(
    'channelID',
    'channelname',
    playSound: true,
    priority: Priority.high,
    importance: Importance.high,
  );

  Future<void> showNotifications({int id=0, required String title, required String message}) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      message,
      NotificationDetails(android: _androidNotificationDetails),
    );
  }

  Future<void> scheduleNotifications({int id=0, required String title, required String message}) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        message,
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 7)),
        NotificationDetails(android: _androidNotificationDetails),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> cancelNotifications(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

Future selectNotification(String? payload) async {
  if (payload != null) {
    print('notification payload: $payload');
  }
  // await Navigator.push(
  //   context,
  //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
  // );
}