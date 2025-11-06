class User {
  final String id;
  final String email;
  final String? photoURL;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  static const User zero = User(
    id: '',
    email: '',
    photoURL: null,
    firstName: '',
    lastName: '',
    phoneNumber: '',
  );

  const User({
    required this.id,
    required this.email,
    this.photoURL,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });

  String get fullName {
    return '$firstName $lastName';
  }

  String get name {
    return fullName.isNotEmpty ? fullName : email.split('@').first;
  }

  String get initials {
    return '${firstName.isNotEmpty ? firstName[0].toUpperCase() : ''}${lastName.isNotEmpty ? lastName[0].toUpperCase() : ''}';
  }

  String get displayName {
    return fullName.isNotEmpty ? fullName : email.split('@').first;
  }

  String get displayPhoneNumber {
    return phoneNumber.isNotEmpty ? phoneNumber : 'N/A';
  }

  String get displayEmail {
    return email.isNotEmpty ? email : 'N/A';
  }

  String get displayPhotoURL {
    return photoURL ?? 'https://example.com/default-avatar.png'; // Default avatar URL
  }

  @override
  String toString() {
    return 'AppUser{id: $id, email: $email, photoURL: $photoURL, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber}';
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
        phoneNumber == otherUser.phoneNumber;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        (photoURL?.hashCode ?? 0) ^
        firstName.hashCode ^
        lastName.hashCode ^
        phoneNumber.hashCode;
  }

  static User empty() {
    return const User(
      id: '',
      email: '',
      photoURL: null,
      firstName: '',
      lastName: '',
      phoneNumber: '',
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final String id = json['id'] as String;
    final String email = json['email'] as String;
    final String? photoURL = json['avatarURL'] as String?;
    final String firstName = json['firstname'] as String;
    final String lastName = json['lastname'] as String;
    final String phoneNumber = json['phone'] as String;

    return User(
      id: id,
      email: email,
      photoURL: photoURL,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'photoURL': photoURL,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
    };
  }
}
