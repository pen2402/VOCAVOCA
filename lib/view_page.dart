import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voca_app/move_page.dart';
import 'package:voca_app/ocr_page.dart';
import 'package:voca_app/size_config.dart';
import 'package:voca_app/voca.dart';
import 'dart:convert';

import 'package:voca_app/write_page.dart';


class Voca {
  String en;
  String ko;

  Voca(this.en, this.ko);

  Voca.fromJson(Map<String, String> json) {
    en = json['en'];
    ko = json['ko'];
  }

  Map toJson({en, ko}) => {
    'en': en,
    'ko': ko,
  };
}

class ViewPage extends StatefulWidget {
  ViewPage({Key key, this.index, this.name}) : super(key: key);
  
  static String routeName = "/view_page";

  final int index;
  final String name;

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  bool _meaning = false;
  bool _fixedMeaning = false;
  int _counter = 0;
  List vocaList = [];
  List vocaListChecked = [];
  double _sideBarPos = 0;
  bool _edit = false;
  List checkList = [];

  Future<String> _read(int index) async {
    String text = '';
    List list = [];

    try {
      final Directory dir = await getExternalStorageDirectory();
      final File file = File(Directory('${dir.path}/voca').listSync(recursive: true, followLinks: false)[index].path);
      print(dir.path);
      text = await file.readAsString();
    } catch (e) {
      print('파일을 읽을 수 없음');
    }

    for (int i = 0; i < jsonDecode(text).length; i++) {
      if (!jsonDecode(text)[i]['checked']) {
        list.add(jsonDecode(text)[i]);
      }
    }
    
    //print(jsonDecode(text)[0]);
    setState(() {
      vocaList = jsonDecode(text);
      vocaListChecked = list;
    });
  }

  _update(String text, int index) async {
    String original = '';
    List list = [];

    try {
      final Directory dir = await getExternalStorageDirectory();
      final File file = File(Directory('${dir.path}/voca').listSync(recursive: true, followLinks: false)[index].path);
      print(dir.path);
      original = await file.readAsString();
    } catch (e) {
      print('파일을 읽을 수 없음');
    }
    if (text != original) {
      try {
        final dir = await getExternalStorageDirectory();
        final File file = File(Directory('${dir.path}/voca').listSync(recursive: true, followLinks: false)[index].path);
        await file.writeAsString(text);

        for (int i = 0; i < jsonDecode(text).length; i++) {
          if (!jsonDecode(text)[i]['checked']) {
            list.add(jsonDecode(text)[i]);
          }
        }
      
        setState(() {
          vocaList = jsonDecode(text);
          vocaListChecked = list;
          _counter = 0;
        });
      } catch (e) {}
    }
  }

  void _appearMeaning() {
    setState(() {
      _meaning = !_meaning;
      _fixedMeaning = (_meaning) ? _fixedMeaning : false;
    });
  }

  void _fixAppearMeaning() {
    setState(() {
      _fixedMeaning = !_fixedMeaning;
      _meaning = _fixedMeaning;
    });
  }

  void _previousVoca() {
    setState(() {
      if (_counter > 0) {
        _meaning = (_fixedMeaning) ? true : false;
        _counter--;
      }
    });
  }

