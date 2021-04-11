
import 'dart:io';

import 'package:firexcode/firexcode.dart';
import 'package:image_editor_pro/image_editor_pro.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomePage().xMaterialApp();
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return buildCenter().xScaffold();
  }

  File image;

  Widget buildCenter() {
    print("buildCenter");
    return SafeArea(
      child: Stack(
        children: [
          GestureDetector(
            child:image!=null?Image.file(image):Image.network(
                "https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=2194302503,949681687&fm=26&gp=0.jpg"),
            onTap: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration:
                        Duration(milliseconds: 500), //动画时间为500毫秒
                    pageBuilder: (BuildContext context, Animation animation,
                        Animation secondaryAnimation) {
                      return new FadeTransition(
                          //使用渐隐渐入过渡,
                          opacity: animation,
                          child: ImageEditorPro());
                    },
                  )).then((image) {
                    this.image=image;
                    setState(() {

                    });
              });
            },
          ).toCenter(),
        ],
      ),
      top: false,
    );
  }
}
