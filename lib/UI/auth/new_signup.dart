// Package import
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:SheelQuotient/UI/auth/new_otp.dart';
import 'package:SheelQuotient/constans/wsconstants.dart';
import 'package:SheelQuotient/model/appresponse.dart';
import 'package:SheelQuotient/model/signupsession.dart';
import 'package:SheelQuotient/utils/response_parser.dart';

// File import
import '../../common.dart';
import '../../Service/apiservice.dart';
import '../../colors.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  CommonFunction cf = new CommonFunction();
  bool _autoValidate = false;
  ApiService _api = new ApiService();
  String _mhtId;
  String _mobile;

  @override
  Widget build(BuildContext context) {
    return new Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: new Scaffold(
        backgroundColor: kQuizSurfaceWhite,
        body: SafeArea(
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
                    'SIGN UP',
                    textScaleFactor: 1.5,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  )
                ],
              ),
              new SizedBox(
                height: 50.0,
              ),
              new AccentColorOverride(
                color: kQuizBrown900,
                child: new TextFormField(
                  validator: cf.mhtIdValidation,
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
                  validator: cf.mobileValidation,
                  decoration: InputDecoration(
                    labelText: 'Mobile no.',
                    hintText: 'Enter Mobile no.',
                    prefixIcon: Icon(
                      Icons.call,
                      color: kQuizBrown900,
                    ),
                    filled: true,
                  ),
                  onSaved: (String value) {
                    _mobile = value;
                  },
                  keyboardType: TextInputType.numberWithOptions(),
                ),
              ),
              new SizedBox(height: 20.0),
              new RaisedButton(
                child: Text(
                  'SIGN UP',
                  style: TextStyle(color: Colors.white),
                ),
                elevation: 4.0,
                padding: EdgeInsets.all(20.0),
                onPressed: _submit,
              ),
              new SizedBox(height: 50.0),
              _loginBox(),
              new SizedBox(height: 15.0),
              _termsAndCondition(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginBox() {
    return new Container(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Text(
            'Already have an account?',
            style: TextStyle(color: Colors.grey),
          ),
          new FlatButton(
            child: new Text(
              'LOGIN NOW',
              style: TextStyle(
                color: kQuizBrown900,
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
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
              style: TextStyle(color: Colors.grey),
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
      try {
        _formKey.currentState.save();
        Map<String, dynamic> data = {'mht_id': _mhtId, 'password': _mobile};
        Response res = await _api.postApi(url: '/validate_user', data: data);
        AppResponse appResponse =
            ResponseParser.parseResponse(context: context, res: res);
        if (appResponse.status == WSConstant.SUCCESS_CODE) {
          SignUpSession signUpSession =
              SignUpSession.fromJson(appResponse.data);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  new OtpVerifyPage(signUpSession: signUpSession),
            ),
          );
        } else {
          cf.alertDialog(
            context: context,
            msg: appResponse.message,
            barrierDismissible: false,
            cancelButtonFn: null,
            doneButtonFn: null,
          );
        }
      } catch (err) {
        print('CATCH :: ');
        print(err);
        cf.alertDialog(
          context: context,
          msg: err.toString(),
          barrierDismissible: false,
          cancelButtonFn: null,
          doneButtonFn: null,
          doneButtonIcon: Icons.replay,
        );
      }
    } else {
      _autoValidate = true;
    }
  }
}
