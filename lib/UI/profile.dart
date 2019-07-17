import 'dart:convert';
import 'dart:io';

import 'package:GnanG/Service/apiservice.dart';
import 'package:GnanG/Service/profile_pic.dart';
import 'package:GnanG/UI/animation/success.dart';
import 'package:GnanG/UI/imagepicker/image_input.dart';
import 'package:GnanG/UI/new_leaderboard/profile_service.dart';
import 'package:GnanG/UI/widgets/base_state.dart';
import 'package:GnanG/colors.dart';
import 'package:GnanG/common.dart';
import 'package:GnanG/constans/appconstant.dart';
import 'package:GnanG/constans/wsconstants.dart';
import 'package:GnanG/model/appresponse.dart';
import 'package:GnanG/model/cacheData.dart';
import 'package:GnanG/utils/appsharedpref.dart';
import 'package:GnanG/utils/response_parser.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ProfilePagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new ProfilePagePageState();
}

class ProfilePagePageState extends BaseState<ProfilePagePage> {
  ApiService _api = new ApiService();
  Image profileImage;
  ProfilePic profilePicService = new ProfilePic();

  @override
  void initState() {
    super.initState();
    _loadData();
    // Flame.audio.play('music/bensound-epic.mp3', volume: 0.5);
  }

  _loadData() async {
    File profilePic = await profilePicService.readProfilePic(
        CacheData.userInfo.mhtId, CacheData.userInfo.profilePicVersion);
    // If Not availabale in storage then download and save if url is available
    if (profilePic != null &&
        !profilePic.existsSync() &&
        CacheData.userInfo.profilePic != null &&
        CacheData.userInfo.profilePic.isNotEmpty) {
      profilePic = await profilePicService.writeProfilePic(
          CacheData.userInfo.profilePic,
          CacheData.userInfo.mhtId,
          CacheData.userInfo.profilePicVersion);
    }
    profileImage = Image(
      image: profilePic != null && profilePic.existsSync()
          ? FileImage(profilePic)
          : AssetImage(AppConstant.DEFAULT_USER_IMG_PATH),
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget pageToDisplay() {
    return new Scaffold(
      backgroundColor: kQuizSurfaceWhite,
      body: BackgroundGredient(
        child: new SafeArea(
          child: new ListView(
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            children: <Widget>[
              _gameBar(),
              SizedBox(
                height: 20.0,
              ),
              _userCard(),
              SizedBox(
                height: 20.0,
              ),
              _profileData(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gameBar() {
    return new Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 30, right: 20),
          child: CircleAvatar(
            maxRadius: 22,
            backgroundColor: kQuizMain400,
            child: PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Text('Rules'),
                      value: 'rules',
                    ),
                    PopupMenuItem(
                      child: Text('About'),
                      value: 'about',
                    )
                  ],
              onSelected: (value) {
                Navigator.pushNamed(context, '/$value');
              },
            ),
          ),
        ),
        new Expanded(
          child: Center(
            child: Image.asset(
              'images/logo1.png',
              height: 70.0,
            ),
          ),
        ),
        _iconButton(
          Icon(Icons.power_settings_new, color: Colors.white),
          () {
            CommonFunction.alertDialog(
              context: context,
              msg: 'Are you sure you want to log out?',
              type: 'info',
              barrierDismissible: false,
              showCancelButton: true,
              doneButtonFn: () {
                _api.logout();
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login_new');
              },
            );
          },
        ),
      ],
    );
  }

  Widget _userCard() {
    return new Container(
      height: 250,
      child: new Stack(
        children: <Widget>[
          _userDetail(),
          Positioned(
            top: 0,
            left: MediaQuery.of(context).size.width / 2 - 80,
            child: _userAvatar(),
          ),
        ],
      ),
    );
  }

  _profileData() {
    return new Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      margin: EdgeInsets.symmetric(vertical: 10),
      color: Colors.grey[50],
      elevation: 4,
      child: new Padding(
        padding: EdgeInsets.all(20),
        child: new Column(
          children: <Widget>[
            Text(
              'Profile data',
              textScaleFactor: 1.5,
              style: TextStyle(
                color: kQuizMain400,
              ),
            ),
            SizedBox(height: 15),
            new Divider(),
            SizedBox(height: 15),
            CommonFunction.titleAndData(
                context, 'Mobile no. : ', CacheData.userInfo.mobile),
            SizedBox(height: 15),
            CommonFunction.titleAndData(
                context,
                'Email id : ',
                CacheData.userInfo.email != null
                    ? CacheData.userInfo.email
                    : ""),
            SizedBox(height: 15),
            CommonFunction.titleAndData(
                context, 'Center : ', CacheData.userInfo.center),
          ],
        ),
      ),
    );
  }

  Widget _userDetail() {
    return Card(
      margin: EdgeInsets.fromLTRB(5, 50, 5, 0),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      color: Colors.grey[50],
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: new Column(
          children: <Widget>[
            new SizedBox(
              height: 50,
            ),
            new Text(
              CacheData.userInfo.name,
              textScaleFactor: 1.5,
              style: TextStyle(
                fontWeight: FontWeight.w200,
                color: kQuizMain400,
              ),
            ),
            new SizedBox(
              height: 30,
            ),
            new Row(
              children: <Widget>[
                _scoreData(
                    'Points', CacheData.userState.totalscore_month.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreData(String title, String value) {
    return new Expanded(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              textScaleFactor: 1,
              style: TextStyle(color: kQuizMain50),
            ),
            SizedBox(height: 5.0),
            Text(
              value,
              textScaleFactor: 2,
              style: TextStyle(color: kQuizMain400),
            )
          ],
        ),
      ),
    );
  }

  Widget _iconButton(Icon icon, Function clickEvent) {
    return new RaisedButton(
      onPressed: clickEvent,
      child: icon,
      shape: new CircleBorder(),
      elevation: 5.0,
      padding: const EdgeInsets.all(10.0),
    );
  }

  Widget _userAvatar() {
    return ImageInput(onImagePicked: onImagePicked, image: profileImage);
  }

  void onImagePicked(File image) async {
    setState(() {
      isOverlay = true;
    });
    try {
      Response res = await _api.uploadProfilePicture(
          mhtId: CacheData.userInfo.mhtId, file: image);
      AppResponse appResponse =
          ResponseParser.parseResponse(context: context, res: res);
      if (appResponse.status == WSConstant.SUCCESS_CODE) {
        CacheData.userInfo.profilePicVersion += 1;
        CacheData.userInfo.profilePic = appResponse.data['img_dropbox_url'];
        await profilePicService.writeProfilePic(
            appResponse.data['img_dropbox_url'],
            CacheData.userInfo.mhtId,
            CacheData.userInfo.profilePicVersion);
        File profilePic = await profilePicService.readProfilePic(
            CacheData.userInfo.mhtId, CacheData.userInfo.profilePicVersion);
        setState(() {
          if (profilePic.existsSync()) {
            profileImage = Image(image: FileImage(profilePic));
          }
        });
      }
    } catch (error) {
      print("Error while uploading Profile Picture:" + error);
    }
    setState(() {
      isOverlay = false;
    });
  }
}
