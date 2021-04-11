import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_editor_pro/modules/all_emojies.dart';
import 'package:image_editor_pro/modules/bottombar_container.dart';
import 'package:image_editor_pro/modules/colors_picker.dart';
import 'package:image_editor_pro/modules/emoji.dart';
import 'package:image_editor_pro/modules/text.dart';
import 'package:image_editor_pro/modules/textview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:signature/signature.dart';

TextEditingController heightcontroler = TextEditingController();
TextEditingController widthcontroler = TextEditingController();

List fontsize = [];
var howmuchwidgetis = 0;
List multiwidget = [];
Color currentcolors = Colors.white;
var opicity = 0.0;

class ImageEditorPro extends StatefulWidget {
  final Color appBarColor;
  final Color bottomBarColor;

  ImageEditorPro({this.appBarColor, this.bottomBarColor});

  @override
  _ImageEditorProState createState() => _ImageEditorProState();
}

var slider = 0.0;

class _ImageEditorProState extends State<ImageEditorPro> {
  // create some values
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);
  GestureWhiteboardController _controller = GestureWhiteboardController()
    ..brushSize = (5)
    ..eraserSize = (25)
    ..brushColor = Color(0XFFFF6666);

  PersistentBottomSheetController _scfFutController;

// ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
    _controller?.brushColor = color;
  }

  List<Offset> offsets = [];
  Offset offset1 = Offset.zero;
  Offset offset2 = Offset.zero;
  final scaf = GlobalKey<ScaffoldState>();
  var openbottomsheet = false;
  List type = [];
  List aligment = [];

  final GlobalKey container = GlobalKey();
  final GlobalKey globalKey = GlobalKey();
  File _image;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    type.clear();
    fontsize.clear();
    offsets.clear();
    multiwidget.clear();
    howmuchwidgetis = 0;

    super.initState();
  }

  static Future<Directory> getAppDirectory() async {
    return Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getExternalStorageDirectory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey,
        key: scaf,
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.camera),
                onPressed: () {
                  bottomsheets();
                }),
            FlatButton(
                child: Text('Done'),
                textColor: Colors.white,
                onPressed: () {
                  screenshotController
                      .capture(
                          delay: Duration(milliseconds: 500), pixelRatio: 1.5)
                      .then((File image) async {
                    print("Capture Done");

                    final paths = await getAppDirectory();
                    await image.copy(paths.path +
                        '/' +
                        DateTime.now().millisecondsSinceEpoch.toString() +
                        '.png');
                    //TODO 这里获取到图片了,通过路由返回
                    Navigator.pop(context, image);
                  }).catchError((onError) {
                    print(onError);
                  });
                }),
          ],
          backgroundColor: widget.appBarColor,
        ),
        body: Center(
          child: Screenshot(
            controller: screenshotController,
            child: Container(
                margin: EdgeInsets.all(0),
                color: Colors.white,
                child: LayoutBuilder(
                  builder: (context, cc) {
                    return RepaintBoundary(
                        key: globalKey,
                        child: Stack(
                          children:()sync*{
                            if( _image != null){
                              yield Image.file(
                                _image,
                                height: cc.maxHeight.toDouble(),
                                width: cc.maxWidth.toDouble(),
                                fit: BoxFit.cover,
                              );
                            }
                            yield Container(
                              color: Colors.transparent,
                              height: cc.maxHeight,
                              width: cc.maxWidth,
                              child: GestureDetector(
                                  onPanUpdate: (DragUpdateDetails details) async {
                                    if(_scfFutController!=null){
                                      await _scfFutController.close();
                                      _scfFutController=null;
                                    }
                                  },
                                  onTap: () async {
                                    if(_scfFutController!=null){
                                     await _scfFutController.close();
                                     _scfFutController=null;
                                    }
                                  },
                                  onPanEnd: (DragEndDetails details) {

                                  },
                                  child: Signat(_controller, cc)
                              ),
                            );
                            yield Container(
                              child: Stack(
                                children: multiwidget.asMap().entries.map((f) {
                                  if (type[f.key] == 1) {
                                    StreamController<int> _stream=StreamController.broadcast();
                                    return StreamBuilder(
                                        stream: _stream.stream,
                                        builder: (context,snap){
                                      return EmojiView(
                                        left: offsets[f.key].dx,
                                        top: offsets[f.key].dy,
                                        ontap: () async {
                                          if(_scfFutController!=null){
                                            await _scfFutController.close();
                                            _scfFutController=null;
                                          }
                                          _scfFutController= scaf.currentState.showBottomSheet((context) {
                                            return Sliders(
                                              size: f.key,
                                              sizevalue: fontsize[f.key].toDouble(), stream:_stream
                                            );
                                          });
                                        },
                                        onpanupdate: (details) {
                                          setState(() {
                                            offsets[f.key] = Offset(
                                                offsets[f.key].dx +
                                                    details.delta.dx,
                                                offsets[f.key].dy +
                                                    details.delta.dy);
                                          });
                                        },
                                        value: f.value.toString(),
                                        fontsize: fontsize[f.key].toDouble(),
                                        align: TextAlign.center,
                                      );
                                    });
                                  } else if (type[f.key] == 2) {
                                    StreamController<int> _stream=StreamController.broadcast();
                                    return StreamBuilder(
                                        stream: _stream.stream,
                                        builder: (context,snap){
                                          return TextView(
                                            left: offsets[f.key].dx,
                                            top: offsets[f.key].dy,
                                            ontap: () async {
                                              if(_scfFutController!=null){
                                                await _scfFutController.close();
                                                _scfFutController=null;
                                              }
                                              _scfFutController= scaf.currentState
                                                  .showBottomSheet((context) {
                                                return Sliders(
                                                  size: f.key,
                                                  sizevalue: fontsize[f.key].toDouble(), stream:_stream
                                                );
                                              });
                                            },
                                            onpanupdate: (details) {
                                              setState(() {
                                                offsets[f.key] = Offset(
                                                    offsets[f.key].dx +
                                                        details.delta.dx,
                                                    offsets[f.key].dy +
                                                        details.delta.dy);
                                              });
                                            },
                                            value: f.value.toString(),
                                            fontsize: fontsize[f.key].toDouble(),
                                            align: TextAlign.center,
                                          );
                                        });
                                  }
                                  return Container();
                                }).toList(),
                              ),
                            );
                          }().toList(),
                        ));
                  },
                )),
          ),
        ),
        bottomNavigationBar: openbottomsheet
            ? Container()
            : Container(
                decoration: BoxDecoration(
                    color: widget.bottomBarColor,
                    boxShadow: [BoxShadow(blurRadius: 10.9)]),
                height: 70,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    BottomBarContainer(
                      colors: widget.bottomBarColor,
                      icons: FontAwesomeIcons.brush,
                      ontap: () {
                        _controller?.setErase(false);
                        // raise the [showDialog] widget
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Pick a color!'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: pickerColor,
                                  onColorChanged: changeColor,
                                  showLabel: true,
                                  pickerAreaHeightPercent: 0.8,
                                ),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: const Text('Got it'),
                                  onPressed: () {
                                    setState(() => currentColor = pickerColor);
                                    _controller?.setErase(false);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      title: 'Brush',
                    ),
                    BottomBarContainer(
                      icons: Icons.text_fields,
                      ontap: () async {
                        _controller?.setErase(false);
                        final value = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TextEditor()));
                        if (value.toString().isEmpty) {
                          print('true');
                        } else {
                          type.add(2);
                          fontsize.add(20);
                          offsets.add(Offset.zero);
                          multiwidget.add(value);
                          howmuchwidgetis++;
                          setState(() {

                          });
                        }
                      },
                      title: 'Text',
                    ),
                    BottomBarContainer(
                      icons: FontAwesomeIcons.eraser,
                      ontap: () {
                        _controller?.setErase(true);
                      },
                      title: 'Eraser',
                    ),
                    BottomBarContainer(
                      icons: FontAwesomeIcons.eraser,
                      ontap: () {
                        _controller?.setErase(false);
                        _controller?.wipe();
                        type.clear();
                        fontsize.clear();
                        offsets.clear();
                        multiwidget.clear();
                        howmuchwidgetis = 0;
                        setState(() {

                        });
                      },
                      title: 'Wipe',
                    ),

                    BottomBarContainer(
                      icons: FontAwesomeIcons.smile,
                      ontap: () {
                        _controller?.setErase(false);
                        var getemojis = showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Emojies();
                            });
                        getemojis.then((value) {
                          if (value != null) {
                            type.add(1);
                            fontsize.add(20);
                            offsets.add(Offset.zero);
                            multiwidget.add(value);
                            howmuchwidgetis++;
                            setState(() {

                            });
                          }
                        });
                      },
                      title: 'Emoji',
                    ),
                  ],
                ),
              ));
  }

  final picker = ImagePicker();

  void bottomsheets() {
    openbottomsheet = true;
    setState(() {});
    var future = showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(blurRadius: 10.9, color: Colors.grey[400])
          ]),
          height: 170,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('Select Image Options'),
              ),
              Divider(
                height: 1,
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(Icons.photo_library),
                                  onPressed: () async {
                                    var image = await picker.getImage(
                                        source: ImageSource.gallery);
                                    var decodedImage =
                                        await decodeImageFromList(
                                            File(image.path).readAsBytesSync());

                                    setState(() {
                                      // height = decodedImage.height;
                                      // width = decodedImage.width;
                                      _image = File(image.path);
                                    });
                                    setState(() => _controller?.wipe());
                                    Navigator.pop(context);
                                  }),
                              SizedBox(width: 10),
                              Text('Open Gallery')
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 24),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            IconButton(
                                icon: Icon(Icons.camera_alt),
                                onPressed: () async {
                                  var image = await picker.getImage(
                                      source: ImageSource.camera);
                                  var decodedImage = await decodeImageFromList(
                                      File(image.path).readAsBytesSync());

                                  setState(() {
                                    // height = decodedImage.height;
                                    // width = decodedImage.width;
                                    _image = File(image.path);
                                  });
                                  setState(() => _controller?.wipe());
                                  Navigator.pop(context);
                                }),
                            SizedBox(width: 10),
                            Text('Open Camera')
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
    future.then((void value) => _closeModal(value));
  }

  void _closeModal(void value) {
    openbottomsheet = false;
    setState(() {});
  }
}

