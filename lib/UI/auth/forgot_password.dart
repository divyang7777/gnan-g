import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:SheelQuotient/constans/wsconstants.dart';
import 'package:SheelQuotient/model/appresponse.dart';
import 'package:SheelQuotient/model/signupsession.dart';
import 'package:SheelQuotient/utils/response_parser.dart';
import '../../UI/auth/new_otp.dart';
import '../../Service/apiservice.dart';
import '../../common.dart';
import '../../colors.dart';

class ForgotPassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ForgotPasswordState();
  }
}

class ForgotPasswordState extends State<ForgotPassword> {
  CommonFunction cf = new CommonFunction();
  final _formKey = GlobalKey<FormState>();
  ApiService _api = new ApiService();
  bool _autoValidate = false;
  String _mhtId;

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
                    'FORGOT PASSWORD',
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
              new RaisedButton(
                child: Text(
                  'SUBMIT',
                  style: TextStyle(color: Colors.white),
                ),
                elevation: 4.0,
                padding: EdgeInsets.all(20.0),
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState.validate()) {
      try {
        _formKey.currentState.save();
        Map<String, dynamic> data = {'mht_id': _mhtId};
        Response res = await _api.postApi(url: '/forgot_password', data: data);
        AppResponse appResponse = ResponseParser.parseResponse(context: context, res: res);
        if (appResponse.status == WSConstant.SUCCESS_CODE) {
          SignUpSession signUpSession = SignUpSession.fromJson(appResponse.data);
          Navigator.pop(context);
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
