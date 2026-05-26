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

/// CDC §11.5 : link_with_children ∈ { father, mother, guardian }.
enum InvitationLink { father, mother, guardian }

/// CDC §11.5 : civility ∈ { Mr, Mme }.
class InviteParams {
  const InviteParams({
    required this.email,
    required this.civility,
    required this.firstName,
    required this.lastName,
    required this.linkWithChildren,
    this.lang = 'fr',
  });
  final String email;
  final String civility; // 'Mr' | 'Mme'
  final String firstName;
  final String lastName;
  final InvitationLink linkWithChildren;
  final String lang; // 'fr' | 'en'
}
