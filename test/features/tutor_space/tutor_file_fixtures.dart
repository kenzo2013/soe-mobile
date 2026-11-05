/// API v2 payloads of the recruitment journey, shared by the tutor file tests.
library;

Map<String, dynamic> sectionRow(String section, String state,
        {String summary = '', bool editable = true}) =>
    {
      'section': section,
      'label': switch (section) {
        'identity' => 'Identité et pièce d’identité',
        'address' => 'Adresse et quartiers',
        'subjects' => 'Matières par classe',
        'availability' => 'Disponibilités',
        'diplomas' => 'Diplômes et justificatifs',
        'experiences' => 'Expériences',
        _ => 'Présentation',
      },
      'state': state,
      'state_label': switch (state) {
        'accepted' => 'Acceptée',
        'complete' => 'Complète',
        'in_review' => 'En vérification',
        'redo' => 'À refaire',
        _ => 'À fournir',
      },
      'summary': summary,
      'editable': editable,
    };

Map<String, dynamic> fileJson({
  String stage = 'application',
  int step = 1,
  bool canSubmit = false,
  String presentation = 'missing',
  String diplomas = 'redo',
}) =>
    {
      'stage': stage,
      'step': step,
      'total_steps': 6,
      'step_label': 'Compléter le dossier',
      'active': stage == 'active',
      'refused': stage == 'refused',
      'complete_count': 5,
      'total_sections': 7,
      'can_submit': canSubmit,
      'sections': [
        sectionRow('identity', 'accepted', summary: 'CNI recto verso'),
        sectionRow('address', 'complete', summary: 'Makepe · 6 quartiers'),
        sectionRow('subjects', 'complete', summary: 'Maths 4e'),
        sectionRow('availability', 'complete', summary: '9 plages'),
        sectionRow('diplomas', diplomas, summary: 'Relevé illisible'),
        sectionRow('experiences', 'complete', summary: '2 expériences'),
        sectionRow('presentation', presentation,
            summary: 'Photo et bio à ajouter'),
      ],
      'badge': [
        {
          'item': 'identity',
          'label': 'Pièce d’identité',
          'state': 'accepted',
          'state_label': 'Acceptée',
        },
        {
          'item': 'diplomas',
          'label': 'Diplômes',
          'state': 'in_review',
          'state_label': 'En vérification',
        },
        {
          'item': 'interview',
          'label': 'Entretien',
          'state': 'upcoming',
          'state_label': 'À venir',
        },
        {
          'item': 'test',
          'label': 'Test de niveau',
          'state': 'upcoming',
          'state_label': 'À venir',
        },
      ],
      'to_redo': diplomas == 'redo'
          ? [
              {
                'document': 'diploma',
                'label': 'Diplômes et justificatifs',
                'reason': 'Relevé illisible.',
              }
            ]
          : <dynamic>[],
    };

Map<String, dynamic> sectionJson(
  String section, {
  required Map<String, dynamic> content,
  String state = 'missing',
  bool editable = true,
  String? redoReason,
}) =>
    {
      ...sectionRow(section, state, editable: editable),
      'redo_reason': redoReason,
      'content': content,
    }..remove('summary');

Map<String, dynamic> charterJson(
        {required bool canSign, String stage = 'charter', String? signedAt}) =>
    {
      'stage': stage,
      'signed_at': signedAt,
      'can_sign': canSign,
      'articles': [
        {
          'title': 'Ponctualité et présence',
          'body': 'Je pointe mon arrivée et mon départ à chaque séance.',
        },
        {
          'title': 'Respect de l’enfant',
          'body': 'Je garde une attitude bienveillante.',
        },
      ],
    };
