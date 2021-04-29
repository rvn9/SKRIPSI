import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'aturKandidat.dart';
import 'bacaVote.dart';
import 'listSuara.dart';

class AdminPage extends StatefulWidget {
  final _userData;
  AdminPage(this._userData);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {


  Future _openBox() async {
    await Hive.openBox('data_suara');
    return;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _openBox();
  }

  baca_kartu_suara (context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => BacaVote()));
  }

  atur_kandidat (context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AturKandidat()));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Admin Page",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            backgroundColor: Colors.white,
            bottom: TabBar(
              labelColor: Colors.black,
              indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 2.0, color: Colors.red),
                  insets: EdgeInsets.symmetric(horizontal:100.0)
              ),
              tabs: [
                Tab(
                  child: Text(
                    "Baca Kartu Suara",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ) ,
                ),
                Tab(
                  child: Text(
                    "Atur Kandidat",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ) ,
                ),
                Tab(
                  child: Text(
                    "List Suara",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ) ,
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              BacaVote(),
              AturKandidat(),
              ListSuara(widget._userData),
            ],
          ),
        ),
      ),
    );
  }
}
