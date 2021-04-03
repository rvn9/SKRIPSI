import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:skripsi/adminPage.dart';
import 'package:skripsi/util/util.dart';
import 'package:skripsi/votingPage.dart';
import "package:http/http.dart" as http;


class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}


Future<bool> checkNFC() async {
  bool nfc_is_available = await NfcManager.instance.isAvailable();
  return nfc_is_available;
}

void _create_new_pemilih(context, _currUserTagID) {
  String url = 'http://192.168.100.10:3000/endpoint/pemilih/add_new_pemilih';

  http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'TagID': _currUserTagID,
    }),
  ).then((res) => {
    if(res.statusCode == 200){
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Sukses Menambahkan Akun')))
    }else{
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Gagal Menambahkan Akun')))
    }
  });
}

Future<Object> check_user (context,_currUserTagID) async{
  var _userJson;
  String url = 'http://192.168.100.10:3000/endpoint/pemilih/get_data_pemilih';

  try {
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'TagID': _currUserTagID,
      }),
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      _userJson = jsonDecode(response.body);
      // check if user data exist //
      if(_userJson["response"] == "ERROR"){
        // create new user //
        _create_new_pemilih(context,_currUserTagID);
      }else {
        // check user privilege //
        if(_userJson['data'][0]['Privilege'] == "user"){
          // move to pemilih page //
          var data = {
            "TagID" : _userJson['data'][0]['TagID']
          };
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => VotingPage(data)));
        }else if(_userJson['data'][0]['Privilege'] == "admin"){
          // move to admin page //
          var data = {
            "TagID" : _userJson['data'][0]['TagID']
          };
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AdminPage(data)));
        }
      }
    }
    else {
      throw Exception("Failed to load data");
    }
  } catch (err){
    Scaffold.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data.')));
  }

}

class _HomePageState extends State<HomePage> {
  String _currUserTagID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: checkNFC(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data == false) {
            return Center(
              child: Text("Sorry your phone doesn't support NFC"),
            );
          }else {
            // Start Session
            NfcManager.instance.startSession(
              onDiscovered: (NfcTag tag) async {
                NfcA nfcA = NfcA.from(tag);
                if (nfcA == null) {
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text('Data tidak ditemukan, mohon coba lagi.')));
                }else{
                  _currUserTagID = hexFromBytes(nfcA.identifier).toString();
                  print(_currUserTagID);
                  check_user(context, _currUserTagID);
                  // stop session //
                  NfcManager.instance.stopSession();
                }
              },
            );

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center ,
                children: [
                  Icon(
                    Icons.nfc,
                    color: Colors.black,
                    size: 240.0,
                  ),
                  Text(
                    'Scan your nfc card here.',
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
