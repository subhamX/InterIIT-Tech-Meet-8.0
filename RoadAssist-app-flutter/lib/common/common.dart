import 'package:flutter/material.dart';
import 'package:roadassist/services/auth_service.dart';

class Common {
  // static String sbiFormId = 'sbi_home_loan';
  // static String unionBankFormId = 'union_bank_home_loan';
  // static String hdfcBankFormId = 'hdfc_professional_loan';
  // static String indianBankFormId = 'indian_bank_home_loan';
  // static String appRootUrl =
  //     'https://us-central1-formassist-a4711.cloudfunctions.net/serverFun/';
  // static String appUrl = 'https://formassist.subhamx.co/forms/fa/';
  // static List<Map<dynamic, dynamic>> forms = [
  //   {"name": "SBI HOME LOAN", "id": 0},
  //   {"name": "HDFC PROFESSIONAL LOAN", "id": 1},
  //   {"name": "UNION BANK HOME LOAN", "id": 2},
  //   {"name": "INDIAN BANK HOME LOAN", "id": 3},
  // ];
  static List<Color> ratingColors = [
    Colors.red,
    Colors.red[900],
    Colors.orange[600],
    Colors.green,
    Colors.green[600],
  ];

  static Color ratingColorsFun(int index){
    return Colors.red;
  }

  static List<String> ratingOptions = [
    'Very Poor',
    'Below Average',
    'Average',
    'Minor Issues',
    'Fine But Can Be Improved'
  ];

  static AppBar getAppBar(context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        'Road Assist',
        style: TextStyle(
          fontFamily: 'BBPU',
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.black, //change your color here
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('SIGN OUT'),
          onPressed: () {
            AuthService.signOut(context);
          },
        ),
      ],
    );
  }
}