  void _nextVoca() {
    setState(() {
      if (_counter < vocaListChecked.length - 1) {
        _meaning = (_fixedMeaning) ? true : false;
        _counter++;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _sideBarPos = - 1000;
    _read(widget.index);
/*
    vocaListChecked = [];
    for (int i; i < vocaList.length; i++) {
      if (!vocaList[i]['checked']) {
        vocaListChecked.add(vocaList[i]);
      }
    }
*/
  }

  @override
  Widget build(BuildContext context) {
    vocaList ?? CircularProgressIndicator(); 
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              tooltip: '뒤로 가기',
              icon: Icon(Icons.west,),
            ),
            title: Text(
              '${widget.name}',
              style: Theme.of(context).textTheme.headline6,
            ),
            actions: [
              if (_edit)
                IconButton(
                  onPressed: () {
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
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => WritePage(isAdd: true, index: widget.index)));
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
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => OcrPage(isAdd: true, index: widget.index)));
                                },
                              ),
                            ],
                          )
                        );
                      }
                    );
                  },
                  tooltip: '추가',
                  icon: Icon(Icons.add,),
                ),
              if (_edit)
                IconButton(
                  onPressed: () {
                    List move = [];
                    List remain = [];
                    for (int i = 0; i < vocaList.length; i++) {
                      if (checkList[i]) {
                        move.add(vocaList[i]);
                      }
                      else {
                        remain.add(vocaList[i]);
                      }
                    }
                    (move.isEmpty) ?
                      showDialog(context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Center(
                              child: Text(
                                "이동할 단어를 선택해주세요.",
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
                      ) :
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MovePage(move: move, remain: remain, index: widget.index)));
                  },
                  tooltip: '이동',
                  icon: Icon(Icons.swap_horiz,),
                ),
              if (_edit)
                IconButton(
                  onPressed: () {
                    List remove = [];
                    List remain = [];
                    for (int i = 0; i < vocaList.length; i++) {
                      if (checkList[i]) {
                        remove.add(vocaList[i]);
                      }
                      else {
                        remain.add(vocaList[i]);
                      }
                    }
                    (remove.isEmpty) ?
                      showDialog(context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Center(
                              child: Text(
                                "삭제할 단어를 선택해주세요.",
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
                      ) : showDialog(context: context,
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
                                onPressed: () {
                                  _update(jsonEncode(remain), widget.index);
                                  checkList = [];
                                  for (int i = 0; i < vocaList.length; i++) {
                                    checkList.add(false);
                                  }
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
                  tooltip: '삭제',
                  icon: Icon(Icons.delete,),
                ),
              if (_sideBarPos != 0)
              IconButton(
                onPressed: () {
                  vocaListChecked.shuffle();
                  setState(() {
                    _counter = 0;
                  });
                },
                tooltip: '순서 섞기',
                icon: Icon(Icons.shuffle,),
              ),
              if (_sideBarPos == 0)
              IconButton(
                onPressed: () {
                    checkList = [];
                  for (int i = 0; i < vocaList.length; i++) {
                    checkList.add(false);
                  }
                  setState((){_edit = !_edit;});
                },
                tooltip: (_edit) ? '확인' : '편집',
                icon: (_edit) ? Icon(Icons.check) : Icon(Icons.edit),
              ),
              if (!_edit)
              IconButton(
                onPressed: () => setState((){
                  _edit = false;
                  _update(jsonEncode(vocaList), widget.index);
                  _read(widget.index);
                  _sideBarPos = (_sideBarPos == 0) ? - ((MediaQuery.of(context).size.width / 5) * 4) : 0;
                }),
                tooltip: '목록',
                icon: Icon((_sideBarPos == 0) ? Icons.menu_open : Icons.menu,),
              ),
            ],
          ),
          bottomNavigationBar: SizedBox(height: 50,),
          body: Stack(
            children: [
              (vocaListChecked.isEmpty) ?
              Center(
                child: Text(
                  '암기할 단어가 없습니다.',
                  style: Theme.of(context).textTheme.headline6.copyWith(color: Theme.of(context).textTheme.bodyText2.color),
                )
              ) :
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget> [
                    Text(
                      vocaListChecked[_counter]['en'],//voca[widget.day][_counter]['en'],
                      style: Theme.of(context).textTheme.headline6.copyWith(color: Theme.of(context).textTheme.bodyText2.color),
                    ),
                    Text(
                      (_meaning == true) ? vocaListChecked[_counter]['ko'] : '',//'$_counter', //voca[widget.day][_counter]['ko']
                      style: Theme.of(context).textTheme.headline6.copyWith(color: Theme.of(context).textTheme.bodyText2.color),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        (vocaListChecked.length > 0) ? '[${_counter + 1}/${vocaListChecked.length}]' : '',//'$_counter',
                      ),
                      SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FloatingActionButton(
                            heroTag: null,
                            onPressed: _previousVoca,
                            tooltip: '이전',
                            child: Icon(Icons.arrow_back),
                          ),
                          SizedBox(width: 30,),
                          FloatingActionButton(
                            heroTag: null,
                            onPressed: _appearMeaning,
                            tooltip: '뜻 표시(더블 탭 : 전체)',
                            child: GestureDetector(
                              onDoubleTap: _fixAppearMeaning,
                              child: Icon(Icons.search),
                            ),
                          ),
                          SizedBox(width: 30,),
                          FloatingActionButton(
                            heroTag: null,
                            onPressed: _nextVoca,
                            tooltip: '다음',
                            child: Icon(Icons.arrow_forward),
                          ),
                        ]
                      ),
                    ]
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 500),
                top: 0,
                bottom: 0,
                right: _sideBarPos,
                curve: Curves.ease,
                child: Material(
                  elevation: 3,
                  child: Container(
                    width: (MediaQuery.of(context).size.width / 5) * 4,
                    child: (vocaList.isEmpty) ?
                      Center(
                          child: Text(
                            '비어있음',
                            style: Theme.of(context).textTheme.headline6.copyWith(color: Theme.of(context).textTheme.bodyText2.color),
                          ),
                      ) :
                      ListView(
                        children: <Widget>[
                          for (int i = 0; i < vocaList.length; i++)
                          Column(
                            children: [
                              Row(
                                children: [
                                  if (_edit)
                                    SizedBox(width: 10,),
                                  if (!_edit)
                                    Checkbox(
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      checkColor: Theme.of(context).textTheme.headline6.color,
                                      value: vocaList[i]['checked'] ?? false,
                                      onChanged: (value) {
                                        setState(() {
                                          vocaList[i]['checked'] = value;
                                        });
                                      },
                                    ),
                                  SizedBox(
                                    width: (MediaQuery.of(context).size.width / 5) * 4 - 60,
                                    child: Text(
                                      '${vocaList[i]['en']}',
                                      style: Theme.of(context).textTheme.headline6.copyWith(color: Theme.of(context).textTheme.bodyText2.color),
                                    ),
                                  ),
                                  Spacer(),
                                  if (_edit)
                                    Checkbox(
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      checkColor: Theme.of(context).textTheme.headline6.color,
                                      value: checkList[i] ?? false,
                                      onChanged: (value) {
                                        setState(() {
                                          checkList[i] = value;
                                        });
                                      },
                                    ),
                                    SizedBox(width: 6,),
                                ],
                              ),
                              Divider(),
                            ],
                          ),
                        ]
                      ),
                  ),
                ),
              )
            ],
          ),
        ),
      ]
    );
  }
}

