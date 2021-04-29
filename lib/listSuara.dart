import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:skripsi/models/voteModel.dart';
import "package:http/http.dart" as http;
import 'package:connectivity/connectivity.dart';

class ListSuara extends StatefulWidget {
  final TagID_admin;
  ListSuara(this.TagID_admin);

  @override
  _ListSuaraState createState() => _ListSuaraState();
}

class _ListSuaraState extends State<ListSuara> {

  bool Is_sended_to_server;
  // insert data suara ke server //
  insert_kartu_suara(ListSuara) async{

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Tidak menemukan koneksi internet.')));
    } else{
      ListSuara.forEach((data) =>
          vote(data['TagID'], data['Id_presiden'], data['Id_dpr'], data['dprType'] ,data['Id_dpd'], data['Id_dprd_provinsi'], data['dprdProvinsiType'],data['Id_dprd_kabupaten'], data['dprdKabupatenType'])
      );
      Hive.box('data_suara').clear();
    }
  }



  // http req ke server //
  Future<void> vote(TagID, Id_presiden, Id_dpr,dprType, Id_dpd, Id_dprd_provinsi,dprdProvinsiType, Id_dprd_kabupaten, dprdKabupatenType) async {
    String url = 'http://192.168.100.218:3000/endpoint/presiden/vote';
    final response = await http.patch(url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'TagID' : TagID,
        'Id_presiden' : Id_presiden,
        "Id_dpr" : Id_dpr,
        "dprType" : dprType,
        "Id_dpd" : Id_dpd,
        "Id_dprd_provinsi" : Id_dprd_provinsi,
        "dprdProvinsiType" : dprdProvinsiType,
        "Id_dprd_kabupaten" : Id_dprd_kabupaten,
        "dprdKabupatenType" : dprdKabupatenType
      }),
    );

    if(response.statusCode == 200) {
      print(response.body);
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Sukses Mengirim data ke server.')));
    }else {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Memasukan data ke kartu gagal, silahkan coba lagi.')));
    }
  }

  @override
  Widget build(BuildContext context) {

    List _listSuara = <VoteModel>[];

    return ValueListenableBuilder(
      valueListenable: Hive.box('data_suara').listenable(),
      builder: (context, box, widget) {
        _listSuara = box.values.toList();
        // check isiny ada ga //
        if (box.values.isEmpty) {
          return Center(
            child: Text(
              "BELUM ADA DATA SUARA."
            ),
          );
        } else {
          return Container(
            child: Column(
              children: [
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: _listSuara.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 1.5,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                 _listSuara[index]['TagID']
                              ),
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 40.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Divider(
                  color: Colors.transparent,
                  height: 20,
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.black87)),
                  onPressed: () => insert_kartu_suara(_listSuara),
                  color: Colors.yellow,
                  textColor: Colors.black,
                  child: Text("KIRIM KE SERVER",
                      style: TextStyle(fontFamily: "Netflix", fontSize: 18)),
                ),
              ],
            )
          );
        }
      },
    );
  }
}
