import 'package:freezed_annotation/freezed_annotation.dart';

part 'image.freezed.dart';

@freezed
class Image with _$Image {
  const factory Image({
    required Uri url,
    required int width,
    required int height,
  }) = _Image;
}
