/// Statut de validation d'une pièce d'identité.
enum TutorIdentityStatus { approved, pending, rejected, unknown }

/// Profil public du tuteur (`GET /tutors/profile`).
class TutorProfile {
  const TutorProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.city,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.bio,
    required this.completion,
    this.avatarUrl,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String city;
  final String category;
  final double rating;
  final int reviews;
  final String bio;

  /// Pourcentage de complétion du profil (0-100).
  final int completion;
  final String? avatarUrl;

  String get fullName => '$firstName $lastName';
}

/// Formation / diplôme (`/tutors/trainings`).
class TutorTraining {
  const TutorTraining({
    required this.id,
    required this.category,
    required this.level,
    required this.domain,
    required this.specialty,
    required this.date,
  });

  final String id;
  final String category;
  final String level;
  final String domain;
  final String specialty;
  final String date;
}

/// Expérience professionnelle (`/tutors/works`).
class TutorWork {
  const TutorWork({
    required this.id,
    required this.title,
    required this.company,
    required this.current,
    required this.since,
    this.until,
  });

  final String id;
  final String title;
  final String company;
  final bool current;
  final String since;
  final String? until;
}

/// Pièce d'identité (`/tutors/identities`).
class TutorIdentity {
  const TutorIdentity({
    required this.id,
    required this.type,
    required this.expires,
    required this.dob,
    required this.photoUrls,
    required this.status,
  });

  final String id;
  final String type;
  final String expires;
  final String dob;

  /// URLs absolues des photos du document (résolues depuis `image_urls`).
  final List<String> photoUrls;
  final TutorIdentityStatus status;

  int get photos => photoUrls.length;
}

/// Matières enseignées pour un niveau / une classe (`/tutors/tutoring_courses`).
class TutorTeachingCourse {
  const TutorTeachingCourse({
    required this.id,
    required this.classe,
    required this.subjects,
  });

  final String id;
  final String classe;
  final List<String> subjects;
}

/// Un créneau horaire (disponibilité hebdo).
class TutorTimeSlot {
  const TutorTimeSlot({required this.from, required this.to});
  final String from;
  final String to;
}

/// Disponibilité d'un jour de la semaine.
class TutorDayAvailability {
  const TutorDayAvailability({
    required this.dayKey,
    required this.label,
    required this.slots,
    this.recordId,
  });

  /// `mon`, `tue`, … (clé API).
  final String dayKey;

  /// `Lun`, `Mar`, … (libellé court UI).
  final String label;
  final List<TutorTimeSlot> slots;

  /// Identifiant de l'enregistrement `availability` du jour (`null` si aucune
  /// disponibilité). Sert à supprimer la disponibilité du jour.
  final String? recordId;

  bool get isAvailable => slots.isNotEmpty;
}
