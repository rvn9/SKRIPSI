import 'dart:convert';
import "package:http/http.dart" as http;
import 'package:flutter/material.dart';

class PerolehanSuara extends StatefulWidget {
  @override
  _PerolehanSuaraState createState() => _PerolehanSuaraState();
}



class _PerolehanSuaraState extends State<PerolehanSuara> {
  List data = [];
  bool isLoading = false;

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
      setState(() {
        data = [];
        isLoading = false;
      });
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

  Widget getCardPresiden(item){
    // presiden //
    var nama_calon_presiden = item['Calon_presiden'];

    // wakil presiden //
    var nama_calon_wakil_presiden = item['Calon_wakil_presiden'];

    // partai pendukung nanti aja deh //

    return Card(
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
                      child: Text(nama_calon_presiden,style: TextStyle(fontSize: 12),)),
                  SizedBox(height: 10,),
                  Text(nama_calon_wakil_presiden.toString(),style: TextStyle(fontSize: 12),),
                  SizedBox(height: 10,),
                  Text("Jumlah Suara : " + item['Jumlah_suara'].toString(), style: TextStyle(fontSize: 17,  fontWeight: FontWeight.bold),)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getCardDpr(item, kategori_pilihan){
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
              Text(
                nama_parpol,
                style: TextStyle(
                    fontSize: 18
                ),
              ),
              Text(
                "Jumlah suara untuk partai : " + item['Jumlah_suara'].toString(),
                style: TextStyle(
                    fontSize: 12
                ),
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
                                  Text(
                                    data_calon[index]['Jumlah_suara'].toString(),
                                    style: TextStyle(
                                        fontSize: 14
                                    ),
                                  ),
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

  PerolehanSuaraPresiden(context){
    print(data);
    if(data.length < 0) {
      return Center(child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey),));
    }else{
      return showDialog(
          context: context,
          builder: (_) => StatefulBuilder(
              builder: (context, setState){
                return  new Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: EdgeInsets.all(10),
                    child: Center(
                      child:  Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15), color: Colors.white),
                          padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                          child: SingleChildScrollView(
                            physics: ScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Perolehan Suara Sementara",
                                    style: TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.start),
                                Text("Kategori Presiden & Wakil Presiden",
                                    style: TextStyle(fontSize: 14),
                                    textAlign: TextAlign.start),
                                ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  itemCount: data.length,
                                  itemBuilder: (_, index) {
                                    return getCardPresiden(data[index]);
                                  },
                                ),
                              ],
                            ),
                          )),
                    )
                );
              }
          )
      );
    }

  }

  PerolehanSuaraDPR(context){
    if(data.length < 0) {
      return Center(child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey),));
    }else{
      return showDialog(
          context: context,
          builder: (_) => StatefulBuilder(
              builder: (context, setState){
                return  new Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: EdgeInsets.all(10),
                    child: Center(
                      child:  Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15), color: Colors.white),
                          padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                          child: SingleChildScrollView(
                            physics: ScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Perolehan Suara Sementara",
                                    style: TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.start),
                                Text("Kategori DPR RI",
                                    style: TextStyle(fontSize: 14),
                                    textAlign: TextAlign.start),
                                ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  itemCount: data.length,
                                  itemBuilder: (_, index) {
                                    return getCardDpr(data[index], "dpr_ri");
                                  },
                                ),
                              ],
                            ),
                          )),
                    )
                );
              }
          )
      );
    }
  }

  void check_kategori(kategori,context){
    switch(kategori) {
      case "presiden" :
        load_data_kandidat_presiden();
        PerolehanSuaraPresiden(context);
        break;
      case "dpr_ri":
        load_data_calon_dpr();
        PerolehanSuaraDPR(context);
        break;
      case "dpd_ri" :
        print("dialog dpd");
        break;
      case "dprd_provinsi" :
        print("dialog dprd provinsi");
        break;
      case "dprd_kabupaten"  :
        print("dialog dprd kabupaten");
        break;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child:  ListView.builder(
            itemCount: list_kategori_suara.length,
            itemBuilder: (context,index){
              return getCard(list_kategori_suara[index], context);
            })
    );
  }

  Widget getCard(item,context){
    return GestureDetector(
      onTap: () => check_kategori(item['kategori'], context),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
