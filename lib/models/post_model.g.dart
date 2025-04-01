// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostModelImpl _$$PostModelImplFromJson(Map<String, dynamic> json) =>
    _$PostModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrls:
          (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList(),
      visitedAt: DateTime.parse(json['visitedAt'] as String),
      categories:
          (json['categories'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$$PostModelImplToJson(_$PostModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'imageUrls': instance.imageUrls,
      'visitedAt': instance.visitedAt.toIso8601String(),
      'categories': instance.categories,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'createdAt': instance.createdAt.toIso8601String(),
      'userId': instance.userId,
    };
