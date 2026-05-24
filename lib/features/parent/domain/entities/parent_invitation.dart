enum InvitationStatus { pending, accepted, rejected, expired, unknown }

class ParentInvitation {
  const ParentInvitation({
    required this.id,
    required this.email,
    required this.status,
    required this.sentAt,
    this.fullName,
    this.relationship,
  });
  final String id;
  final String email;
  final InvitationStatus status;
  final DateTime sentAt;
  final String? fullName;
  final String? relationship;
}

class InviteParams {
  const InviteParams({
    required this.email,
    this.fullName,
    this.relationship,
  });
  final String email;
  final String? fullName;
  final String? relationship;
}
