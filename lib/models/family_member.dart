class FamilyMember {
  final String uid;
  String nickname;

  FamilyMember({
    required this.uid,
    required this.nickname,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      uid: json['uid'] as String,
      nickname: json['nickname'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nickname': nickname,
    };
  }
}
