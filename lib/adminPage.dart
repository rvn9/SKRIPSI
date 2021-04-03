import 'package:flutter/material.dart';
import 'package:skripsi/ListSuara.dart';

import 'AturKandidat.dart';
import 'BacaVote.dart';

class AdminPage extends StatefulWidget {
  final _userData;
  AdminPage(this._userData);

  @override
  _AdminPageState createState() => _AdminPageState();
}

baca_kartu_suara (context) async {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => BacaVote()));
}

atur_kandidat (context) async {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => AturKandidat()));
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
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
                  insets: EdgeInsets.symmetric(horizontal:65.0)
              ),
              tabs: [
                Tab(
                  child: Text(
                    "Baca Kartu Suara",
                  ) ,
                ),
                Tab(
                  child: Text(
                    "Atur Kandidat",
                  ) ,
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              BacaVote(),
              AturKandidat(),
              // ListSuara(),
            ],
          ),
        ),
      ),
    );
  }
}
