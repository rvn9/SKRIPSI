import 'dart:convert';
import 'dart:developer';
import "package:http/http.dart" as http;
import 'package:flutter/material.dart';


class AturKandidat extends StatefulWidget {
  final nama_presiden_ctrl = TextEditingController();
  final nama_wakil_presiden_ctrl = TextEditingController();
  final nomor_urut_pasangan_ctrl = TextEditingController();
  final nama_parpol_ctrl = TextEditingController();


  @override
  _AturKandidatState createState() => _AturKandidatState();
}


class _AturKandidatState extends State<AturKandidat> {

  final _formKey = GlobalKey<FormState>();

  // presiden //
  String nama_presiden, nama_wakil_presiden, nomor_urut_pasangan;
  List temp_partai_pendukung = [];
  List partai_pendukung = [];

  // dpr //
  String nama_parpol;
  List calon_dpr = [];
  List temp_calon_dpr=[];


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

  void check_kategori(kategori,context){
    switch(kategori) {
      case "presiden" :
        addPresidenDialog(context);
        break;
      case "dpr_ri":
        addDprDialog(context);
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

  add_new_presiden(calonPresiden, calonWakilPresiden, nomorUrut, partaiPendukung) async{
    String url = 'http://192.168.100.218:3000/endpoint/presiden/add_new_kandidat';
    final response = await http.post(url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'Nomor_urut_pasangan': nomorUrut.toString(),
        'Calon_presiden' : calonPresiden,
        'Calon_wakil_presiden' : calonWakilPresiden,
        'Partai_pendukung' : partaiPendukung
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

  add_new_dpr(namaParpol, calonAnggotaDPR ) async{
    List data = [];
    calonAnggotaDPR.forEach((value) {
      var temp_data = {
        "Nama_calon" : value
      };
      data.add(temp_data);
    });

    String url = 'http://192.168.100.218:3000/endpoint/dpr/add_new';
    final response = await http.post(url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'Parpol': namaParpol,
        'Data': data,
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

  void validateDataPresiden(context){
    if (_formKey.currentState.validate()) {
      nama_presiden = widget.nama_presiden_ctrl.text;
      nama_wakil_presiden = widget.nama_wakil_presiden_ctrl.text;
      nomor_urut_pasangan = widget.nomor_urut_pasangan_ctrl.text;
      temp_partai_pendukung = [];
      partai_pendukung.forEach((widget) => temp_partai_pendukung.add(widget.partai_pendukung_ctrl.text));
      add_new_presiden(nama_presiden,nama_wakil_presiden,nomor_urut_pasangan,temp_partai_pendukung);

      Navigator.pop(context);

    }
  }

  void validateDataDpr(context){
    if (_formKey.currentState.validate()) {
      nama_parpol = widget.nama_parpol_ctrl.text;
      temp_calon_dpr = [];
      calon_dpr.forEach((widget) => temp_calon_dpr.add(widget.anggota_dpr_ctrl.text));

      add_new_dpr(nama_parpol, temp_calon_dpr);
      Navigator.pop(context);

    }
  }

  void addPresidenDialog(context) {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
          builder: (context, setState){
            return  new Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(10),
              child: Form(
                key: _formKey,
                child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15), color: Colors.white),
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                    child: SingleChildScrollView(
                      physics: ScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Tambah Kandidat Presiden",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.start),
                          Text("Masukan data-data kandidat baru",
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.start),
                          Divider(
                            color: Colors.transparent,
                          ),
                          TextFormField(
                            controller: widget.nomor_urut_pasangan_ctrl,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(34, 34, 34, 1),
                            ),
                            decoration: InputDecoration(
                              labelText: "nomor urut pasangan",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Nomor urut pasangan tidak boleh kosong.";
                              }
                              return null;
                            },
                          ),
                          Divider(
                            color: Colors.transparent,
                          ),
                          TextFormField(
                            controller: widget.nama_presiden_ctrl,
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(34, 34, 34, 1),
                            ),
                            decoration: InputDecoration(
                              labelText: "nama presiden",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Nama presiden tidak boleh kosong";
                              }
                              return null;
                            },
                          ),
                          Divider(
                            color: Colors.transparent,
                          ),
                          TextFormField(
                            controller: widget.nama_wakil_presiden_ctrl,
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(34, 34, 34, 1),
                            ),
                            decoration: InputDecoration(
                              labelText: "Nama calon wakil presiden",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Nama calon wakil presiden tidak boleh kosong";
                              }
                              return null;
                            },
                          ),
                          ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            itemCount: partai_pendukung.length,
                            itemBuilder: (_, index) => partai_pendukung[index],
                          ),
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  partai_pendukung.add(new DynamicWidget());
                                });
                              },
                              style: TextButton.styleFrom(
                                primary: Colors.blue,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.add),
                                  Text("Tambah partai pendukung")
                                ],
                              )
                          ),
                          Divider(
                            color: Colors.transparent,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child:   ElevatedButton(
                              child: Text('Simpan'),
                              onPressed: () {
                                validateDataPresiden(context);
                              },
                            ),
                          )

                        ],
                      ),
                    )),
              ),
            );
          }
      )
    );
  }

  void addDprDialog(context){
    showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
            builder: (context, setState){
              return  new Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.all(10),
                child: Form(
                  key: _formKey,
                  child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15), color: Colors.white),
                      padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                      child: SingleChildScrollView(
                        physics: ScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Tambah Kandidat Dpr",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start),
                            Text("Masukan data-data kandidat baru",
                                style: TextStyle(fontSize: 14),
                                textAlign: TextAlign.start),
                            Divider(
                              color: Colors.transparent,
                            ),
                            TextFormField(
                              controller: widget.nama_parpol_ctrl,
                              keyboardType: TextInputType.text,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(34, 34, 34, 1),
                              ),
                              decoration: InputDecoration(
                                labelText: "nama partai politik",
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Nama partai politik tidak boleh kosong";
                                }
                                return null;
                              },
                            ),
                            ListView.builder(
                              primary: false,
                              shrinkWrap: true,
                              itemCount: calon_dpr.length,
                              itemBuilder: (_, index) => calon_dpr[index],
                            ),
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    calon_dpr.add(new DprWidget());
                                  });
                                },
                                style: TextButton.styleFrom(
                                  primary: Colors.blue,
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.add),
                                    Text("Tambah calon dpr")
                                  ],
                                )
                            ),
                            Divider(
                              color: Colors.transparent,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child:   ElevatedButton(
                                child: Text('Simpan'),
                                onPressed: () {
                                  validateDataDpr(context);
                                },
                              ),
                            )

                          ],
                        ),
                      )),
                ),
              );
            }
        )
    );
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

class DprWidget extends StatelessWidget {
  final anggota_dpr_ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          color: Colors.transparent,
        ),
        TextFormField(
          controller:anggota_dpr_ctrl,
          keyboardType: TextInputType.text,
          style: TextStyle(
            fontSize: 16,
            color: Color.fromRGBO(34, 34, 34, 1),
          ),
          decoration: InputDecoration(
            labelText: "nama calon anggota DPR",
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value.isEmpty) {
              return "Nama calon anggota DPR tidak boleh kosong";
            }
            return null;
          },
        ),
      ],
    );
  }
}


class DynamicWidget extends StatelessWidget {
  final partai_pendukung_ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          color: Colors.transparent,
        ),
        TextFormField(
          controller:partai_pendukung_ctrl,
          keyboardType: TextInputType.text,
          style: TextStyle(
            fontSize: 16,
            color: Color.fromRGBO(34, 34, 34, 1),
          ),
          decoration: InputDecoration(
            labelText: "partai pendukung",
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value.isEmpty) {
              return "Nama partai pendukung tidak boleh kosong";
            }
            return null;
          },
        ),
      ],
    );
  }
}
