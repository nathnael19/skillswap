import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppImageCacheManager extends CacheManager {
  static const cacheKey = 'skillswap_image_cache';

  static final AppImageCacheManager instance = AppImageCacheManager._();

  AppImageCacheManager._()
      : super(
          Config(
            cacheKey,
            stalePeriod: const Duration(days: 7),
            maxNrOfCacheObjects: 300,
          ),
        );
}
