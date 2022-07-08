import 'dart:async';
import 'package:cache_manager/cache_manager.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:olr_rooms_web/api/APIService.dart';
import 'package:olr_rooms_web/firebase_options.dart';
import 'package:olr_rooms_web/model/Response.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeData.dart';
import 'Login.dart';
import 'LoginData.dart';
import 'colors/MyColors.dart';
import 'package:olr_rooms_web/route/route_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home/Home.dart';
import 'url_strategy_nativeConfig.dart'
if(dart.library.html) 'url_strategy_webConfig.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message ${message.messageId}');
}
// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     "high_importance_channel", "High Importance notification",
//     importance: Importance.high);

//Remove this
// "This channel is used for important notification.",

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();

Future<void> main() async {

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();
  // setUrlStrategy(PathUrlStrategy());
  urlConfig();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //     AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(const MyApp());
  // print("GET TOKEN ABOVE");
  // FirebaseMessaging.instance.getToken().then((value) => print(value));
  // print("GET TOKEN BELOW");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: LoginData(),
        ),
        ChangeNotifierProvider.value(
          value: HomeData(),
        ),
      ],
      child: MaterialApp(
        title: 'Splash Screen',
        onGenerateRoute: RouteServices.generateRoute,
        scrollBehavior: MaterialScrollBehavior().copyWith(
            dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus,
              PointerDeviceKind.unknown, PointerDeviceKind.invertedStylus, PointerDeviceKind.trackpad},
          ),
        theme: ThemeData(
          primarySwatch: MyColors.generateMaterialColor(MyColors.colorPrimary),
            dividerColor: Colors.transparent
        ),
        supportedLocales: [
          const Locale('en'),
          const Locale('el'),
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'), // Generic Simplified Chinese 'zh_Hans'
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'), // Generic traditional Chinese 'zh_Hant'
        ],
        localizationsDelegates: [
          CountryLocalizations.delegate,
        ],
        home: MyHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  SharedPreferences? sharedPreferences;
  late final AnimationController controller;
  // late VideoPlayerController _controller;

  String fcmId = "";

  String? _linkMessage;
  bool _isCreatingLink = false;

  // FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;


  Future<void> taketo() async {
    List<String> keys = await ReadCache.getStringList(key: "keys") ?? [];
    for(int i = 0; i<keys.length; i++) {
      DeleteCache.deleteKey(keys[i]);
    }
    await WriteCache.setListString(key: "keys", value: []);
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences != null) {
      sharedPreferences!.setBool("pop", false);
      if (sharedPreferences!.getString("status") == "logged in") {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => Home()),
            (Route<dynamic> route) => false);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => const Login()),
            (Route<dynamic> route) => false);
      }
    }
  }


  @override
  void initState() {
    super.initState();
    getFirebaseMessagingSetUp();
    // _controller = VideoPlayerController.asset('assets/splash.mov')
    //   ..initialize().then((_) {
    //     _controller.play();
    //     // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
    //     setState(() {});
    //   });
    //
    // Future.delayed(Duration(seconds: 3), () {
    //   taketo();
    // });
    taketo();

    // controller = AnimationController(vsync: this);
    //
    // controller.addStatusListener((status) {
    //   if(status==AnimationStatus.completed)
    //     {
    //       taketo();
    //     }
    // });

    // var initializationSettingsAndroid =
    // AndroidInitializationSettings("app_icon");
    // var initializationSettings =
    // InitializationSettings(android: initializationSettingsAndroid);
    //
    // flutterLocalNotificationsPlugin.initialize(initializationSettings);
    //
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   RemoteNotification? notification = message.notification;
    //   AndroidNotification? android = message.notification?.android;
    //   if (notification != null && android != null) {
    //     flutterLocalNotificationsPlugin.show(
    //         notification.hashCode,
    //         notification.title,
    //         notification.body,
    //         NotificationDetails(
    //             android: AndroidNotificationDetails(channel.id, channel.name,
    //                 //,Remove this channel.description,
    //                 icon: "app_icon")));
    //   }
    // });
    // _createDynamicLink(true, kBookingpageLink);
    // initDynamicLinks();
    //initDeepLinks();

  }

  getFirebaseMessagingSetUp() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print("Testing"+message.data.toString());
      }
      else
        {
          print(message?.data);
          print(message.isNullOrBlank);
        }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print(
            'Message also contained a notification: ${message.notification?.body}');
        showDialog(
            context: context,
            builder: ((BuildContext context) {
              return DynamicDialog(
                  title: message.notification?.title,
                  body: message.notification?.body);
            }));
      }
      else
        {
          print("Service else");
        }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');

    });
    getToken();
    FirebaseMessaging.instance.onTokenRefresh
        .listen((fcmToken) {
      print("New Token");
      // TODO: If necessary send token to application server.

      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
    })
        .onError((err) {
      // Error getting token.
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => ResponsiveWrapper.builder(
          BouncingScrollWrapper.builder(context, child!),
          maxWidth: 1200,
          minWidth: 450,
          defaultScale: true,
          breakpoints: [
            const ResponsiveBreakpoint.resize(450, name: MOBILE),
            const ResponsiveBreakpoint.autoScale(800, name: TABLET),
            const ResponsiveBreakpoint.autoScale(1000, name: TABLET),
            const ResponsiveBreakpoint.resize(1200, name: DESKTOP),
            const ResponsiveBreakpoint.autoScale(2460, name: "4K"),
          ],
          background: Container(color: MyColors.white)),
      home: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: MyColors.white,
          child: Center(
            child: CircularProgressIndicator(
              color: MyColors.colorPrimary,
            ),
          ),
          // color: MyColors.colorPrimary,
          // child: Center(
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: <Widget>[
          //       Expanded(
          //         child: Lottie.asset(
          //             'assets/splash/splash.json',
          //             controller: controller,
          //             frameRate: FrameRate.max,
          //             onLoaded: (composition) {
          //               // Configure the AnimationController with the duration of the
          //               // Lottie file and start the animation.
          //               print("hello");
          //               controller
          //                 ..duration = composition.duration
          //                 ..forward();
          //             },
          //       ),
          //       ),
          //     ],
          //   ),
          // ),
        ),
        // body: Container(
        //   alignment: Alignment.center,
        //   color: MyColors.colorPrimary,
        //   child: Lottie.asset(
        //         'assets/splash/splash.json',
        //         controller: controller,
        //       frameRate: FrameRate.max,
        //         onLoaded: (composition) {
        //           // Configure the AnimationController with the duration of the
        //           // Lottie file and start the animation.
        //           print("hello");
        //           controller
        //             ..duration = composition.duration
        //             ..forward();
        //         },
        //   ),
        // ),
        // body: Container(
        //   alignment: Alignment.center,
        //   color: MyColors.colorPrimary,
        //   padding: EdgeInsets.all(10),
        //   child: Center(
        //       // child: _controller.value.isInitialized
        //       //     ? AspectRatio(
        //       //   aspectRatio: 4 / 6,
        //       //   child: VideoPlayer(_controller),
        //       // )
        //       //     : Container()
        //     child: Image.asset("assets/splash.gif"),
        //   ),
        // ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // controller.dispose();
    super.dispose();
  }

  getToken() async {
    String? token = await FirebaseMessaging.instance.getToken(vapidKey: "BEiqQwC8GEmH_sqlx6S5vaAaZwikxHlP1yPsMaETKUdV6PhMXkjU8ACPWra8ctvGIsH4qMhzpxi-OAQVmGATzuk");
    print("token");
    print(token);
    print("token");
    insertUserFCM(token!);
  }

  Future<void> insertUserFCM(String token) async {
    Map<String, dynamic> data = new Map();
    data['fcm'] = token;

    print(data);

    Response response = await APIService().insertUserFCM(data);

    print("response.message");
    print(response.message);
  }

  // Future<void> initDynamicLinks() async {
  //   dynamicLinks.onLink.listen((dynamicLinkData) {
  //     final Uri uri = dynamicLinkData.link;
  //     print("uri.toString()");
  //     print(uri.toString());
  //     final queryParams = uri.queryParameters;
  //     print(uri.queryParameters);
  //     if (queryParams.isNotEmpty) {
  //       String? id = queryParams["id"];
  //       taketo();
  //       Navigator.pushNamed(context, dynamicLinkData.link.path,
  //         arguments: {"id": id??""}).then((value) {
  //           print("takleto1");
  //           taketo();
  //       });
  //     } else {
  //       print("Else Dynamic Link");
  //       taketo();
  //       Navigator.pushNamed(
  //         context,
  //         dynamicLinkData.link.path,
  //       ).then((value) {
  //         print("takleto1");
  //         taketo();
  //       });
  //     }
  //   }).onError((error) {
  //     print('onLink error');
  //     print(error.message);
  //   });
  // }

}

class DynamicDialog extends StatefulWidget {
  final title;
  final body;
  DynamicDialog({this.title, this.body});
  @override
  _DynamicDialogState createState() => _DynamicDialogState();
}

class _DynamicDialogState extends State<DynamicDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      actions: <Widget>[
        OutlinedButton.icon(
            label: Text('Close'),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close))
      ],
      content: Text(widget.body),
    );
  }
}
