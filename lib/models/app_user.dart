import 'package:murya/config/custom_classes.dart';

class User {
  final String? id;
  final String? email;
  final String? phone;
  final String? deviceId;

  final String? photoURL;
  final String? firstName;
  final String? lastName;

  final int diamonds;

  static const User zero = User(id: '', email: '', phone: '', deviceId: '', firstName: '', lastName: '');

  const User({
    this.id,
    this.email,
    this.phone,
    this.deviceId,
    this.photoURL,
    this.firstName,
    this.lastName,
    this.diamonds = 0,
  });

  String get fullName {
    return '$firstName $lastName';
  }

  String get name {
    return fullName.isNotEmpty ? fullName : email?.split('@').first ?? 'N/A';
  }

  String get initials {
    return '${firstName.isNotEmptyOrNull ? firstName![0].toUpperCase() : ''}${lastName.isNotEmptyOrNull ? lastName![0].toUpperCase() : ''}';
  }

  String get displayName {
    return fullName.isNotEmpty ? fullName : email?.split('@').first ?? 'N/A';
  }

  String get displayPhoneNumber {
    return phone.isNotEmptyOrNull ? phone! : 'N/A';
  }

  String get displayEmail {
    return email.isNotEmptyOrNull ? email! : 'N/A';
  }

  String get displayPhotoURL {
    return photoURL ?? 'https://example.com/default-avatar.png'; // Default avatar URL
  }

  @override
  String toString() {
    return 'AppUser{id: $id, email: $email, photoURL: $photoURL, firstName: $firstName, lastName: $lastName, phone: $phone}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final User otherUser = other as User;
    return id == otherUser.id &&
        email == otherUser.email &&
        photoURL == otherUser.photoURL &&
        firstName == otherUser.firstName &&
        lastName == otherUser.lastName &&
        phone == otherUser.phone &&
        diamonds == otherUser.diamonds;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        (photoURL?.hashCode ?? 0) ^
        firstName.hashCode ^
        lastName.hashCode ^
        phone.hashCode ^
        diamonds.hashCode;
  }

  static User empty() {
    return const User(
      id: '',
      email: '',
      photoURL: null,
      firstName: '',
      lastName: '',
      phone: '',
      deviceId: '',
      diamonds: 0,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final String? id = json['id'];
    final String? email = json['email'];
    final String? phone = json['phone'];
    final String? deviceId = json['deviceId'];
    final String? photoURL = json['avatarURL'];
    final String? firstName = json['firstname'];
    final String? lastName = json['lastname'];
    final int diamonds = json['diamonds'] ?? 0;

    return User(
      id: id,
      email: email,
      phone: phone,
      deviceId: deviceId,
      photoURL: photoURL,
      firstName: firstName,
      lastName: lastName,
      diamonds: diamonds,
    );
  }

  get isNotEmpty => id.isNotEmptyOrNull;

  get isRegistered =>
      (email.isNotEmptyOrNull || phone.isNotEmptyOrNull || deviceId.isNotEmptyOrNull) && id.isNotEmptyOrNull;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'photoURL': photoURL,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'deviceId': deviceId,
      'diamonds': diamonds,
    };
  }
}

//         firstName: 'Sébastien',
//         lastName: 'Biney',
//         diamonds: 3750,
//         questionsAnswered: 20,
//         performance: 75,
//         sinceDate: DateTime(2025, 12, 3),
class LeaderBoardUser {
  final String id;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;
  final int diamonds;
  final int questionsAnswered;
  final double performance;
  final DateTime? sinceDate;
  final int rank;
  final double percentage;
  final int completedQuizzes;
  final DateTime? lastQuizAt;

  LeaderBoardUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePictureUrl,
    required this.diamonds,
    required this.questionsAnswered,
    required this.performance,
    this.sinceDate,
    required this.rank,
    required this.percentage,
    required this.completedQuizzes,
    this.lastQuizAt,
  });

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  // fromJson factory
  factory LeaderBoardUser.fromJson(Map<String, dynamic> json) {
    final String firstName = (json['firstName'] ?? json['firstname'] ?? '').toString();
    final String lastName = (json['lastName'] ?? json['lastname'] ?? '').toString();
    final double performance = _toDouble(json['performance']);
    final double percentage = json['percentage'] != null ? _toDouble(json['percentage']) : performance * 100;
    return LeaderBoardUser(
      id: (json['id'] ?? json['userId'] ?? '').toString(),
      firstName: firstName,
      lastName: lastName,
      profilePictureUrl: json['profilePictureUrl']?.toString() ?? json['avatarURL']?.toString(),
      diamonds: _toInt(json['diamonds']),
      questionsAnswered: _toInt(json['questionsAnswered']),
      performance: performance,
      sinceDate: json['sinceDate'] != null ? DateTime.parse(json['sinceDate'] as String) : null,
      rank: _toInt(json['rank']),
      percentage: percentage,
      completedQuizzes: _toInt(json['completedQuizzes']),
      lastQuizAt: json['lastQuizAt'] != null ? DateTime.parse(json['lastQuizAt'] as String) : null,
    );
  }
}