/*

  bool checked;
  SharedPreferences remember;
  
  void loadCheck() async {
    remember = await SharedPreferences.getInstance();
    setState(() {
      checked = remember?.getBool('isChecked') ?? false;
    });
  }

  void saveCheck() async {
    remember = await SharedPreferences.getInstance();
    setState(() {
      remember?.setBool('isChecked', checked);
    });
  }


  }

  setRememberInfo() async {
    logger.d(doRemember);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("doRemember", doRemember);
    if (doRemember) {
      prefs.setString("userEmail", _mailCon.text);
      prefs.setString("userPasswd", _



class SideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    List<bool> checked = [];
    for (int i = 0; i < vocaList.length; i++) {
      checked.add(false);
    }
    //.replaceAll(false);

    return Positioned(
      top: 0,
      bottom: 0,
      right: 0,
      child: Container(
        color: Colors.blue,
        width: (screenWidth / 5) * 2,
        child: ListView(
          children: <Widget>[
            if (vocaList.length == 0) CircularProgressIndicator(),
            for (int i = 0; i < vocaList.length; i++)
              Row(
                children: [
                  SizedBox(child: Checkbox(
                    //activeColor: mPrimaryColor2,
                    value: false,//remember?.getBool('isChecked') ?? false,
                    onChanged: (value) {
                      setState(() {
                        checked[i] = value;//!remember.getBool('isChecked') ?? false;//remember.setBool('isChecked', value);
                        //saveCheck();
                      });
                    },
                  ),),
                  Text(
                    'Day ${i + 1}',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              )
          ]
        ),
      )
    );
  }
}

*/