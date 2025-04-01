import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_model.freezed.dart';
part 'post_model.g.dart';

@freezed
class PostModel with _$PostModel {
  const factory PostModel({
    required String id,
    required String title,
    required String description,
    required List<String> imageUrls,
    required DateTime visitedAt,
    required List<String> categories,
    required double latitude,
    required double longitude,
    required DateTime createdAt,
    required String userId,
  }) = _PostModel;

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);
}
