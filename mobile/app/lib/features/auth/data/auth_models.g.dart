// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  status: $enumDecode(_$UserStatusEnumMap, json['status']),
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
  phone: json['phone'] as String?,
  phoneVerifiedAt: json['phoneVerifiedAt'] == null
      ? null
      : DateTime.parse(json['phoneVerifiedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'role': _$UserRoleEnumMap[instance.role]!,
  'status': _$UserStatusEnumMap[instance.status]!,
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
  'phone': instance.phone,
  'phoneVerifiedAt': instance.phoneVerifiedAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$UserRoleEnumMap = {UserRole.user: 'USER', UserRole.admin: 'ADMIN'};

const _$UserStatusEnumMap = {
  UserStatus.active: 'ACTIVE',
  UserStatus.locked: 'LOCKED',
};

_AuthResult _$AuthResultFromJson(Map<String, dynamic> json) => _AuthResult(
  accessToken: json['accessToken'] as String,
  user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuthResultToJson(_AuthResult instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'user': instance.user,
    };
