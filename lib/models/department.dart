class SupportTeam {
  final String id;
  final String name;
  final String departmentId;
  final List<String> memberNames;

  const SupportTeam({
    required this.id,
    required this.name,
    required this.departmentId,
    this.memberNames = const [],
  });

  factory SupportTeam.fromJson(Map<String, dynamic> json) {
    return SupportTeam(
      id: json['id'] as String,
      name: json['name'] as String,
      departmentId: json['departmentId'] as String,
      memberNames: (json['memberNames'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'departmentId': departmentId,
      'memberNames': memberNames,
    };
  }
}

class Department {
  final String id;
  final String name;
  final String code;
  final List<SupportTeam> teams;

  const Department({
    required this.id,
    required this.name,
    required this.code,
    required this.teams,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      teams: (json['teams'] as List<dynamic>?)
              ?.map((t) => SupportTeam.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'teams': teams.map((t) => t.toJson()).toList(),
    };
  }
}