class Signat extends StatefulWidget {
  final GestureWhiteboardController _controller;
  final BoxConstraints cc;

  Signat(this._controller, this.cc);

  @override
  _SignatState createState() => _SignatState();
}

class _SignatState extends State<Signat> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return //SIGNATURE CANVAS
        //SIGNATURE CANVAS
        ListView(
      children: <Widget>[
        Container(
          child: Signature(
              controller: widget._controller,
              height: widget.cc.maxHeight.toDouble(),
              width: widget.cc.maxWidth.toDouble()),
        ),
      ],
    );
  }
}

class Sliders extends StatefulWidget {
  final int size;
  final sizevalue;
  final StreamController<int> stream;
  const Sliders({Key key, this.size, this.sizevalue,this.stream}) : super(key: key);

  @override
  _SlidersState createState() => _SlidersState();
}

class _SlidersState extends State<Sliders> {
  @override
  void initState() {
    slider = widget.sizevalue;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 120,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('Slider Size'),
            ),
            Divider(
              height: 1,
            ),
            Slider(
                value: slider,
                min: 0.0,
                max: 100.0,
                onChangeEnd: (v) {
                  setState(() {
                    fontsize[widget.size] = v.toInt();
                    widget.stream.add(v.toInt());
                  });
                },
                onChanged: (v) {
                  setState(() {
                    slider = v;
                    print(v.toInt());
                    fontsize[widget.size] = v.toInt();
                  });
                }),
          ],
        ));
  }
}

class ColorPiskersSlider extends StatefulWidget {
  @override
  _ColorPiskersSliderState createState() => _ColorPiskersSliderState();
}

class _ColorPiskersSliderState extends State<ColorPiskersSlider> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      height: 260,
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text('Slider Filter Color'),
          ),
          Divider(
            height: 1,
          ),
          SizedBox(height: 20),
          Text('Slider Color'),
          SizedBox(height: 10),
          BarColorPicker(
              width: 300,
              thumbColor: Colors.white,
              cornerRadius: 10,
              pickMode: PickMode.Color,
              colorListener: (int value) {
                setState(() {
                  //  currentColor = Color(value);
                });
              }),
          SizedBox(height: 20),
          Text('Slider Opicity'),
          SizedBox(height: 10),
          Slider(value: 0.1, min: 0.0, max: 1.0, onChanged: (v) {})
        ],
      ),
    );
  }
}
