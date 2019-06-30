// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonModelGenerator
// **************************************************************************

@generatedSerializable
class User extends _User {
  User(
      {this.id,
      this.googleId,
      this.name,
      this.avatarUrl,
      this.createdAt,
      this.updatedAt});

  @override
  final String id;

  @override
  final String googleId;

  @override
  final String name;

  @override
  final String avatarUrl;

  @override
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  User copyWith(
      {String id,
      String googleId,
      String name,
      String avatarUrl,
      DateTime createdAt,
      DateTime updatedAt}) {
    return new User(
        id: id ?? this.id,
        googleId: googleId ?? this.googleId,
        name: name ?? this.name,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt);
  }

  bool operator ==(other) {
    return other is _User &&
        other.id == id &&
        other.googleId == googleId &&
        other.name == name &&
        other.avatarUrl == avatarUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return hashObjects([id, googleId, name, avatarUrl, createdAt, updatedAt]);
  }

  @override
  String toString() {
    return "User(id=$id, googleId=$googleId, name=$name, avatarUrl=$avatarUrl, createdAt=$createdAt, updatedAt=$updatedAt)";
  }

  Map<String, dynamic> toJson() {
    return UserSerializer.toMap(this);
  }
}

// **************************************************************************
// SerializerGenerator
// **************************************************************************

const UserSerializer userSerializer = const UserSerializer();

class UserEncoder extends Converter<User, Map> {
  const UserEncoder();

  @override
  Map convert(User model) => UserSerializer.toMap(model);
}

class UserDecoder extends Converter<Map, User> {
  const UserDecoder();

  @override
  User convert(Map map) => UserSerializer.fromMap(map);
}

class UserSerializer extends Codec<User, Map> {
  const UserSerializer();

  @override
  get encoder => const UserEncoder();
  @override
  get decoder => const UserDecoder();
  static User fromMap(Map map) {
    return new User(
        id: map['id'] as String,
        googleId: map['google_id'] as String,
        name: map['name'] as String,
        avatarUrl: map['avatar_url'] as String,
        createdAt: map['created_at'] != null
            ? (map['created_at'] is DateTime
                ? (map['created_at'] as DateTime)
                : DateTime.parse(map['created_at'].toString()))
            : null,
        updatedAt: map['updated_at'] != null
            ? (map['updated_at'] is DateTime
                ? (map['updated_at'] as DateTime)
                : DateTime.parse(map['updated_at'].toString()))
            : null);
  }

  static Map<String, dynamic> toMap(_User model) {
    if (model == null) {
      return null;
    }
    return {
      'id': model.id,
      'google_id': model.googleId,
      'name': model.name,
      'avatar_url': model.avatarUrl,
      'created_at': model.createdAt?.toIso8601String(),
      'updated_at': model.updatedAt?.toIso8601String()
    };
  }
}

abstract class UserFields {
  static const List<String> allFields = <String>[
    id,
    googleId,
    name,
    avatarUrl,
    createdAt,
    updatedAt
  ];

  static const String id = 'id';

  static const String googleId = 'google_id';

  static const String name = 'name';

  static const String avatarUrl = 'avatar_url';

  static const String createdAt = 'created_at';

  static const String updatedAt = 'updated_at';
}
