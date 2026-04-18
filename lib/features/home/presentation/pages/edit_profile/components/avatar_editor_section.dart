import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/core/network/api_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AvatarEditorSection extends StatelessWidget {
  final String imageUrl;
  final XFile? localImage;
  final VoidCallback onTap;

  const AvatarEditorSection({
    super.key,
    required this.imageUrl,
    this.localImage,
    required this.onTap,
  });

  static const Color kBackground = AppColors.background;
  static const Color kAccent = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120,
            width: 120,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: kAccent.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: localImage != null
                        ? DecorationImage(
                            image: FileImage(File(localImage!.path)),
                            fit: BoxFit.cover,
                          )
                        : (imageUrl.startsWith('http') || imageUrl.startsWith('/static'))
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(
                                  imageUrl.startsWith('/')
                                      ? '${ApiConstants.mediaBaseUrl}$imageUrl'
                                      : imageUrl,
                                ),
                                fit: BoxFit.cover,
                              )
                            : DecorationImage(
                                image: AssetImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: kAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: kBackground, width: 2.5),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.textPrimary,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Change Photo',
          style: AppTextStyles.labelSmall.copyWith(
            color: kAccent,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}
