import 'dart:io';
import 'package:image_editor_pro/image_editor_pro.dart';
import 'package:firexcode/firexcode.dart';

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
    return buildCenter().xScaffold(
            appBar:
                'Image Editor Pro example'.xTextColorWhite().xAppBar(),
            floatingActionButton:
                Icons.add.xIcons().xFloationActiobButton(color: Colors.red));
  }

  Widget buildCenter(){
    return SafeArea(child: Stack(
      children: [
        Image.network("https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=2194302503,949681687&fm=26&gp=0.jpg").toCenter(),
        ImageEditorPro()
      ],
    ),top: false,);
  }
}


