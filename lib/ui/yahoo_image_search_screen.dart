import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_yahoo_image_search/repository/image_repository_impl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'yahoo_image_search_viewmodel.dart';
import '../repository/image_repository.dart';

class YahooImageSearchScreen extends StatelessWidget {
  const YahooImageSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => YahooImageSearchViewmodel(ImageRepositoryImpl(Dio())),
      child: const _YahooImageSearchScreen(),
    );
  }
}

class _YahooImageSearchScreen extends StatelessWidget {
  const _YahooImageSearchScreen();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<YahooImageSearchViewmodel>(context);

    // isLoading が true になったら SmartDialog を表示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.isLoading) {
        SmartDialog.showLoading();
      } else {
        SmartDialog.dismiss();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yahoo Image Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 4),
                TextField(
                  onChanged: viewModel.setSearchWord,
                  decoration: const InputDecoration(
                    labelText: '検索キーワード',
                    border: OutlineInputBorder(),
                    isDense: true, // これも高さを詰める効果あり
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 12.0), // ← 余白調整
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed:
                      viewModel.isSearchButtonEnabled && !viewModel.isLoading
                          ? () {
                              // キーボードを閉じる
                              FocusScope.of(context).unfocus();
                              // 検索を実行
                              viewModel.search();
                            }
                          : null,
                  child: viewModel.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('検索'),
                ),
                const SizedBox(height: 10),
                if (viewModel.error != null)
                  Text(
                    'エラー: ${viewModel.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0), // 左右に16px余白
              child: GridView.builder(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag, // スクロール開始で閉じる
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3列
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.0, // 正方形なら1.0、縦長なら変更
                ),
                itemCount: viewModel.results.length,
                itemBuilder: (context, index) {
                  final imageUrl = viewModel.results[index].url;
                  return GestureDetector(
                    onTap: () {
                      _showPhotoBrowser(context,
                          viewModel.results.map((e) => e.url).toList(), index);
                    },
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showPhotoBrowser(
    BuildContext context,
    List<String> photos,
    int initialIndex,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "閉じる",
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      //useSafeArea: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PhotoViewGallery.builder(
                itemCount: photos.length,
                pageController: PageController(initialPage: initialIndex),
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(photos[index]),
                    heroAttributes: PhotoViewHeroAttributes(tag: photos[index]),
                  );
                },
                scrollPhysics: const BouncingScrollPhysics(),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
