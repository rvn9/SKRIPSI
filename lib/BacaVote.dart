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

  SaveToHiveDB(Id_pasangan, TagID) async {

    var kartu_suara = VoteModel(
      TagID: TagID,
      Id_kandidat:Id_pasangan,
    );
    await data_suara_box.add(kartu_suara);
  }

  @override
  void initState() async{
    // TODO: implement initState
    super.initState();
    await Hive.registerAdapter(VoteModelAdapter());
    data_suara_box = await Hive.openBox('data_suara');
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

  baca_suara(context,_currUserTagID,hash, jsonData) async{
    String url = 'http://192.168.100.10:3000/endpoint/pemilih/get_data_pemilih';
    bool isVerified = false;
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

      if(response.statusCode == 200) {
        _userJson = jsonDecode(response.body);
        if(_userJson['data'][0]['Is_voted'] == false){
          if(_userJson['data'][0]['Hash_value'] == hash){

            // insert suara ke hive local db //
            SaveToHiveDB(jsonData['Id_pasangan'],jsonData['TagId']);

            // // masukin data vote ny ke suara lewat id pasangan //
            // insert_kartu_suara(jsonData['Id_pasangan'],jsonData['TagId']);

            setState(() {
              isVerified = true;
            });
          }
          _showDialog(context,isVerified);
        }else if(_userJson['data'][0]['Is_voted'] == true){
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Kartu berikut sudah digunakan.')));
        }
      }

    } catch (err){
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data.')));
    }

  }

  Future<void> insert_kartu_suara(Id_kandidat, TagID) async {
    String url = 'http://192.168.100.10:3000/endpoint/kandidat/vote';


    final response = await http.patch(url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'TagID' : TagID,
        'Id_Kandidat' : Id_kandidat
      }),
    );

    if(response.statusCode != 200) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Memasukan data ke kartu gagal, silahkan coba lagi.')));
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

                  // check hash value //
                  baca_suara(context, jsonData['TagId'], data_vote['hash'],jsonData);


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
