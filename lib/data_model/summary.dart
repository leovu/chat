class Tags {
  final String type;
  final String tag;

  Tags({required this.type, required this.tag});

  factory Tags.fromJson(Map<String, dynamic> json) {
    return Tags(
      type: json['type'] as String,
      tag: json['tag'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'tag': tag,
    };
  }
}

class ConversationSummaryModel {
  final String summary;
  final List<Tags> tags;

  ConversationSummaryModel({required this.summary, required this.tags});

  factory ConversationSummaryModel.fromJson(Map<String, dynamic> json) {
    return ConversationSummaryModel(
      summary: json['summary'] as String,
      tags: (json['tags'] as List)
          .map((tagJson) => Tags.fromJson(tagJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'tags': tags.map((tag) => tag.toJson()).toList(),
    };
  }
}
