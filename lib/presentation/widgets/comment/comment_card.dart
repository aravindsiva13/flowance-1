// lib/presentation/widgets/comment/comment_card.dart

import 'package:flutter/material.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/user_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';

class CommentCard extends StatelessWidget {
  final CommentModel comment;
  final UserModel author;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool canEdit;
  final bool canDelete;
  final bool showActions;

  const CommentCard({
    Key? key,
    required this.comment,
    required this.author,
    this.onEdit,
    this.onDelete,
    this.canEdit = false,
    this.canDelete = false,
    this.showActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            _buildContent(),
            if (comment.mentions.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildMentions(),
            ],
            if (showActions && (canEdit || canDelete)) ...[
              const SizedBox(height: 8),
              _buildActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primaryBlue,
          child: Text(
            author.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                AppDateUtils.formatRelativeTime(comment.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (comment.updatedAt != null && 
            comment.updatedAt!.isAfter(comment.createdAt))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'edited',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.warning,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        comment.content,
        style: const TextStyle(
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildMentions() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: comment.mentions.map((mentionId) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
          ),
          child: Text(
            '@mentioned',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (canEdit)
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Edit'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
        if (canDelete)
          TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }
}

// lib/presentation/widgets/comment/comment_input.dart

class CommentInput extends StatefulWidget {
  final String? initialText;
  final String hintText;
  final VoidCallback? onCancel;
  final Function(String content, List<String> mentions)? onSubmit;
  final bool isLoading;
  final bool isEditing;

  const CommentInput({
    Key? key,
    this.initialText,
    this.hintText = 'Add a comment...',
    this.onCancel,
    this.onSubmit,
    this.isLoading = false,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      _controller.text = widget.initialText!;
      _isExpanded = true;
    }
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isExpanded = _focusNode.hasFocus || _controller.text.isNotEmpty;
    });
  }

  void _handleSubmit() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    // Extract mentions (simple implementation - look for @mentions)
    final mentions = <String>[];
    final mentionRegex = RegExp(r'@(\w+)');
    final matches = mentionRegex.allMatches(content);
    for (final match in matches) {
      final mention = match.group(1);
      if (mention != null) {
        mentions.add(mention);
      }
    }

    widget.onSubmit?.call(content, mentions);
    
    if (!widget.isEditing) {
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  void _handleCancel() {
    _controller.text = widget.initialText ?? '';
    _focusNode.unfocus();
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: _isExpanded ? null : 1,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  enabled: !widget.isLoading,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: widget.isLoading ? null : _handleSubmit,
                icon: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        widget.isEditing ? Icons.check : Icons.send,
                        color: AppColors.primaryBlue,
                      ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                ),
              ),
            ],
          ),
          if (_isExpanded && widget.isEditing) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.isLoading ? null : _handleCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: widget.isLoading ? null : _handleSubmit,
                  child: const Text('Update'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}