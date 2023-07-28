import 'package:freezed_annotation/freezed_annotation.dart';

part 'hosted_image.freezed.dart';

@freezed
class HostedImage with _$HostedImage {
  const factory HostedImage({
    required String fileName,
    required int width,
    required int height,
  }) = _Image;
}
