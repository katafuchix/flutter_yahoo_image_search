import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/app_config.dart';
import '../model/image_result.dart';
import '../repository/image_repository.dart';

class YahooImageSearchViewmodel extends ChangeNotifier {
  final ImageRepository _repository;

  // DioではなくRepositoryを受け取るようにする
  YahooImageSearchViewmodel(this._repository);

  List<ImageResult> _results = [];

  List<ImageResult> get results => _results;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String _searchWord = '';
  String? _error;

  // Getter
  String get searchWord => _searchWord;

  String? get error => _error;

  bool get isSearchButtonEnabled => _searchWord.length >= AppConfig.minSearchWordLength;

  // Setter
  void setSearchWord(String word) {
    _searchWord = word;
    notifyListeners();
  }
  
  Future<void> search() async {
    if (!isSearchButtonEnabled) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 通信の詳細はリポジトリに任せる
      _results = await _repository.fetchImages(_searchWord);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/*
class YahooImageSearchViewmodel extends ChangeNotifier {
// 通信インスタンスを外から受け取れるように変更
  final Dio _dio;

  YahooImageSearchViewmodel({Dio? dio}) : _dio = dio ?? Dio();

  String _searchWord = '';
  List<String> _results = [];
  bool _isLoading = false;
  String? _error;

  // Getter
  String get searchWord => _searchWord;

  List<String> get results => _results;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get isSearchButtonEnabled => _searchWord.length >= 3;

  // Setter
  void setSearchWord(String word) {
    _searchWord = word;
    notifyListeners();
  }

  Future<void> search() async {
    if (!isSearchButtonEnabled) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final keyword = Uri.encodeComponent(_searchWord);
      final url = "https://search.yahoo.co.jp/image/search?ei=UTF-8&p=$keyword";

      final response = await _dio.get(url,
          options: Options(headers: {
            'User-Agent': 'your_email@example.com', // ← Constants.mail 相当
          }));

      if (response.statusCode == 200) {
        final body = response.data.toString();
        final regex =
            RegExp(r'(https?)://msp.c.yimg.jp/([A-Z0-9a-z._%+-/]{2,1024}).jpg');
        final matches = regex.allMatches(body);

        final urls = <String>{};
        for (final match in matches) {
          urls.add(body.substring(match.start, match.end));
        }

        _results = urls.toList();
      } else {
        _error = 'HTTP Error';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
*/
