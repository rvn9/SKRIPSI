import 'package:hive/hive.dart';
part 'voteModel.g.dart';
@HiveType(typeId: 1)
class VoteModel {

  @HiveField(0)
  String TagID;

  @HiveField(1)
  String Id_calon;

  @HiveField(2)
  String Kategori;

  @HiveField(3)
  String Tipe;

  VoteModel({ this.TagID, this.Id_calon, this.Kategori, this.Tipe});

}