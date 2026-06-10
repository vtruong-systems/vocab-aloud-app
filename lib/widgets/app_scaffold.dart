import 'package:flutter/material.dart';

import 'soft_background.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.leading,
    this.actions,
    this.subtitle,
  });

  final String? title;
  final String? subtitle;
  final Widget body;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: leading,
        title: title == null
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title!, style: Theme.of(context).textTheme.titleLarge),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                          ),
                    ),
                ],
              ),
        actions: actions,
      ),
      body: SoftBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: body,
          ),
        ),
      ),
    );
  }
}
