import 'package:flutter/src/widgets/framework.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/models/diploma.dart';

class User {
  final String? id;
  final String? email;
  final String? phone;
  final String? deviceId;

  final String? avatarUrl;
  final String? firstName;
  final String? lastName;
  final DateTime? birthDate;
  final String? genre;
  final String? preferredLangCode;
  final Diploma? diploma;
  final DiplomaYear? diplomaYear;
  final DiplomaSchool? diplomaSchool;

  final int diamonds;
  final int streakDays;

  static const User zero = User(id: '', email: '', phone: '', deviceId: '', firstName: '', lastName: '');

  const User({
    this.id,
    this.email,
    this.phone,
    this.deviceId,
    this.avatarUrl,
    this.firstName,
    this.lastName,
    this.birthDate,
    this.genre,
    this.preferredLangCode,
    this.diploma,
    this.diplomaYear,
    this.diplomaSchool,
    this.diamonds = 0,
    this.streakDays = 0,
  });

  String get profilePictureUrl {
    return avatarUrl ?? '';
  }

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
    return avatarUrl ?? 'https://example.com/default-avatar.png'; // Default avatar URL
  }

  String? get photoURL => avatarUrl;

  @override
  String toString() {
    return 'AppUser{id: $id, email: $email, avatarUrl: $avatarUrl, firstName: $firstName, lastName: $lastName, phone: $phone, birthDate: $birthDate, genre: $genre, preferredLangCode: $preferredLangCode, diploma: $diploma, diplomaYear: $diplomaYear, diplomaSchool: $diplomaSchool, streakDays: $streakDays}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final User otherUser = other as User;
    return id == otherUser.id &&
        email == otherUser.email &&
        avatarUrl == otherUser.avatarUrl &&
        firstName == otherUser.firstName &&
        lastName == otherUser.lastName &&
        birthDate == otherUser.birthDate &&
        genre == otherUser.genre &&
        preferredLangCode == otherUser.preferredLangCode &&
        diploma == otherUser.diploma &&
        diplomaYear == otherUser.diplomaYear &&
        diplomaSchool == otherUser.diplomaSchool &&
        phone == otherUser.phone &&
        diamonds == otherUser.diamonds &&
        streakDays == otherUser.streakDays;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        (avatarUrl?.hashCode ?? 0) ^
        firstName.hashCode ^
        lastName.hashCode ^
        birthDate.hashCode ^
        genre.hashCode ^
        preferredLangCode.hashCode ^
        diploma.hashCode ^
        diplomaYear.hashCode ^
        diplomaSchool.hashCode ^
        phone.hashCode ^
        diamonds.hashCode ^
        streakDays.hashCode;
  }

  static User empty() {
    return const User(
      id: '',
      email: '',
      avatarUrl: null,
      firstName: '',
      lastName: '',
      birthDate: null,
      genre: null,
      preferredLangCode: null,
      diploma: null,
      diplomaYear: null,
      diplomaSchool: null,
      phone: '',
      deviceId: '',
      diamonds: 0,
      streakDays: 0,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final String? id = json['id'];
    final String? email = json['email'];
    final String? phone = json['phone'];
    final String? deviceId = json['deviceId'];
    final String? avatarUrl =
        (json['avatarUrl'] ?? json['avatarURL'] ?? json['photoURL'] ?? json['photoUrl']) as String?;
    final String? firstName = (json['firstname'] ?? json['firstName']) as String?;
    final String? lastName = (json['lastname'] ?? json['lastName']) as String?;
    final int diamonds = json['diamonds'] ?? 0;
    final Diploma? diploma = diplomaFromJson(json['diploma']);
    final DiplomaYear? diplomaYear = diplomaYearFromJson(json['diplomaYear']);
    final DiplomaSchool? diplomaSchool = diplomaSchoolFromJson(json['diplomaSchool']);
    final int streakDays = _toInt(json['streakDays'] ?? json['streak']);
    final DateTime? birthDate = _toDate(json['birthDate']);
    final String? genre = json['genre'] as String?;
    final String? preferredLangCode = json['preferredLangCode'] as String?;

    return User(
      id: id,
      email: email,
      phone: phone,
      deviceId: deviceId,
      avatarUrl: avatarUrl,
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
      genre: genre,
      preferredLangCode: preferredLangCode,
      diploma: diploma,
      diplomaYear: diplomaYear,
      diplomaSchool: diplomaSchool,
      diamonds: diamonds,
      streakDays: streakDays,
    );
  }

  get isNotEmpty => id.isNotEmptyOrNull;

  get isRegistered =>
      (email.isNotEmptyOrNull || phone.isNotEmptyOrNull || deviceId.isNotEmptyOrNull) && id.isNotEmptyOrNull;

  Map<String, dynamic> toJson({User? baseline}) {
    final Map<String, dynamic> data = {};

    void setField(String key, dynamic value, dynamic baselineValue) {
      if (baseline != null) {
        if (value != baselineValue) {
          data[key] = value;
        }
        return;
      }
      if (value != null) {
        data[key] = value;
      }
    }

    final String? birthDateValue = birthDate != null ? _formatDate(birthDate!) : null;
    final String? birthDateBaseline = baseline?.birthDate != null ? _formatDate(baseline!.birthDate!) : null;

    setField('firstname', firstName, baseline?.firstName);
    setField('lastname', lastName, baseline?.lastName);
    setField('email', email, baseline?.email);
    setField('phone', phone, baseline?.phone);
    setField('avatarUrl', avatarUrl, baseline?.avatarUrl);
    setField('birthDate', birthDateValue, birthDateBaseline);
    setField('genre', genre, baseline?.genre);
    setField('preferredLangCode', preferredLangCode, baseline?.preferredLangCode);

    return data;
  }

  String contextName(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final String first = firstName ?? locale.user_firstName_placeholder;
    final String last = lastName ?? locale.user_lastName_placeholder;
    return '$first $last';
  }

  User copyWith({
    String? id,
    String? email,
    String? phone,
    String? deviceId,
    String? avatarUrl,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? genre,
    String? preferredLangCode,
    Diploma? diploma,
    DiplomaYear? diplomaYear,
    DiplomaSchool? diplomaSchool,
    int? diamonds,
    int? streakDays,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      deviceId: deviceId ?? this.deviceId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      genre: genre ?? this.genre,
      preferredLangCode: preferredLangCode ?? this.preferredLangCode,
      diploma: diploma ?? this.diploma,
      diplomaYear: diplomaYear ?? this.diplomaYear,
      diplomaSchool: diplomaSchool ?? this.diplomaSchool,
      diamonds: diamonds ?? this.diamonds,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
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
  final String? userJobId;
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
    this.userJobId,
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
      userJobId: json['userJobId']?.toString(),
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
