import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '/filters/subfilters.dart';
import '/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';
import '/filters/image_filters.dart';
import '/utils/convolution_kernels.dart';

void main() => runApp(new MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String fileName = '';
  List<Filter> filters = presetFiltersList;
  File temp;
  File imageFile;
  // final ImagePicker _picker = ImagePicker();

  Future getImage(context) async {
    imageFile = File(await ImagePicker()
        .pickImage(source: ImageSource.gallery)
        .then((value) => value.path));

    fileName = basename(imageFile.path);

    var image = imageLib.decodeImage(imageFile.readAsBytesSync());

    var customImageFilter = new ImageFilter(name: "Custom Image Filter");

    customImageFilter.subFilters.add(SaturationSubFilter(25));

    setState(() {
      filters.add(customImageFilter);
    });

    // customImageFilter.apply(
    //     imageFile.readAsBytesSync(), image.width, image.height);

    image = imageLib.copyResize(image, width: 600);

    Map imagefile = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new PhotoFilterSelector(
          title: Text("Photo Filter Example"),
          image: image,
          filters: filters,
          filename: fileName,
          loader: Center(child: CircularProgressIndicator()),
          fit: BoxFit.contain,
        ),
      ),
    );
    if (imagefile != null && imagefile.containsKey('image_filtered')) {
      setState(() {
        imageFile = imagefile['image_filtered'];
      });
      print(imageFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Photo Filter Example'),
      ),
      body: Center(
        child: new Container(
          child: imageFile == temp
              ? Center(
                  child: new Text('No image selected.'),
                )
              : Image.file(imageFile),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          getImage(context);
        },
        tooltip: 'Pick Image',
        child: new Icon(Icons.add_a_photo),
      ),
    );
  }
}
