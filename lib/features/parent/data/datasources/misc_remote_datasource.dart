import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/contract.dart';
import '../../domain/entities/parent_invitation.dart';
import '../../domain/entities/parent_program.dart';
import '../../domain/entities/parent_review.dart';

class MiscRemoteDatasource {
  const MiscRemoteDatasource(this._dio);
  final Dio _dio;

  // ── Reviews ────────────────────────────────────────────
  Future<List<ParentReview>> listReviews() async {
    final r = await _dio.get<Map<String, dynamic>>(ApiEndpoints.parentsReviews);
    final list = (r.data!['data'] as List?) ?? const [];
    return list.cast<Map<String, dynamic>>().map(_parseReview).toList();
  }

  Future<ParentReview> createReview(ReviewParams p) async {
    final r = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.parentsReviews,
      data: {
        'review': {
          'tutor_id': p.tutorId,
          'score': p.score,
          'comment': p.comment,
          if (p.subject != null) 'subject': p.subject,
        },
      },
    );
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return _parseReview(data);
  }

  static ParentReview _parseReview(Map<String, dynamic> j) => ParentReview(
        id: j['id']?.toString() ?? '',
        tutorId: j['tutor_id']?.toString() ?? '',
        tutorName: j['tutor_name']?.toString() ?? '—',
        subject: j['subject']?.toString() ?? '',
        score: (j['score'] as num?)?.toInt() ?? 0,
        comment: j['comment']?.toString() ?? '',
        createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '') ??
            DateTime.now(),
      );

  // ── Programs ───────────────────────────────────────────
  Future<List<ParentProgram>> listPrograms() async {
    final r = await _dio.get<Map<String, dynamic>>('/parents/programs');
    final list = (r.data!['data'] as List?) ?? const [];
    return list.cast<Map<String, dynamic>>().map(_parseProgram).toList();
  }

  static ParentProgram _parseProgram(Map<String, dynamic> j) => ParentProgram(
        id: j['id']?.toString() ?? '',
        title: j['title']?.toString() ?? '—',
        subject: j['subject']?.toString() ?? '',
        level: j['level']?.toString() ?? '',
        progress: (j['progress'] as num?)?.toDouble() ?? 0.0,
        description: j['description']?.toString(),
        modules: ((j['modules'] as List?) ?? const [])
            .cast<Map<String, dynamic>>()
            .map((m) => ProgramModule(
                  id: m['id']?.toString() ?? '',
                  title: m['title']?.toString() ?? '',
                  progress: (m['progress'] as num?)?.toDouble() ?? 0.0,
                ))
            .toList(),
      );

  // ── Invitations ────────────────────────────────────────
  Future<List<ParentInvitation>> listInvitations() async {
    final r = await _dio.get<Map<String, dynamic>>('/parents/invitations');
    final list = (r.data!['data'] as List?) ?? const [];
    return list.cast<Map<String, dynamic>>().map(_parseInvitation).toList();
  }

  Future<ParentInvitation> invite(InviteParams p) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/parents/invitations',
      data: {
        'invitation': {
          'email': p.email,
          if (p.fullName != null) 'full_name': p.fullName,
          if (p.relationship != null) 'relationship': p.relationship,
        },
      },
    );
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return _parseInvitation(data);
  }

  static ParentInvitation _parseInvitation(Map<String, dynamic> j) =>
      ParentInvitation(
        id: j['id']?.toString() ?? '',
        email: j['email']?.toString() ?? '',
        status: switch (j['status']?.toString()) {
          'pending' => InvitationStatus.pending,
          'accepted' => InvitationStatus.accepted,
          'rejected' => InvitationStatus.rejected,
          'expired' => InvitationStatus.expired,
          _ => InvitationStatus.unknown,
        },
        sentAt: DateTime.tryParse(j['sent_at']?.toString() ?? '') ??
            DateTime.now(),
        fullName: j['full_name']?.toString(),
        relationship: j['relationship']?.toString(),
      );

  // ── Contracts ──────────────────────────────────────────
  Future<List<Contract>> listContracts() async {
    final r = await _dio.get<Map<String, dynamic>>(ApiEndpoints.contracts);
    final list = (r.data!['data'] as List?) ?? const [];
    return list.cast<Map<String, dynamic>>().map(_parseContract).toList();
  }

  Future<Contract> signContract(String id) async {
    final r = await _dio.post<Map<String, dynamic>>(
        '${ApiEndpoints.contracts}/$id/sign');
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return _parseContract(data);
  }

  static Contract _parseContract(Map<String, dynamic> j) => Contract(
        id: j['id']?.toString() ?? '',
        title: j['title']?.toString() ?? 'Contrat',
        status: switch (j['status']?.toString()) {
          'signed' => ContractStatus.signed,
          'unsigned' => ContractStatus.unsigned,
          'expired' => ContractStatus.expired,
          'terminated' => ContractStatus.terminated,
          _ => ContractStatus.unknown,
        },
        createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '') ??
            DateTime.now(),
        tutorName: j['tutor_name']?.toString(),
        childName: j['child_name']?.toString(),
        amount: (j['amount'] as num?)?.toInt(),
        pdfUrl: j['pdf_url']?.toString(),
        signedAt: DateTime.tryParse(j['signed_at']?.toString() ?? ''),
      );
}
