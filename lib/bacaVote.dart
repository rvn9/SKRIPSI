import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'dart:convert';
import "package:http/http.dart" as http;
import 'package:skripsi/models/voteModel.dart';
import 'package:skripsi/util/encryption.dart';

class BacaVote extends StatefulWidget {

  @override
  _BacaVoteState createState() => _BacaVoteState();
}


class _BacaVoteState extends State<BacaVote> {
  var _userJson;
  Box data_suara_box;
  List _listSuara = <VoteModel>[];
  bool isVerified = false;

  SaveToHiveDB(data) async {
    data_suara_box = await Hive.openBox('data_suara');
    var kartu_suara = {
      "TagID" : data['TagID'],
      "Id_presiden" : data['Id_presiden'],
      "Id_dpr" : data['Id_dpr'],
      "dprType" : data['dprType'],
      "Id_dpd" : data['Id_dpd'],
      "Id_dprd_provinsi" :  data['Id_dprd_provinsi'],
      "dprdProvinsiType" : data['dprdProvinsiType'],
      "Id_dprd_kabupaten" : data['Id_dprd_kabupaten'],
      "dprdKabupatenType" : data['dprdKabupatenType'],
    };



    // insert kartu suara ke offline db (hive db) //
    data_suara_box.add(kartu_suara);



  }

  CheckDuplicateHiveDB(data, hash) async{

    data_suara_box = await Hive.openBox('data_suara');
    _listSuara = data_suara_box.values.toList();
    print(_listSuara);
    if(_listSuara.isEmpty){
      if(_userJson['data'][0]['Hash_value'] == hash){
        SaveToHiveDB(data);
        setState(() {
          isVerified = true;
        });
      }
      _showDialog(context,isVerified);
    }else{
      for (var suara in _listSuara) {
        if(suara['TagID'] == data['TagID'] ){
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Kartu berikut sudah digunakan.')));
          break;
        }else {
          if(_userJson['data'][0]['Hash_value'] == hash){
            SaveToHiveDB(data);
            setState(() {
              isVerified = true;
            });
          }
          _showDialog(context,isVerified);
          break;
        }
      }
    }


  }


  Future<bool> checkNFC() async {
    bool nfc_is_available = await NfcManager.instance.isAvailable();
    return nfc_is_available;
  }

  void _showDialog(BuildContext context, isVerified) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: new Text("Hash Code Verified"),
          content: isVerified ? Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 240.0,
          ) :  Icon(
            Icons.highlight_off,
            color: Colors.red,
            size: 240.0,
          ),
          actions: <Widget>[
            new TextButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  baca_suara(context,TagID,hash, jsonData) async{
    String url = 'http://192.168.100.218:3000/endpoint/pemilih/get_data_pemilih';
    print(TagID);
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'TagID': TagID,
        }),
      ).timeout(const Duration(seconds: 20));

      if(response.statusCode == 200) {
        _userJson = jsonDecode(response.body);
        if(_userJson['data'][0]['Is_readed'] == true){
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Kartu berikut sudah digunakan.')));
        }else{
          CheckDuplicateHiveDB(jsonData, hash);
        }

      }

    } catch (err){
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data.')));
    }

  }


  @override
  Widget build(BuildContext context) {
    String voting_data, hash;

    var data_vote;
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
                final ndef = Ndef.from(tag);
                if (nfcA == null) {
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text('Data tidak ditemukan, mohon coba lagi.')));
                }else{

                  Iterable.generate(ndef.cachedMessage?.records?.length ?? 0).forEach((i) {
                    final record = ndef.cachedMessage.records[i];

                    final languageCodeLength = record.payload.first;
                    if(i == 0){
                      voting_data = utf8.decode(record.payload.sublist(1 + languageCodeLength));
                    }else{
                      hash = utf8.decode(record.payload.sublist(1 + languageCodeLength));
                    }

                    data_vote = {
                      "data": voting_data,
                      "hash": hash,
                    };
                  });

                  var decrpyted = decryptAESCryptoJS(data_vote['data'], "skripsi-andreas-agustinus-2017");
                  var jsonData = jsonDecode(decrpyted);

                  print(jsonData);
                  // check hash value //
                  baca_suara(context, jsonData['TagID'], data_vote['hash'],jsonData);


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
