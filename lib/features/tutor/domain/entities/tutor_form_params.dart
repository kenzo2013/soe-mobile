import 'dart:io';

/// Paramètres des actions d'écriture du flux tuteur (domain — sans dépendance
/// réseau ; la sérialisation se fait dans la couche data).

class TutorTrainingParams {
  const TutorTrainingParams({
    required this.category,
    required this.level,
    required this.domain,
    required this.specialty,
    required this.date,
  });
  final String category;
  final String level;
  final String domain;
  final String specialty;
  final String date;
}

class TutorWorkParams {
  const TutorWorkParams({
    required this.title,
    required this.company,
    required this.current,
    this.since,
    this.until,
  });
  final String title;
  final String company;
  final bool current;
  final String? since;
  final String? until;
}

class TutorIdentityParams {
  const TutorIdentityParams({
    required this.documentType,
    required this.birthday,
    required this.expirationDate,
    required this.images,
  });
  final String documentType;
  final String birthday;
  final String expirationDate;
  final List<File> images;
}

class TutorTeachingCourseParams {
  const TutorTeachingCourseParams({
    required this.schoolClassId,
    required this.subjectIds,
  });
  final String schoolClassId;
  final List<String> subjectIds;
}

class TutorAvailabilityParams {
  const TutorAvailabilityParams({
    required this.weekday,
    required this.startTime,
    required this.endTime,
  });
  final int weekday;
  final String startTime;
  final String endTime;
}

class TutorSessionEditParams {
  const TutorSessionEditParams({this.startAt, this.endAt, this.note});
  final String? startAt;
  final String? endAt;
  final String? note;
}

class TutorSessionReportParams {
  const TutorSessionReportParams({
    required this.date,
    required this.startAt,
    required this.endAt,
    required this.proceedings,
    required this.signature,
  });
  final String date;
  final String startAt;
  final String endAt;
  final String proceedings;
  final File signature;
}

enum TutorMobileOperator { mtn, orange }

class TutorMobilePaymentParams {
  const TutorMobilePaymentParams({
    required this.phone,
    required this.operator,
  });
  final String phone;
  final TutorMobileOperator operator;
}

class TutorBankPaymentParams {
  const TutorBankPaymentParams({
    required this.accountHolder,
    required this.bankName,
    required this.iban,
    required this.bic,
    this.accountNumber = '',
    this.key = '',
    this.bankCode = '',
    this.agencyCode = '',
  });
  final String accountHolder;
  final String bankName;
  final String iban;
  final String bic;
  final String accountNumber;
  final String key;
  final String bankCode;
  final String agencyCode;
}
