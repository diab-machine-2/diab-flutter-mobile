import 'package:better_player/better_player.dart';

class VideoManager {
  VideoManager({required String url, required int loop}) {
    _initVideoController(url: url, loop: loop);
  }

  late final BetterPlayerController controller;

  void _initVideoController({required String url, required int loop}) {
    this.controller = BetterPlayerController(
      const BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        '',
      ),
    );
  }

  void changeUrl({required String url, required int loop}) {
    this.controller.setupDataSource(
          BetterPlayerDataSource(
            BetterPlayerDataSourceType.network,
            url,
          ),
        );
    this.controller.retryDataSource();
    this.controller.setControlsAlwaysVisible(true);
  }

  void dispose() {
    this.controller.dispose(forceDispose: true);
  }
}
