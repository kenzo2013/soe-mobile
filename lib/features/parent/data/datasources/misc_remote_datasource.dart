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
          'rating': p.rating,
          'comment': p.comment,
          if (p.subjectIds.isNotEmpty) 'subject_ids': p.subjectIds,
        },
      },
    );
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return _parseReview(data);
  }

  // CDC §11.5 : rating = entier 1..5.
  static ParentReview _parseReview(Map<String, dynamic> j) {
    final a = _attrs(j);
    return ParentReview(
      id: j['id']?.toString() ?? '',
      tutorId: a['tutor_id']?.toString() ?? '',
      tutorName: a['tutor_name']?.toString() ?? '—',
      rating: (a['rating'] as num?)?.toInt() ?? 0,
      comment: a['comment']?.toString() ?? '',
      createdAt: DateTime.tryParse(a['created_at']?.toString() ?? '') ??
          DateTime.now(),
      subjects: ((a['subjects'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  // ── Programs ───────────────────────────────────────────
  Future<List<ParentProgram>> listPrograms() async {
    final r = await _dio.get<Map<String, dynamic>>('/parents/proposed_programs');
    final list = (r.data!['data'] as List?) ?? const [];
    return list.cast<Map<String, dynamic>>().map(_parseProgram).toList();
  }

  static ParentProgram _parseProgram(Map<String, dynamic> j) {
    final a = _attrs(j);
    return ParentProgram(
      id: j['id']?.toString() ?? '',
      title: a['title']?.toString() ?? '—',
      subject: a['subject']?.toString() ?? '',
      level: a['level']?.toString() ?? '',
      progress: (a['progress'] as num?)?.toDouble() ?? 0.0,
      description: a['description']?.toString(),
      modules: ((a['modules'] as List?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map((m) {
        final ma = _attrs(m);
        return ProgramModule(
          id: m['id']?.toString() ?? '',
          title: ma['title']?.toString() ?? '',
          progress: (ma['progress'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList(),
    );
  }

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
          'civility': p.civility,
          'first_name': p.firstName,
          'last_name': p.lastName,
          'phone': p.phone,
          'link_with_children': switch (p.linkWithChildren) {
            InvitationLink.father => 'father',
            InvitationLink.mother => 'mother',
            InvitationLink.guardian => 'guardian',
          },
          'lang': p.lang,
        },
      },
    );
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return _parseInvitation(data);
  }

  static ParentInvitation _parseInvitation(Map<String, dynamic> j) {
    final a = _attrs(j);
    final firstName = a['first_name']?.toString();
    final lastName = a['last_name']?.toString();
    final fullName = [firstName, lastName]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .join(' ');
    return ParentInvitation(
      id: j['id']?.toString() ?? '',
      email: a['email']?.toString() ?? '',
      status: switch (a['status']?.toString()) {
        'pending' => InvitationStatus.pending,
        'accepted' => InvitationStatus.accepted,
        'rejected' => InvitationStatus.rejected,
        'expired' => InvitationStatus.expired,
        _ => InvitationStatus.unknown,
      },
      sentAt: DateTime.tryParse(
              (a['sent_at'] ?? a['created_at'])?.toString() ?? '') ??
          DateTime.now(),
      fullName: fullName.isEmpty ? null : fullName,
      relationship: a['link_with_children']?.toString(),
      phone: a['phone']?.toString(),
    );
  }

  // ── Contracts ──────────────────────────────────────────
  Future<List<Contract>> listContracts() async {
    final r = await _dio.get<Map<String, dynamic>>(ApiEndpoints.contracts);
    final list = (r.data!['data'] as List?) ?? const [];
    return list.cast<Map<String, dynamic>>().map(_parseContract).toList();
  }

  /// CDC §4.8 : la signature se fait en PATCH /common/contracts/:id avec
  /// un fichier signature en multipart/form-data (`contract[signature]`).
  /// `signatureBytes` est l'export PNG du canvas tactile.
  Future<Contract> signContract(String id, List<int> signatureBytes) async {
    final formData = FormData.fromMap({
      'contract[signature]': MultipartFile.fromBytes(
        signatureBytes,
        filename: 'signature.png',
      ),
    });
    final r = await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.contracts}/$id',
      data: formData,
    );
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return _parseContract(data);
  }

  static Contract _parseContract(Map<String, dynamic> j) {
    final a = _attrs(j);
    return Contract(
      id: j['id']?.toString() ?? '',
      title: a['title']?.toString() ?? 'Contrat',
      status: switch (a['status']?.toString()) {
        'signed' => ContractStatus.signed,
        'unsigned' => ContractStatus.unsigned,
        'expired' => ContractStatus.expired,
        'terminated' => ContractStatus.terminated,
        _ => ContractStatus.unknown,
      },
      createdAt: DateTime.tryParse(a['created_at']?.toString() ?? '') ??
          DateTime.now(),
      tutorName: a['tutor_name']?.toString(),
      childName: a['child_name']?.toString(),
      amount: (a['amount'] as num?)?.toInt(),
      pdfUrl: a['pdf_url']?.toString(),
      signedAt: DateTime.tryParse(a['signed_at']?.toString() ?? ''),
    );
  }

  /// Helper : si la reponse suit le format JSON:API
  /// (`{id, type, attributes: {...}}`), retourne `attributes`. Sinon, le map
  /// est deja plat → on le retourne tel quel.
  static Map<String, dynamic> _attrs(Map<String, dynamic> j) {
    final a = j['attributes'];
    return a is Map<String, dynamic> ? a : j;
  }
}
