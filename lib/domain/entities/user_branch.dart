class UserEntity {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
    required this.permissions,
  });
  final int id;
  final String name;
  final String email;
  final List<String> roles;
  final List<String> permissions;

  factory UserEntity.fromJson(Map<String, dynamic> j) => UserEntity(
    id: (j['id'] as num).toInt(),
    name: j['name'] as String? ?? '',
    email: j['email'] as String? ?? '',
    roles: _str(j['roles']),
    permissions: _str(j['permissions']),
  );

  static List<String> _str(dynamic v) {
    if (v is List) {
      return v.map((e) {
        if (e is String) return e;
        if (e is Map && e['name'] is String) return e['name'] as String;
        return '$e';
      }).toList();
    }
    return [];
  }
}

class BranchEntity {
  const BranchEntity({
    required this.id,
    required this.name,
    required this.code,
  });
  final int id;
  final String name;
  final String code;
  factory BranchEntity.fromJson(Map<String, dynamic> j) => BranchEntity(
    id: (j['id'] as num).toInt(),
    name: j['name'] as String? ?? '',
    code: j['code'] as String? ?? '',
  );
}
