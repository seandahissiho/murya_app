enum Diploma {
  // BTS CIEL - Option A
  btsCielOptionA,
  // BTS CIEL - Option B
  btsCielOptionB,
}

enum DiplomaYear {
  // Première année
  firstYear,
  // Deuxième année
  secondYear,
  // Troisième année
  thirdYear,
  // Quatrième année
  fourthYear,
  // Cinquième année
  fifthYear,
  // Sixième année
  sixthYear,
  // Septième année
  seventhYear,
  // Huitième année
  eighthYear,
}

enum DiplomaSchool {
  // Lycée Pilote Innovant International (LP2I)
  lp2i,
}

extension DiplomaExtension on Diploma {
  String get displayName {
    switch (this) {
      case Diploma.btsCielOptionA:
        return "BTS CIEL - Option A";
      case Diploma.btsCielOptionB:
        return "BTS CIEL - Option B";
    }
  }
}

extension DiplomaYearExtension on DiplomaYear {
  String get displayName {
    switch (this) {
      case DiplomaYear.firstYear:
        return "Première année";
      case DiplomaYear.secondYear:
        return "Deuxième année";
      case DiplomaYear.thirdYear:
        return "Troisième année";
      case DiplomaYear.fourthYear:
        return "Quatrième année";
      case DiplomaYear.fifthYear:
        return "Cinquième année";
      case DiplomaYear.sixthYear:
        return "Sixième année";
      case DiplomaYear.seventhYear:
        return "Septième année";
      case DiplomaYear.eighthYear:
        return "Huitième année";
    }
  }
}

extension DiplomaSchoolExtension on DiplomaSchool {
  String get displayName {
    switch (this) {
      case DiplomaSchool.lp2i:
        return "Lycée Pilote Innovant International (LP2I)";
    }
  }
}

Diploma? diplomaFromJson(dynamic value) {
  if (value == null) return null;
  if (value is Diploma) return value;
  final raw = value.toString();
  for (final entry in Diploma.values) {
    if (entry.name == raw || entry.displayName == raw) return entry;
  }
  return null;
}

DiplomaYear? diplomaYearFromJson(dynamic value) {
  if (value == null) return null;
  if (value is DiplomaYear) return value;
  final raw = value.toString();
  for (final entry in DiplomaYear.values) {
    if (entry.name == raw || entry.displayName == raw) return entry;
  }
  return null;
}

DiplomaSchool? diplomaSchoolFromJson(dynamic value) {
  if (value == null) return null;
  if (value is DiplomaSchool) return value;
  final raw = value.toString();
  for (final entry in DiplomaSchool.values) {
    if (entry.name == raw || entry.displayName == raw) return entry;
  }
  return null;
}
