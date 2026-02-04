import 'package:dio/dio.dart';
import '../model/image_result.dart';

class ImageRepository {
  final Dio _dio;

  ImageRepository(this._dio);

  Future<List<ImageResult>> fetchImages(String searchWord) async {
    final keyword = Uri.encodeComponent(searchWord);
    final url = "https://search.yahoo.co.jp/image/search?ei=UTF-8&p=$keyword";

    final response = await _dio.get(url,
        options: Options(headers: {
          'User-Agent': 'your_email@example.com',
        }));

    if (response.statusCode != 200) throw Exception('HTTP Error');

    final body = response.data.toString();
    final regex =
        RegExp(r'(https?)://msp.c.yimg.jp/([A-Z0-9a-z._%+-/]{2,1024}).jpg');
    final matches = regex.allMatches(body);

    // 重複を除去してモデルのリストに変換
    return matches
        .map((m) => body.substring(m.start, m.end))
        .toSet() // 重複排除
        .map((url) => ImageResult(url: url))
        .toList();
  }
}
