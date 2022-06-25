import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class LoginData extends ChangeNotifier
{
  String code="+91"; // initial value of count down timer

  String getCountryCode() => code;   //method to get update value of variable

  updateCountryCode(String cc){
    code = cc;//method to update the variable value

    notifyListeners();
  }

}