import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';
import 'package:voca_app/size_config.dart';
import 'package:voca_app/write_page.dart';

class OcrPage extends StatefulWidget {
  OcrPage({Key key, this.isAdd, this.index}) : super(key: key);
  final bool isAdd;
  final int index;
  
  @override
  _OcrPageState createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _text);
  }
  bool _scanning = false;
  String _extractTextEn = '';
  String _extractTextKo = '';
  int _scanTime = 0;
  List en = [];
  List ko = [];
  bool isEdit = false;
  String _text = '';
  List list = [];
  String name = '';



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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '단어 추가 OCR',
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                child: Text(
                  '영어 단어',
                  style: Theme.of(context).textTheme.subtitle2.copyWith(color: Theme.of(context).textTheme.headline6.color),
                  ),
                onPressed: () async {
                  list = [];
                  en = [];
                  var file = await ImagePicker.pickImage(source: ImageSource.gallery);//'assets/images/hello.png';
                    //  await FilePicker.getFilePath(type: FileType.image);
                  _scanning = true;
                  setState(() {});
                  
                  var watch = Stopwatch()..start();
                  _extractTextEn = await TesseractOcr.extractText(file.path, language: 'eng');
                  //_extractTextEn = _extractTextEn.replaceAll(" ", "");
                  _scanTime = watch.elapsedMilliseconds;
                  _scanning = false;
                  for (int i = 0; i < _extractTextEn.split('\n').length; i++) {
                    en.add(_extractTextEn.split('\n')[i]);
                  }
                  setState(() {});
                },
              ),
              RaisedButton(
                child: Text(
                  '한글 뜻',
                  style: Theme.of(context).textTheme.subtitle2.copyWith(color: Theme.of(context).textTheme.headline6.color),
                ),
                onPressed: () async {
                  list = [];
                  ko = [];
                  var file = await ImagePicker.pickImage(source: ImageSource.gallery);//'assets/images/hello.png';
                    //  await FilePicker.getFilePath(type: FileType.image);
                  _scanning = true;
                  setState(() {});
                  
                  var watch = Stopwatch()..start();
                  _extractTextKo = await TesseractOcr.extractText(file.path, language: 'kor');
                  _extractTextKo = _extractTextKo.replaceAll(" ", "");
                  _scanTime = watch.elapsedMilliseconds;
                  _scanning = false;
                  for (int i = 0; i < _extractTextKo.split('\n').length; i++) {
                    ko.add(_extractTextKo.split('\n')[i]);
                  }
                  setState(() {});
                },
              ),
              // It doesn't spin, because scanning hangs thread for now
            ],
          ),
          SizedBox(
            height: 16,
          ),
          _scanning
          ? CircularProgressIndicator()
          : 
          SizedBox(
            width: MediaQuery.of(context).size.width - 60,
            height: MediaQuery.of(context).size.height / 5,
            child: (isEdit) ?
              TextField(
                //focusNode: _focus,
                autofocus: true,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                onChanged: (value){_text = value;},
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
                controller: _controller,
                maxLength: null,
              ) :
              ListView(
                children: <Widget> [
                  for (int i = 0; i < max(max(ko.length, en.length), list.length); i++)
                    Text(
                    (list.isEmpty)
                    ? ((i < en.length) ? en[i] : '') + ' : ' + ((i < ko.length) ? ko[i] : '')
                    : list[i]['en'] + ' : ' + list[i]['ko'],
                    textAlign: TextAlign.center,
                    )
                ]
              )
          ),
          SizedBox(
            height: 16,
          ),
          RaisedButton(
            child: Text(
              '편집',
              style: Theme.of(context).textTheme.subtitle2.copyWith(color: Theme.of(context).textTheme.headline6.color),
            ),
            onPressed: () {
              if (!isEdit) {
                _text = '';
                if (list.isEmpty) {
                  for (int i = 0; i < max(ko.length, en.length); i++) {
                    _text += ((i < en.length) ? en[i] : '') + '\n' + ((i < ko.length) ? ko[i] : '');
                    (i != max(ko.length, en.length) - 1) ? _text += '\n' : _text += '';
                  }
                }
                else {
                  for (int i = 0; i < list.length; i++) {
                    _text += list[i]['en'] + '\n' + list[i]['ko'];
                    (i != list.length - 1) ? _text += '\n' : _text += '';
                  }
                }
              }
              else {
                list = [];
                en = [];
                ko = [];
                for (int i = 0; i < _text.split('\n').length; i+=2) {
                  if (i != _text.split('\n').length - 1) {
                    print(Voca('','').toJson(en: _text.split('\n')[i], ko: _text.split('\n')[i+1], checked: false));
                    list.add(Voca('','').toJson(en: _text.split('\n')[i], ko: _text.split('\n')[i+1], checked: false));
                    en.add(_text.split('\n')[i]);
                    ko.add(_text.split('\n')[i+1]);
                  }
                  else {
                    print(Voca('','').toJson(en: _text.split('\n')[i], ko: '', checked: false));
                    list.add(Voca('','').toJson(en: _text.split('\n')[i], ko: '', checked: false));
                    en.add(_text.split('\n')[i]);
                    ko.add('');
                  }
                }
              }
              setState(() {
                isEdit = !isEdit;
                _controller = TextEditingController(text: _text);
              });
            },
          ),
        ],
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
                            if (_text == '') {
                              for (int i = 0; i < max(ko.length, en.length); i++) {
                                _text += ((i < en.length) ? en[i] : '') + '\n' + ((i < ko.length) ? ko[i] : '');
                                (i != max(ko.length, en.length) - 1) ? _text += '\n' : _text += '';
                              }
                            }
                            list = [];
                            for (int i = 0; i < _text.split('\n').length; i+=2) {
                              if (i != _text.split('\n').length - 1) {
                                print(Voca('','').toJson(en: _text.split('\n')[i], ko: _text.split('\n')[i+1], checked: false));
                                list.add(Voca('','').toJson(en: _text.split('\n')[i], ko: _text.split('\n')[i+1], checked: false));
                                en.add(_text.split('\n')[i]);
                                ko.add(_text.split('\n')[i+1]);
                              }
                              else {
                                print(Voca('','').toJson(en: _text.split('\n')[i], ko: '', checked: false));
                                list.add(Voca('','').toJson(en: _text.split('\n')[i], ko: '', checked: false));
                                en.add(_text.split('\n')[i]);
                                ko.add('');
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
            if (_text == '') {
              for (int i = 0; i < max(ko.length, en.length); i++) {
                _text += ((i < en.length) ? en[i] : '') + '\n' + ((i < ko.length) ? ko[i] : '');
                (i != max(ko.length, en.length) - 1) ? _text += '\n' : _text += '';
              }
            }
            list = [];
            for (int i = 0; i < _text.split('\n').length; i+=2) {
              if (i != _text.split('\n').length - 1) {
                print(Voca('','').toJson(en: _text.split('\n')[i], ko: _text.split('\n')[i+1], checked: false));
                list.add(Voca('','').toJson(en: _text.split('\n')[i], ko: _text.split('\n')[i+1], checked: false));
                en.add(_text.split('\n')[i]);
                ko.add(_text.split('\n')[i+1]);
              }
              else {
                print(Voca('','').toJson(en: _text.split('\n')[i], ko: '', checked: false));
                list.add(Voca('','').toJson(en: _text.split('\n')[i], ko: '', checked: false));
                en.add(_text.split('\n')[i]);
                ko.add('');
              }
            }
            _add(jsonEncode(list), widget.index);
            Navigator.pop(context);
          }
        },
        tooltip: '추가',
        child: Icon(Icons.check),
      ),
    );
  }
}
