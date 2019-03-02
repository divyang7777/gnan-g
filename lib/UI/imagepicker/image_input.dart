import 'dart:io';
import 'dart:typed_data';

import 'package:GnanG/Service/apiservice.dart';
import 'package:GnanG/UI/imagepicker/image_picker_handler.dart';
import 'package:GnanG/colors.dart';
import 'package:flutter/material.dart';

class ImageInput extends StatefulWidget {

  Function onImagePicked;
  Uint8List base64Image;
  ImageInput({this.base64Image, this.onImagePicked});
  @override
  _ImageInputState createState() => new _ImageInputState();
}

class _ImageInputState extends State<ImageInput>
    with TickerProviderStateMixin, ImagePickerListener {
  File _image;
  AnimationController _controller;
  ImagePickerHandler imagePicker;
  ApiService _api = new ApiService();
  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    imagePicker = new ImagePickerHandler(this, _controller);
    imagePicker.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        new Center(
            child: new Stack(
          children: <Widget>[
            _buildProfilePicture(widget.base64Image),
            new Center(
              child: new GestureDetector(
                onTap: () => imagePicker.showDialog(context),
                child: _buildCamera(),
              ),
            ),
          ],
        )),
      ],
    );
  }

  _buildCamera() {
    return Container(
        width: 100.0,
        height: 100.0,
        alignment: Alignment.bottomRight,
        child: CircleAvatar(
          maxRadius: 17,
          child: new Container(
            decoration: new BoxDecoration(

            ),
            child: Image(
              height: 27,
              width: 27,
              image: AssetImage('images/photo_camera.png'),
            ),
          ),
        ));
  }

  _buildProfilePicture(Uint8List data) {
    return CircleAvatar(
      maxRadius: 48,
      child: CircleAvatar(
        maxRadius: 45,
        backgroundImage: data == null ? AssetImage('images/face.jpg') : MemoryImage(data),
      ),
      backgroundColor: kQuizBrown900,
    );
  }

  @override
  userImage(File _image) async {
    _image.length().then((data) {print("Profile image size:" + (data/1000).toString());});
    if(widget.onImagePicked != null) {
      widget.onImagePicked(_image);
    }
    /*setState(() {
      this._image = _image;
    });*/

  }
}
