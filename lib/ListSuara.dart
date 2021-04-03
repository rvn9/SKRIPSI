// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:skripsi/models/voteModel.dart';
//
// class ListSuara extends StatelessWidget {
//
//   var data_suara_box =  Hive.openBox('data_suara');
//   @override
//   Widget build(BuildContext context) {
//     return WatchBoxBuilder(
//         box: data_suara_box,
//         builder: (context, data_suara_box){
//           return ListView.builder(
//               itemCount: data_suara_box.length,
//               itemBuilder: (context, index){
//                 final data_suara = data_suara_box.getAt(index) as VoteModel;
//                 print(data_suara.TagID);
//               }
//           );
//         }
//     );
//   }
// }
