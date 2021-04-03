import 'package:hive/hive.dart';
part 'voteModel.g.dart';
@HiveType(typeId: 1)
class VoteModel {

  @HiveField(0)
  String TagID;

  @HiveField(1)
  String Id_kandidat;

  VoteModel({ this.TagID, this.Id_kandidat});


  @override
  String toString() {
    return '$TagID: $Id_kandidat';
  }
}