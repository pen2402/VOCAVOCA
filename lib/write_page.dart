import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class Voca {
  String en;
  String ko;
  bool checked;

  Voca(this.en, this.ko);

  Voca.fromJson(Map<String, String> json) {
    en = json['en'];
    ko = json['ko'];
  }

  Map toJson({en, ko, checked}) => {
    'en': en,
    'ko': ko,
    'checked' : checked,
  };
}

class WritePage extends StatefulWidget {
  WritePage({Key key, this.title, this.isAdd, this.index}) : super(key: key);
  final String title;
  final bool isAdd;
  final int index;

  @override
  _WritePageState createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  Firestore firestore = Firestore.instance;

  _create() async {
    final dir = await getExternalStorageDirectory();
    Directory('${dir.path}/voca').create();
  }

  _loading() async {
    final dir = await getExternalStorageDirectory();
    int len = Directory('${dir.path}/voca').listSync(recursive: true, followLinks: false).length;
    setState(() {
      length = len;
    });
  }

  _write(String text, String name) async {
    final dir = await getExternalStorageDirectory();
    final File file = File('${dir.path}/voca/$name.txt');
    await file.writeAsString(text);
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

  String text = '';
  Directory _dir;
  int length = 0;
  String name = '';

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
    if (length == 0) return CircularProgressIndicator(); 
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: '뒤로 가기',
          icon: Icon(Icons.west),
        ),
        title: Text(
          '단어 추가',
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: Center(
        child: TextField(
          //focusNode: _focus,
          autofocus: true,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          onChanged: (value){text = value;},
          cursorHeight: 20,
          cursorRadius: Radius.circular(1),
          //maxLength: 20,
          decoration: InputDecoration(
            isCollapsed: true,
            counterText: '',
            border: InputBorder.none,
            hintText:"단어를 입력해주세요.",
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
        )
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () async {
          if (!widget.isAdd) {
            showDialog(context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Center(
                    child: Column(
                      children: [
                        Text(
                          '단어장 이름',
                          style: Theme.of(context).textTheme.headline6.copyWith(color: Theme.of(context).textTheme.bodyText2.color),
                        ),
                        SizedBox(height: 10,),
                        TextField(
                          //focusNode: _focus,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          onChanged: (value){name = value;},
                          cursorHeight: 20,
                          cursorRadius: Radius.circular(1),
                          //maxLength: 20,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            counterText: '',
                            border: InputBorder.none,
                            hintText:"단어장 이름을 입력해주세요.",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                        )
                      ]
                    )
                  ),
                  actions: [
                    FlatButton(
                      child: Text("확인"),
                      onPressed: () async {
                        final dir = await getExternalStorageDirectory();
                        final File file = File('${dir.path}/voca/$name.txt');
                        await file.exists().then((bool isExists) {
                          if (isExists) {
                            showDialog(context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Center(
                                    child: Text(
                                      "이미 존재하는 이름입니다.",
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
                            List list = [];
                            for (int i = 0; i < text.split('\n').length; i+=2) {
                              if (i != text.split('\n').length - 1) {
                                print(Voca('','').toJson(en: text.split('\n')[i], ko: text.split('\n')[i+1], checked: false));
                                list.add(Voca('','').toJson(en: text.split('\n')[i], ko: text.split('\n')[i+1], checked: false));
                              }
                              else {
                                print(Voca('','').toJson(en: text.split('\n')[i], ko: '', checked: false));
                                list.add(Voca('','').toJson(en: text.split('\n')[i], ko: '', checked: false));
                              }
                            }
                            _write(jsonEncode(list), name);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                        });
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
          }
          else {
            List list = [];
            for (int i = 0; i < text.split('\n').length; i+=2) {
              if (i != text.split('\n').length - 1) {
                print(Voca('','').toJson(en: text.split('\n')[i], ko: text.split('\n')[i+1], checked: false));
                list.add(Voca('','').toJson(en: text.split('\n')[i], ko: text.split('\n')[i+1], checked: false));
              }
              else {
                print(Voca('','').toJson(en: text.split('\n')[i], ko: '', checked: false));
                list.add(Voca('','').toJson(en: text.split('\n')[i], ko: '', checked: false));
              }
            }
            _add(jsonEncode(list), widget.index);
            Navigator.pop(context);
            Navigator.pop(context);
          }
        },
        tooltip: '추가',
        child: Icon(Icons.check),
      ),
    );
  }
}

