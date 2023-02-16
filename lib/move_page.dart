import 'package:cloud_firestore/cloud_firestore.dart';
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

class MovePage extends StatefulWidget {
  MovePage({Key key, this.index, this.move, this.remain}) : super(key: key);
  final int index;
  final List move;
  final List remain;

  @override
  _MovePageState createState() => _MovePageState();
}

class _MovePageState extends State<MovePage> {
  Firestore firestore = Firestore.instance;

  _create() async {
    final dir = await getExternalStorageDirectory();
    Directory('${dir.path}/voca').create();
  }

  _loading() async {
    final dir = await getExternalStorageDirectory();
    int len = Directory('${dir.path}/voca').listSync(recursive: true, followLinks: false).length;
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
    setState(() {
      length = len;
    });
  }

  Future<String> _add(String text, int index) async {
    String original = '';
    List list = [];
    try {
      final Directory dir = await getExternalStorageDirectory();
      String txt = Directory('${dir.path}/voca').listSync(recursive: true, followLinks: false)[index].path;
      final File file = File(txt);
      print(dir.path);
      original = await file.readAsString();
      for (int i = 0; i < jsonDecode(original).length; i++) {
        list.add(jsonDecode(original)[i]);
      }
      for (int i = 0; i < jsonDecode(text).length; i++) {
        list.add(jsonDecode(text)[i]);
      }
      await file.writeAsString(jsonEncode(list));
    } catch (e) {
      print('파일을 읽을 수 없음');
    }
  }

  _update(String text, int index) async {
    try {
      final Directory dir = await getExternalStorageDirectory();
      String txt = Directory('${dir.path}/voca').listSync(recursive: true, followLinks: false)[index].path;
      final File file = File(txt);
      await file.writeAsString(text);
    } catch (e) {
      print('파일을 읽을 수 없음');
    }
  }

  String text = '';
  Directory _dir;
  int length = 0;
  List fileList = [];

  int selectedIndex = -1;
  
  @override
  void initState() {
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
          '단어 이동',
          style: Theme.of(context).textTheme.headline6,
        ),
        actions:[
          IconButton(
            onPressed: () {
              if (selectedIndex == -1) {
                showDialog(context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Center(
                        child: Text(
                          "이동할 폴더를 선택해주세요.",
                          style: Theme.of(context).textTheme.subtitle1,
                        )
                      ),
                      actions: [
                        FlatButton(
                          child: Text("확인"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  }
                );
              }
              else {
                //Navigator.pop(context, selectedIndex);
                _add(jsonEncode(widget.move), selectedIndex);
                _update(jsonEncode(widget.remain), widget.index);
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            tooltip: '확인',
            icon: Icon(Icons.check,),
          ),
        ],
      ),
      body: Center(
        child: ListView(
          children: <Widget> [
            if (length == 0) CircularProgressIndicator(),
            for (int i = 0; i < length; i++)
              Column(
                children: [
                  FlatButton(
                    color: (i == widget.index) ? Theme.of(context).dividerColor : (selectedIndex == i) ? Colors.amber : Theme.of(context).canvasColor,
                    onPressed: () {
                      if (i != widget.index) {
                        (selectedIndex == i) ?
                        setState(() {selectedIndex = -1;})
                        : setState(() {selectedIndex = i;});
                      }
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
    );
  }
}
