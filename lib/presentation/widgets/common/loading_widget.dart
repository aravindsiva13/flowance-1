// lib/presentation/widgets/common/loading_widget.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;
  
  const LoadingWidget({
    Key? key,
    this.message,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 50,
            height: size ?? 50,
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
