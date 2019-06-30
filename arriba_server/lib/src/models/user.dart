import 'package:angel_serialize/angel_serialize.dart';
part 'user.g.dart';

@serializable
abstract class _User extends Model {
  String get googleId;

  String get name;

  String get avatarUrl;
}
