import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:skripsi/util/encryption.dart';
import 'package:skripsi/util/nfcSession.dart';
import 'package:crypto/crypto.dart';
import "package:http/http.dart" as http;


class DoneVoting extends StatefulWidget {

  final userTagID;
  final id_pasangan;
  final nomor_urut_pasangan;
  DoneVoting(this.userTagID, this.id_pasangan, this.nomor_urut_pasangan);

  @override
  _DoneVotingState createState() => _DoneVotingState();
}

class _DoneVotingState extends State<DoneVoting> {
  bool isLoading = false;

  Future<void> save_data_vote(encrypted_data, hash, TagID) async {
    String url = 'http://192.168.100.10:3000/endpoint/pemilih/vote';


    final response = await http.post(url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'TagID' : TagID,
        'Data': encrypted_data,
        'Hash': hash,
      }),
    );

    if(response.statusCode != 200) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Memasukan data ke kartu gagal, silahkan coba lagi.')));
    }
  }

  // encrypt data //
  encrypt_data(data_to_encrypt, hash,TagId) async {
      String encrypted_data = encryptAESCryptoJS(jsonEncode(data_to_encrypt), "skripsi-andreas-agustinus-2017");
      // insert data to nfc card //
      NdefMessage message = NdefMessage([
        NdefRecord.createText(encrypted_data),
        NdefRecord.createText(hash.toString()),
      ]);
      save_data_vote(encrypted_data, hash.toString(),TagId);
      startSession(context: context, handleTag: (tag) => handleTag(tag, message));
  }


  @override
  Widget build(BuildContext context) {

    // data to encrypt //
    var data_to_encrypt = {
      "TagId" : widget.userTagID,
      "Id_pasangan" : widget.id_pasangan,
      "Nomor_urut_pasangan" : widget.nomor_urut_pasangan,
    };

    // generate hash //
    var bytes = utf8.encode(jsonEncode(data_to_encrypt)); // data being hashed
    var digest = sha1.convert(bytes);

    return Scaffold(
        body: Container(
          decoration: BoxDecoration(color: Colors.grey[150]),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center ,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 240.0,
                ),
                Text(
                  'Terima kasih telah',
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'menggunakan suara anda.',
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 200,
                ),
                Text("Berikut adalah kode hash anda.",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                ),
                Text(digest.toString(),
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30,
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.black87)),
                  onPressed: () => encrypt_data(data_to_encrypt, digest, widget.userTagID),
                  color: Colors.yellow,
                  textColor: Colors.black,
                  child: Text("LANJUT",
                      style: TextStyle(fontFamily: "Netflix", fontSize: 18)),
                ),
              ],
            ),
          ),
        )
    );


  }

  Future<String> handleTag(NfcTag tag, data) async {
    final tech = Ndef.from(tag);
    if (tech == null)
      throw('Tag is not compatible with NDEF.');
    if (!tech.isWritable)
      throw('Tag is not NDEF writable.');

    try {
      await tech.write(data);
    } on PlatformException catch (e) {
      throw(e.message ?? 'Some error has occurred.');
    }

    return '"Ndef - Write" is completed.';
  }

}

