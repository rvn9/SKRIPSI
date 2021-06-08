import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import "package:http/http.dart" as http;
import 'package:skripsi/doneVoting.dart';

import 'models/voteModel.dart';




class VotingPage extends StatefulWidget {
  final userTagID, kategori;


  VotingPage(this.userTagID, this.kategori);

  @override
  _VotingPageState createState() => _VotingPageState();
}



class _VotingPageState extends State<VotingPage> {
  static MediaQueryData _mediaQueryData;
  List data = [];
  bool isLoading = false;
  List list_suara = [];
  Box data_pemilih;

  // load data kandidat //
  Future<void> load_data_kandidat_presiden() async {
    setState(() {
      isLoading = true;
    });
    String url = 'http://192.168.100.218:3000/endpoint/presiden/get_all_kandidat';
    final response = await http.get(url);
    if(response.statusCode == 200){
      var users_json = jsonDecode(response.body);
      setState(() {
        data = users_json;
        isLoading = false;
      });
    }else{
      data = [];
      isLoading = false;
      throw Exception('Failed to load kandidat, silahkan coba lagi.');
    }
  }

  Future<void> load_data_calon_dpr() async {
    setState(() {
      isLoading = true;
    });
    String url = 'http://192.168.100.218:3000/endpoint/dpr/get_all';
    final response = await http.get(url);
    if(response.statusCode == 200){
      var users_json = jsonDecode(response.body);
      setState(() {
        data = users_json;
        isLoading = false;
      });
    }else{
      data = [];
      isLoading = false;
      throw Exception('Failed to load kandidat, silahkan coba lagi.');
    }
  }

  Future<void> load_data_calon_dpd() async {
    setState(() {
      isLoading = true;
    });
    String url = 'http://192.168.100.218:3000/endpoint/dpd/get_all';
    final response = await http.get(url);
    if(response.statusCode == 200){
      var users_json = jsonDecode(response.body);
      setState(() {
        data = users_json;
        isLoading = false;
      });
    }else{
      data = [];
      isLoading = false;
      throw Exception('Failed to load kandidat, silahkan coba lagi.');
    }
  }

  Future<void> load_data_calon_dprd_provinsi() async {
    setState(() {
      isLoading = true;
    });
    String url = 'http://192.168.100.218:3000/endpoint/dprd_provinsi/get_all';
    final response = await http.get(url);
    if(response.statusCode == 200){
      var users_json = jsonDecode(response.body);
      setState(() {
        data = users_json;
        isLoading = false;
      });
    }else{
      data = [];
      isLoading = false;
      throw Exception('Failed to load kandidat, silahkan coba lagi.');
    }
  }

  Future<void> load_data_calon_dprd_kabupaten() async {
    setState(() {
      isLoading = true;
    });
    String url = 'http://192.168.100.218:3000/endpoint/dprd_kabupaten/get_all';
    final response = await http.get(url);
    if(response.statusCode == 200){
      var users_json = jsonDecode(response.body);
      setState(() {
        data = users_json;
        isLoading = false;
      });
    }else{
      data = [];
      isLoading = false;
      throw Exception('Failed to load kandidat, silahkan coba lagi.');
    }
  }

