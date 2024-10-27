import 'package:flutter/material.dart';
import 'demo_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Request notification permissions and retrieve the FCM token
  await requestNotificationPermissions();
  await retrieveFcmToken();

  // Configure Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  DemoScreenState createState() => DemoScreenState();
}

Future<void> requestNotificationPermissions() async {
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    provisional: true, // Request provisional permission
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
}

Future<void> retrieveFcmToken() async {
  // Retrieve the FCM token
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  if (fcmToken != null) {
    print("FCM Token: $fcmToken");
    // You may want to send the token to your server
  } else {
    print("Failed to get FCM token");
  }

  // Listen to token updates
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print("FCM Token updated: $newToken");
    // Send the updated token to your server if needed
  }).onError((error) {
    print("Error retrieving token: $error");
  });

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Received a message while in the foreground!");
    print("Message data: ${message.data}");

    if (message.notification != null) {
      print("Message also contained a notification: ${message.notification}");
      // Show an alert or a dialog with the notification


    }
  });
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  // You can display notifications here or perform any other actions.
}
