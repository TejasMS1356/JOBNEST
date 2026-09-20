import 'package:flutter/material.dart';

/// Search input with a clear button and debounced change callback.
class JobSearchField extends StatefulWidget {
  const JobSearchField({
    super.key,
    this.initialValue = '',
    required this.onChanged,
    required this.onSubmitted,
    required this.onCleared,
    this.hintText = 'Search roles, companies, skills',
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onCleared;
  final String hintText;

  @override
  State<JobSearchField> createState() => _JobSearchFieldState();
}

class _JobSearchFieldState extends State<JobSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(
              alpha: _focusNode.hasFocus ? 0.18 : 0.06,
            ),
            blurRadius: _focusNode.hasFocus ? 22 : 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          setState(() {});
          widget.onChanged(value);
        },
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _focusNode.hasFocus
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _controller.clear();
                    setState(() {});
                    widget.onCleared();
                  },
                ),
        ),
      ),
    );
  }
}
