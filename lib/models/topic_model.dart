class Topic {
  String id;
  String title;
  bool isDiscussed;
  String note;

  Topic({required this.id, required this.title, this.isDiscussed = false, this.note = ''});

  Map<String, dynamic> toMap() => {
    'title': title,
    'isDiscussed': isDiscussed,
    'note': note,
  };

  factory Topic.fromMap(String id, Map<String, dynamic> map) => Topic(
    id: id,
    title: map['title'] ?? '',
    isDiscussed: map['isDiscussed'] ?? false,
    note: map['note'] ?? '',
  );
}
