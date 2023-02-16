import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voca_app/button.dart';
import 'package:voca_app/ocr_page.dart';
import 'package:voca_app/voca.dart';
import 'package:voca_app/view_page.dart';
import 'package:voca_app/main.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import 'package:voca_app/write_page.dart';

class ListPage extends StatefulWidget {
  ListPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  static MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['flutter', 'firebase', 'admob'],
    testDevices: <String>[],
  );

  BannerAd bannerAd = BannerAd(
    adUnitId: BannerAd.testAdUnitId,
    size: AdSize.smartBanner,
    targetingInfo: targetingInfo,
    listener: (MobileAdEvent event) {
      print("BannerAd event is $event");
    },
  );
  Firestore firestore = Firestore.instance;

  _create() async {
    final dir = await getExternalStorageDirectory();
    Directory('${dir.path}/voca').create();
  }

  _loading() async {
    final dir = await getExternalStorageDirectory();
    int len = Directory('${dir.path}/voca').listSync(recursive: true, followLinks: false).length;
    if (len == 0) {
      _write(jsonEncode(voca[0]).toString(), 'Welcome to 보카보까');
      len++;
    }
    else {
    fileList = [];
      for (int i = 0; i < len; i++) {
        String txt = '';
        int fileLen = Directory('${dir.path}/voca').listSync(recursive: true, followLinks: false)[i].path.split('/').last.split('.txt').length;
        if (fileLen <= 2) {
          txt = Directory('${dir.path}/voca').listSync(recursive: true, followLinks: false)[i].path.split('/').last.split('.txt').first;
        }
        else {
          String txt = '';
          for (int j = 0; j < fileLen - 2;) {
            txt += Directory('${dir.path}/voca').listSync(recursive: true, followLinks: false)[i].path.split('/').last.split('.txt')[j];
            (i != fileLen - 3) ? txt += '.txt' : txt += '';
          }
        }
        fileList.add(txt);
      }
    }
    setState(() {
      length = len;
    });
  }

  _write(String text, String name) async {
    final dir = await getExternalStorageDirectory();
    int count = Directory('${dir.path}/voca').listSync(recursive: true, followLinks: false).length;
    final File file = File('${dir.path}/voca/$name.txt');
    await file.writeAsString(text);
  }

  String text = '';
  Directory _dir;
  int length = 0;
  List fileList = [];

  @override
  void initState() {
    //FirebaseAdMob.instance.initialize(appId: 'ca-app-pub-9593720101394198~1744944200');
    bannerAd..load()..show();
    super.initState();

    _create();
    getExternalStorageDirectory().then((directory) {
      _dir = Directory('${directory.path}/voca');
    });

    _loading();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title + text,
          style: Theme.of(context).textTheme.headline6,
        ),
        actions: [
          Button(),
          IconButton(
            onPressed: () => _loading(),
            tooltip: '새로고침',
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(height: 50,),
      //  static String routeName = "/sign_in";
      body: Center(
        child: ListView(
          children: <Widget> [
            if (length == 0) CircularProgressIndicator(),
            for (int i = 0; i < length; i++)
              Column(
                children: [
                  FlatButton(
                    onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ViewPage(index: i, name: fileList[i]))),
                    onLongPress: () {
                      showDialog(context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Center(
                              child: Text(
                                "정말 삭제하시겠습니까?",
                                style: Theme.of(context).textTheme.subtitle1,
                              )
                            ),
                            actions: [
                              FlatButton(
                                child: Text("확인"),
                                onPressed: () async {
                                  final dir = await getExternalStorageDirectory();
                                  String txt = Directory('${dir.path}/voca').listSync(recursive: true, followLinks: false)[i].path;
                                  final File file = File(txt);
                                  await file.delete();
                                  _loading();
                                  Navigator.pop(context);
                                },
                              ),
                              FlatButton(
                                child: Text("취소"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          );
                        }
                      );

                    },
                    child: SizedBox(
                      height: 60,
                      child: Center(
                        child: Text(
                          fileList[i],
                          style: Theme.of(context).textTheme.headline6.copyWith(color: Theme.of(context).textTheme.bodyText2.color),
                        ),
                      ),
                    ),
                  ),
                  Divider(),
                ],
              ),
          ]
        )
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () //=> Navigator.push(context, MaterialPageRoute(builder: (context) => OcrPage())),
        //Navigator.push(context, MaterialPageRoute(builder: (context) => WritePage())),
        async {
          showDialog(context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Row(
                  children: [
                    RaisedButton(
                      child: Text(
                        "직접 입력",
                        style: Theme.of(context).textTheme.subtitle2.copyWith(color: Theme.of(context).textTheme.headline6.color),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => WritePage(isAdd: false))).then((value) {setState(() {_loading();});});
                      },
                    ),
                    Spacer(),
                    RaisedButton(
                      child: Text(
                        "사진 인식",
                        style: Theme.of(context).textTheme.subtitle2.copyWith(color: Theme.of(context).textTheme.headline6.color),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => OcrPage(isAdd: false))).then((value) {setState(() {_loading();});});
                      },
                    ),
                  ],
                )
              );
            }
          );
        },
        tooltip: '추가',
        child: Icon(Icons.add),
      ),
    );
  }
}


/*

          final dir = await getExternalStorageDirectory();
          int fileLen = Directory('${dir.path}/voca').listSync(recursive: true, followLinks: false)[1].path.split('/').last.split('.txt').length;
          if (fileLen <= 2) {
            print(Directory('${dir.path}/voca').listSync(recursive: true, followLinks: false)[1].path.split('/').last.split('.txt').first);
          }
          else {
            String txt = '';
            for (int i = 0; i < fileLen - 2;) {
              txt += Directory('${dir.path}/voca').listSync(recursive: true, followLinks: false)[1].path.split('/').last.split('.txt')[i];
              (i != fileLen - 3) ? txt += '.txt' : txt += '';
            }
            print(txt);
          }
           */