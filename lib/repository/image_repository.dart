import '../model/image_result.dart';

abstract class ImageRepository {
  Future<List<ImageResult>> fetchImages(String searchWord);
}
