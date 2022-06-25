import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class HomeData extends ChangeNotifier
{
  String name=""; // initial value of count down timer

  String getName() => name;   //method to get update value of variable

  updateName(String value){
    name = value;//method to update the variable value

    notifyListeners();
  }
  String code=""; // initial value of count down timer

  String getCode() => code;   //method to get update value of variable

  updateCode(String value){
    code = value;//method to update the variable value

    notifyListeners();
  }
  String mobile=""; // initial value of count down timer

  String getMobile() => mobile;   //method to get update value of variable

  updateMobile(String value){
    mobile = value;//method to update the variable value

    notifyListeners();
  }

}