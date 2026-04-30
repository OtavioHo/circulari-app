import 'package:circulari/features/lists/domain/entities/list_picture.dart';

class ListPictureModel extends ListPicture {
  const ListPictureModel({required super.slug, required super.order});

  factory ListPictureModel.fromJson(Map<String, dynamic> json) =>
      ListPictureModel(
        slug: json['slug'] as String,
        order: json['order'] as int,
      );
}
