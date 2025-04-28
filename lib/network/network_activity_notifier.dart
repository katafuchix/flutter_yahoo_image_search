import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_activity_notifier.g.dart';

@Riverpod(keepAlive: true)
class NetworkActivityNotifier extends _$NetworkActivityNotifier {
  late StreamSubscription<List<ConnectivityResult>> subscription;

  @override
  Future<List<ConnectivityResult>> build() async {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      state = AsyncValue.data(result);
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return await (Connectivity().checkConnectivity());
  }

  bool get isOnline =>
      state.value?.contains(ConnectivityResult.mobile) == true ||
          state.value?.contains(ConnectivityResult.wifi) == true;

  bool get isOffline => state.value?.contains(ConnectivityResult.none) == true;
}
