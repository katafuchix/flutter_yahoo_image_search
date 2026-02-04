import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart'; // おすすめ
import '../lib/ui/yahoo_image_search_viewmodel.dart';
import '../lib/repository/image_repository_impl.dart';

void main() {
  late YahooImageSearchViewmodel viewModel;
  late Dio dio;
  late DioAdapter dioAdapter;

  setUp(() {
    dio = Dio();
    dioAdapter = DioAdapter(dio: dio);
    viewModel = YahooImageSearchViewmodel(ImageRepositoryImpl(dio));
  });

  test('検索ワードが3文字未満の時は検索を実行しない', () async {
    viewModel.setSearchWord('ab');
    await viewModel.search();

    expect(viewModel.isLoading, false);
    expect(viewModel.results.isEmpty, true);
  });

  test('検索成功時にURLリストが取得できること', () async {
    const mockHtml = '... <img src="https://msp.c.yimg.jp/sample.jpg"> ...';

    // YahooのURLが叩かれたら、偽のHTMLを返すように設定
    dioAdapter.onGet(
      RegExp(r'https://search.yahoo.co.jp/image/search.*'),
      (server) => server.reply(200, mockHtml),
    );

    viewModel.setSearchWord('Flutter');

    // 検索実行
    final future = viewModel.search();

    // 実行中の状態を確認
    expect(viewModel.isLoading, true);

    await future;

    // 完了後の状態を確認
    expect(viewModel.isLoading, false);
    expect(viewModel.results.length, 1);
    expect(viewModel.results.first.url, 'https://msp.c.yimg.jp/sample.jpg');
    expect(viewModel.error, isNull);
  });
}
