import 'dart:convert';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:skripsi/doneVoting.dart';




class VotingPage extends StatefulWidget {
  final userTagID;

  VotingPage(this.userTagID);

  @override
  _VotingPageState createState() => _VotingPageState();
}



class _VotingPageState extends State<VotingPage> {
  static MediaQueryData _mediaQueryData;
  List pasangan = [];
  bool isLoading = false;

  // load data kandidat //
  Future<void> load_data_kandidat() async {
    setState(() {
      isLoading = true;
    });
    String url = 'http://192.168.100.10:3000/endpoint/kandidat/get_all_kandidat';
    final response = await http.get(url);
    if(response.statusCode == 200){
      var users_json = jsonDecode(response.body);
      setState(() {
        pasangan = users_json;
        isLoading = false;
      });
    }else{
      pasangan = [];
      isLoading = false;
      throw Exception('Failed to load kandidat, silahkan coba lagi.');
    }
  }

  Future<void> _showMyDialog(tagID, _id, nomor_urut_pasangan) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Anda yakin memilih kandidat nomor pasangan ' + nomor_urut_pasangan + " ?"),
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
              onPressed: () {
                // send request ke server //
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => DoneVoting(tagID, _id,nomor_urut_pasangan)));
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
    this.load_data_kandidat();
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
                    Text("Berikan suara anda dengan cara menekan salah satu kandidat.",
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
    if(pasangan.length < 0 || isLoading){
      return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey),));
    }else{
      return ListView.builder(
          itemCount: pasangan.length,
          itemBuilder: (context,index){
            return getCard(pasangan[index]);
          });
    }

  }

  Widget getCard(item){
    // id pasangan //
    var id_pasangan = item['_id'];

    // nomor urut passangan //
    var nomor_urut_pasangan = item['Nomor_urut_pasangan'];

    // presiden //
    var nama_calon_presiden = item['Calon_presiden']['Nama'];
    var foto_calon_presiden = item['Calon_presiden']['Foto'];

    // wakil presiden //
    var nama_calon_wakil_presiden = item['Calon_wakil_presiden']['Nama'];
    var foto_calon_wakil_presiden = item['Calon_wakil_presiden']['Foto'];

    // partai pendukung nanti aja deh //


    return GestureDetector(
      onTap: () => _showMyDialog(widget.userTagID['TagID'],id_pasangan,nomor_urut_pasangan),
      child: Card(
        elevation: 1.5,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListTile(
            title: Row(
              children: <Widget>[
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(60/2),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(foto_calon_wakil_presiden)
                      )
                  ),
                ),
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

}

