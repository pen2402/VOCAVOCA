import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voca_app/button.dart';
import 'package:voca_app/list_page.dart';
import 'package:firebase_admob/firebase_admob.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  await FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
  //FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
  runApp(MyApp());
}

ThemeData _darkTheme = ThemeData(
  primaryIconTheme: IconThemeData(color: Colors.black),
  iconTheme: IconThemeData(color: Colors.black),
  floatingActionButtonTheme: FloatingActionButtonThemeData(foregroundColor: Colors.black, backgroundColor: Colors.amber),
  accentColor: Colors.amber,
  textTheme: TextTheme(subtitle1: TextStyle(color: Colors.white), subtitle2: TextStyle(color: Colors.amber), headline6: TextStyle(color: Colors.black), bodyText2: TextStyle(color: Colors.white)),
  primaryColor: Colors.amber,
  canvasColor: Colors.grey.shade900,
  primarySwatch: Colors.amber,
  dividerColor: Colors.grey.shade700,
  unselectedWidgetColor: Colors.amber,
  hintColor: Colors.grey.shade500,
  cursorColor: Colors.amber,
  dialogBackgroundColor: Colors.grey.shade900,
  buttonColor: Colors.amber,


  //textTheme: TextTheme(button: TextStyle(color: Colors.red)),


  // next line is important!
  //appBarTheme: AppBarTheme(brightness: Brightness.light),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

ThemeData _lightTheme = ThemeData(
  primaryIconTheme: IconThemeData(color: Colors.white),
  iconTheme: IconThemeData(color: Colors.white),
  floatingActionButtonTheme: FloatingActionButtonThemeData(foregroundColor: Colors.white, backgroundColor: Colors.amber),
  accentColor: Colors.amber,
  textTheme: TextTheme(subtitle1: TextStyle(color: Colors.black), headline6: TextStyle(color: Colors.white), bodyText2: TextStyle(color: Colors.black)),
  primaryColor: Colors.amber,
  canvasColor: Colors.white,
  primarySwatch: Colors.amber,

  unselectedWidgetColor: Colors.amber,

  cursorColor: Colors.amber,
  buttonColor: Colors.amber,
  

  // next line is important!
  //appBarTheme: AppBarTheme(color: Colors.amber),//brightness: Brightness.dark),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

/*
ThemeData _darkTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  primarySwatch: Colors.amber,
  colorScheme: ColorScheme.dark(),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

ThemeData _lightTheme = ThemeData(
  scaffoldBackgroundColor: Colors.black,
  colorScheme: ColorScheme.light(),
  primarySwatch: Colors.amber,
  visualDensity: VisualDensity.adaptivePlatformDensity,
);
 */


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    builder: (context, _) {
      final themeProvider = Provider.of<ThemeProvider>(context);

      return MaterialApp(
        title: '보카보까',
        themeMode: themeProvider.themeMode,//ThemeMode.system,
        theme: _lightTheme,
        darkTheme: _darkTheme,
        debugShowCheckedModeBanner: false,
        home: ListPage(title: '단어장 목록'),
      );
    },
  );
}
//_notifier.value = mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,

/*
{
        return MaterialApp(
          title: '단어장',
          themeMode: mode,
          theme: _lightTheme,
          darkTheme: _darkTheme,
          debugShowCheckedModeBanner: false,
          home: ListPage(title: '단어장 목록'),
          
        );
      }
       */