class ChathubChannel {
  List<Channels>? channels;

  ChathubChannel({channels});

  ChathubChannel.fromJson(Map<String, dynamic> json) {
    if (json['channels'] != null) {
      channels = <Channels>[];
      json['channels'].forEach((v) {
        channels!.add(Channels.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (channels != null) {
      data['channels'] = channels!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Channels {
  bool? status;
  String? sId;
  String? nameApp;
  String? source;
  String? socialChanelId;
  String? accessToken;
  String? refreshToken;
  String? expiresIn;
  String? refreshExpiresIn;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? oaSecrectKey;

  Channels(
      {status,
        sId,
        nameApp,
        source,
        socialChanelId,
        accessToken,
        refreshToken,
        expiresIn,
        refreshExpiresIn,
        createdAt,
        updatedAt,
        iV,
        oaSecrectKey});

  Channels.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    sId = json['_id'];
    nameApp = json['nameApp'];
    source = json['source'];
    socialChanelId = json['socialChanelId'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    expiresIn = json['expiresIn'];
    refreshExpiresIn = json['refreshExpiresIn'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    oaSecrectKey = json['oaSecrectKey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['_id'] = sId;
    data['nameApp'] = nameApp;
    data['source'] = source;
    data['socialChanelId'] = socialChanelId;
    data['accessToken'] = accessToken;
    data['refreshToken'] = refreshToken;
    data['expiresIn'] = expiresIn;
    data['refreshExpiresIn'] = refreshExpiresIn;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['oaSecrectKey'] = oaSecrectKey;
    return data;
  }
}