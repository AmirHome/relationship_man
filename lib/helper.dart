import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Helper {

  // static Helper _instance;
  // factory Helper() => _instance ??= new Helper._();
  // Helper._();

  Map userDetails = {};
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // --- Method for getting user details from shared preference ---
  Future<Map>getUserDetailsFromSharedPreference () async {
    try {
      final SharedPreferences prefs = await _prefs;

      if(prefs.getString('user') != null) {
        this.userDetails = jsonDecode(prefs.getString('user')??'');
      } else {
        print('Shared preference has no data');
      }

    } catch (e){
      print('Exception caught at getUserDetails method');
      print(e.toString());
    }

    return this.userDetails;
  }

  static void log(String? string){
    print("LogMan: $string");
  }

}