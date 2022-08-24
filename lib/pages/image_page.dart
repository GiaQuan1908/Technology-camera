import 'package:flutter/material.dart';
import 'package:s_camera/pages/home_page.dart';
import 'package:s_camera/pages/library_page.dart';
import 'package:s_camera/utils/firebase_file.dart';

class ImagePage extends StatelessWidget {
  final FirebaseFile file;
  const ImagePage({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(file.name),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                file.ref.delete();
                // Navigator.of(context).pop();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => const MyHomePage()));
              },
              icon: Icon(Icons.delete)
          )

        ],
      ),

      body: Image.network(
        file.url,
        height: double.infinity,
        fit: BoxFit.fill,
      ),
    );
  }

}