  Future<void> change_state(tagId, kategori) async {
    String url = 'http://192.168.100.218:3000/endpoint/pemilih/set_state';
    final response = await http.patch(url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'TagID' : tagId,
        'Kategori' : kategori
      }),
    );
  }

  Future<void> showMyDialogPresiden(tagID,  id, nomorUrutPasangan) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Anda yakin memilih kandidat nomor pasangan ' + nomorUrutPasangan + " ?"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Suara yang anda masukan, tanpa adanya paksaan untuk memilih pihak tertentu, semua murni keputusan anda sendiri.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                data_pemilih = await Hive.openBox('suara_pemilih');
                var kartu_suara = VoteModel(
                    TagID: tagID,
                    Id_calon:id,
                    Kategori: "presiden"
                );

                // insert kartu suara ke offline db (hive db) //
                data_pemilih.add(kartu_suara);
                change_state(widget.userTagID, "presiden");
                Navigator.of(context).pop();
                Navigator.of(context).pop();

              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> dialogKonfirmasi({tagID, id, suara, kategori, tipe}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Anda yakin memberikan suara anda untuk ' + suara + " ?"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Suara yang anda masukan, tanpa adanya paksaan untuk memilih pihak tertentu, semua murni keputusan anda sendiri.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                data_pemilih = await Hive.openBox('suara_pemilih');
                var kartu_suara = VoteModel(
                  TagID: tagID,
                  Id_calon:id,
                  Kategori: kategori,
                  Tipe: tipe
                );



                // insert kartu suara ke offline db (hive db) //
                data_pemilih.add(kartu_suara);
                change_state(widget.userTagID, kategori);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    switch(widget.kategori) {
      case "presiden" :
        load_data_kandidat_presiden();
        break;
      case "dpr_ri":
        load_data_calon_dpr();
        break;
      case "dpd_ri" :
        load_data_calon_dpd();
        break;
      case "dprd_provinsi" :
        load_data_calon_dprd_provinsi();
        break;
      case "dprd_kabupaten"  :
        load_data_calon_dprd_kabupaten();
        break;
    };
  }

  @override
  Widget build(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    // load data kandidat //
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
                      'Pilih Kandidat',
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
                    Text("Berikan suara anda dengan cara menekan salah satu kandidat / partai tertentu.",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Container(
                  height: MediaQuery.of(context).size.height * 0.006,
                  decoration: BoxDecoration(color: Colors.yellow)
              ),
              Container(
                  height: MediaQuery.of(context).size.height * 0.794,
                  decoration: BoxDecoration(color: Colors.grey[150]),
                  child: getBody(),
              )
            ]
        )
    );
  }

  Widget getBody(){
    if(data.length < 0 || isLoading){
      return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey),));
    }else{
      return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context,index){
            switch(widget.kategori) {
              case "presiden" :
                return getCardPresiden(data[index]);
                break;
              case "dpr_ri":
                return getCard(data[index],"dpr_ri");
                break;
              case "dpd_ri" :
                return getCardDpd(data[index]);
                break;
              case "dprd_provinsi" :
                return getCard(data[index],"dprd_provinsi");
                break;
              case "dprd_kabupaten" :
                return getCard(data[index],"dprd_kabupaten");
                break;
            };
            return Text("No Matching Criteria");
          });
    }
  }

  // card untuk calon presiden //
  Widget getCardPresiden(item){
    // id pasangan //
    var id_pasangan = item['_id'];

    // nomor urut passangan //
    var nomor_urut_pasangan = item['Nomor_urut_pasangan'];

    // presiden //
    var nama_calon_presiden = item['Calon_presiden'];

    // wakil presiden //
    var nama_calon_wakil_presiden = item['Calon_wakil_presiden'];

    // partai pendukung nanti aja deh //

    return GestureDetector(
      onTap: () => showMyDialogPresiden(widget.userTagID,id_pasangan,nomor_urut_pasangan),
      child: Card(
        elevation: 1.5,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListTile(
            title: Row(
              children: <Widget>[
                SizedBox(width: 20,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                        width: MediaQuery.of(context).size.width-140,
                        child: Text(nama_calon_presiden,style: TextStyle(fontSize: 17),)),
                    SizedBox(height: 10,),
                    Text(nama_calon_wakil_presiden.toString(),style: TextStyle(color: Colors.grey),)
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getCardDpd(item){
    var nama = item['Nama'];
    var nomor_urut = item['Nomor_urut'];
    var id_calon = item['_id'];
    return GestureDetector(
      onTap: () => dialogKonfirmasi(tagID: widget.userTagID, id: id_calon, suara: nama,kategori: "dpd_ri" ),
      child: Card(
        elevation: 1.5,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListTile(
            title: Row(
              children: <Widget>[
                SizedBox(width: 20,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                        width: MediaQuery.of(context).size.width-140,
                        child: Text(nama,style: TextStyle(fontSize: 17),)),
                    SizedBox(height: 10,),
                    Text("Nomor Urut " + nomor_urut,style: TextStyle(color: Colors.grey),)
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // card dpr ri, dprd provinsi, dan dprd kabupaten sama //
  Widget getCard(item, kategori_pilihan){
    var nama_parpol, id_partai, data_calon;
    switch(kategori_pilihan) {
      case "dpr_ri":
         nama_parpol = item['Parpol'];
         data_calon = item['Calon_dpr'];
         id_partai = item['_id'];
        break;
      case "dprd_provinsi" :
         nama_parpol = item['Parpol'];
         data_calon = item['Calon_dprd_provinsi'];
         id_partai = item['_id'];
        break;
      case "dprd_kabupaten" :
         nama_parpol = item['Parpol'];
         data_calon = item['Calon_dprd_kabupaten'];
         id_partai = item['_id'];
        break;
    };
    return Card(
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: () => dialogKonfirmasi(tagID: widget.userTagID,id: id_partai ,suara: nama_parpol, kategori: kategori_pilihan, tipe: "parpol"),
                child: Text(
                  nama_parpol,
                  style: TextStyle(
                      fontSize: 18
                  ),
                ),
              )
            ),
            Divider(
              height: 10,
            ),
            ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: data_calon.length,
                itemBuilder: (context, index){
                  return Container(
                    child: Column(
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  data_calon[index]['Nama_calon'],
                                  style: TextStyle(
                                      fontSize: 14
                                  ),
                                ),
                               SizedBox(
                                 height: 25,
                                 child:  ElevatedButton(
                                   child: Text('PILIH'),
                                   onPressed: () {
                                     dialogKonfirmasi(tagID: widget.userTagID, id: data_calon[index]['_id'] ,suara: data_calon[index]['Nama_calon'], kategori: kategori_pilihan, tipe: "individu");
                                   },
                                 ),
                               )
                              ],
                            )
                        )
                      ],
                    ),
                  );
                }),
          ],
        ),
      )
    );
  }


}

