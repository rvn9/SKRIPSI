import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:skripsi/doneVoting.dart';
import 'package:skripsi/votingPage.dart';

class KategoriSuara extends StatefulWidget {
  var _userData;
  KategoriSuara(this._userData);


  @override
  _KategoriSuaraState createState() => _KategoriSuaraState();
}

class _KategoriSuaraState extends State<KategoriSuara> {
  final List list_kategori_suara = [
    {
      "title" : "Presiden & Wakil Presiden",
      "kategori" : "presiden",
    },
    {
      "title" : "DPR RI",
      "kategori" : "dpr_ri",
    },
    {
      "title" : "DPD RI",
      "kategori" : "dpd_ri",
    },
    {
      "title" : "DPRD Provinsi",
      "kategori" : "dprd_provinsi"
    },
    {
      "title" : "DPRD Kabupaten / Kota",
      "kategori" : "dprd_kabupaten"
    }
  ];

  Future<Object> refresh_state (context,_currUserTagID) async{
    var _userJson;
    String url = 'http://192.168.100.218:3000/endpoint/pemilih/get_data_pemilih';

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
        if(_userJson['data'][0]['Privilege'] == "user") {
          // move to pemilih page //
          var data = {
            "TagID": _userJson['data'][0]['TagID'],
            "Is_voted": _userJson['data'][0]['Is_voted'],
            "Is_saved": _userJson['data'][0]['Is_saved']
          };

          setState(() {
            widget._userData = data;
          });
        }
      }

    } catch (err){
      log("Terima dari server");
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data.')));
    }

  }

  @override
  Widget build(BuildContext context) {
    refresh_state(context, widget._userData['TagID']);
    bool all_saved = false;
    if( widget._userData['Is_saved']['presiden'] == true && widget._userData['Is_saved']['dpr_ri'] == true && widget._userData['Is_saved']['dpd_ri'] == true && widget._userData['Is_saved']['dprd_provinsi'] == true && widget._userData['Is_saved']['dprd_kabupaten'] == true){
      setState(() {
        all_saved = true;
      });
    }
    return Scaffold(
        body: Column(
            children:[
              Container(
                decoration: BoxDecoration(color: Colors.white),
                height: MediaQuery.of(context).size.height * 0.2,
                child: Column(
                  children: [
                    Divider(
                      color: Colors.transparent,
                      height: 100,
                    ),
                    Text(
                      'Kategori Suara',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                    Divider(
                      color: Colors.transparent,
                      height: 5,
                    ),
                    Text("Pilihlah kategori yang sesuai dengan yang anda inginkan.",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: Colors.black54),
                    ),
                    Divider(
                      color: Colors.transparent,
                      height: 5,
                    ),
                  ],
                ),
              ),
              Container(
                  height: MediaQuery.of(context).size.height * 0.006,
                  decoration: BoxDecoration(color: Colors.yellow)
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.694,
                decoration: BoxDecoration(color: Colors.grey[150]),
                child: getBody(),
              ),
              SizedBox(
                child:  Visibility(
                  visible: all_saved,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.black87)),
                    onPressed: () => Navigator.push(context,MaterialPageRoute(builder: (context) => DoneVoting(widget._userData['TagID']))),
                    color: Colors.yellow,
                    textColor: Colors.black,
                    child: Text("LANJUT",
                        style: TextStyle(fontFamily: "Netflix", fontSize: 18)),
                  ),
                )
              ),
            ]
        )
    );
  }


  Widget getBody(){
    return ListView.builder(
        itemCount: list_kategori_suara.length,
        itemBuilder: (context,index){
          return getCard(list_kategori_suara[index]);
        });
  }

  Widget getCard(item){
    return GestureDetector(
      onTap: () => widget._userData['Is_saved'][item['kategori']] ?
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hak suara anda sudah digunakan untuk kategori tersebut.')))
          : Navigator.push(context,MaterialPageRoute(builder: (context) => VotingPage(widget._userData['TagID'], item['kategori']))),
      child: Card(
        elevation: 1.5,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  item['title']
                ),
                widget._userData['Is_saved'][item['kategori']] ?
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 40.0,
                ) :
                Icon(
                  Icons.highlight_off,
                  color: Colors.red,
                  size: 40.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
