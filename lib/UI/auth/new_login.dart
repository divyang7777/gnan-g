// Package import
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:SheelQuotient/constans/wsconstants.dart';
import 'package:SheelQuotient/model/appresponse.dart';
import 'package:SheelQuotient/model/userinfo.dart';
import 'package:SheelQuotient/utils/response_parser.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// File import
import '../../notification/notifcation_setup.dart';
import '../../common.dart';
import '../../Service/apiservice.dart';
import '../../colors.dart';
import '../../constans/sharedpref_constant.dart';
import '../../model/cacheData.dart';
import '../../model/user_state.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _autoValidate = false;
  bool _obscureText = true;
  ApiService _api = new ApiService();
  String _mhtId;
  String _password;

  @override
  Widget build(BuildContext context) {
    return new Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: new Scaffold(
        backgroundColor: kQuizSurfaceWhite,
        body: CustomLoading(
          isLoading: _isLoading,
          child: SafeArea(
            child: new ListView(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              children: <Widget>[
                new SizedBox(height: 40.0),
                new Column(
                  children: <Widget>[
                    new Image.asset(
                      'images/logo1.png',
                      height: 150,
                    ),
                    new SizedBox(height: 30.0),
                    new Text(
                      'SIGN IN',
                      textScaleFactor: 1.5,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                new SizedBox(
                  height: 50.0,
                ),
                new AccentColorOverride(
                  color: kQuizBrown900,
                  child: new TextFormField(
                    validator: CommonFunction.mhtIdValidation,
                    decoration: InputDecoration(
                      labelText: 'Mht Id',
                      hintText: 'Enter Mht Id no.',
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: kQuizBrown900,
                      ),
                      filled: true,
                    ),
                    onSaved: (String value) {
                      _mhtId = value;
                    },
                    keyboardType: TextInputType.numberWithOptions(),
                  ),
                ),
                new SizedBox(height: 20.0),
                new AccentColorOverride(
                  color: kQuizBrown900,
                  child: new TextFormField(
                    validator: CommonFunction.passwordValidation,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter Password',
                      prefixIcon: Icon(
                        Icons.vpn_key,
                        color: kQuizBrown900,
                      ),
                      filled: true,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        child: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          semanticLabel:
                              _obscureText ? 'show password' : 'hide password',
                          color: kQuizBrown900,
                        ),
                      ),
                    ),
                    onSaved: (String value) {
                      _password = value;
                    },
                    obscureText: _obscureText,
                  ),
                ),
                new SizedBox(height: 20.0),
                new RaisedButton(
                  child: Text(
                    'SIGN IN',
                    style: TextStyle(color: Colors.white),
                  ),
                  elevation: 4.0,
                  padding: EdgeInsets.all(20.0),
                  onPressed: _submit,
                ),
                new SizedBox(height: 15.0),
                _forgotPasswordBox(),
                new SizedBox(height: 20.0),
                _signupBox(),
                new SizedBox(height: 5.0),
                _termsAndCondition(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _signupBox() {
    return new Container(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Text(
            'Don\'t have an account?',
            style: TextStyle(color: kQuizMain50),
          ),
          new FlatButton(
            child: new Text(
              'SIGN UP NOW',
              style: TextStyle(
                color: kQuizBrown900,
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/signup');
            },
          ),
        ],
      ),
    );
  }

  Widget _forgotPasswordBox() {
    return new Container(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new FlatButton(
            child: new Text(
              'Forgot password ?',
              style: TextStyle(
                color: kQuizBrown900,
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/forgotPassword');
            },
          ),
        ],
      ),
    );
  }

  Widget _termsAndCondition() {
    return new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new FlatButton(
            child: new Text(
              'Terms and Conditions',
              style: TextStyle(color: kQuizMain50),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/t&c');
            },
          ),
        ],
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState.save();
      print('LOGIN DATA');
      print('MOBILE : ${this._mhtId}');
      print('PASSWORD : ${this._password}');
      try {
        Response res = await _api.login(mhtId: _mhtId, password: _password);
        AppResponse appResponse =
            ResponseParser.parseResponse(context: context, res: res);
        if (appResponse.status == WSConstant.SUCCESS_CODE) {
          UserInfo userInfo = UserInfo.fromJson(appResponse.data);
          CacheData.userInfo = userInfo;
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.setString('user_info', res.body);
          pref.setString('token', userInfo.token);
          pref.setBool(SharedPrefConstant.b_isUserLoggedIn, true);
          print(userInfo);
          _api.appendTokenToHeader(userInfo.token);
          NotificationSetup.setupNotification(userInfo: userInfo);
          _loadUserState(int.parse(this._mhtId));
        }
      } catch (err) {
        print('CATCH 1 :: ');
        print(err);
        setState(() {
          _isLoading = false;
        });
        CommonFunction.displayErrorDialog(
            context: context, msg: err.toString());
      }
    } else {
      _autoValidate = true;
    }
  }

  onClickDone() {
    print('Try Again ... ');
    Navigator.pop(context);
  }

  _loadUserState(int mhtId) async {
    try {
      Response res = await _api.getUserState(mhtId: mhtId);
      AppResponse appResponse =
          ResponseParser.parseResponse(context: context, res: res);
      if (appResponse.status == WSConstant.SUCCESS_CODE) {
        print('IN LOGIN ::: userstateStr :::');
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString('userState', res.body);
        UserState userState = UserState.fromJson(appResponse.data['results']);
        CacheData.userState = userState;
        Navigator.pushReplacementNamed(context, '/level_new');
      }
    } catch (err) {
      print('CATCH 2 :: ');
      print(err);
      CommonFunction.displayErrorDialog(context: context, msg: err.toString());
    }
  }
}
