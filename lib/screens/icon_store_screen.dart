import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/profile_icon_catalog.dart';
import '../services/purchase_service.dart';
import '../state/app_controller.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_icon_tile.dart';

class IconStoreScreen extends StatelessWidget {
  const IconStoreScreen({super.key});

  Future<void> _onIconTap(BuildContext context, ProfileIconEntry entry) async {
    final controller = context.read<AppController>();
    final isOwned = controller.isIconOwned(entry);

    if (isOwned) {
      await _showEquipDialog(context, entry);
      return;
    }

    await _showPurchaseDialog(context, entry);
  }

  Future<void> _showEquipDialog(
    BuildContext context,
    ProfileIconEntry entry,
  ) async {
    final controller = context.read<AppController>();
    final equipped = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Equip ${entry.displayName}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfileIconPreview(entry: entry, size: 72),
            const SizedBox(height: 12),
            const Text('This icon will appear on your profile.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Equip'),
          ),
        ],
      ),
    );

    if (equipped == true && context.mounted) {
      await controller.equipProfileIcon(entry);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${entry.displayName} equipped.')),
      );
    }
  }

  Future<void> _showPurchaseDialog(
    BuildContext context,
    ProfileIconEntry entry,
  ) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unlock ${entry.displayName}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfileIconPreview(entry: entry, size: 72, dimmed: true),
            const SizedBox(height: 12),
            const Text(
              'Purchase this profile icon for \$0.99.\n'
              'A parent or guardian must approve.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Purchase for \$0.99'),
          ),
        ],
      ),
    );

    if (proceed != true || !context.mounted) return;

    final passedGate = await _showParentGate(context);
    if (!passedGate || !context.mounted) return;

    final controller = context.read<AppController>();
    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    final result = await controller.purchasePremiumIcon(entry.id);
    if (!context.mounted) return;
    Navigator.pop(context);

    switch (result) {
      case PremiumPurchaseResult.success:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${entry.displayName} unlocked.')),
        );
      case PremiumPurchaseResult.storeUnavailable:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The app store is not available on this device.',
            ),
          ),
        );
      case PremiumPurchaseResult.cancelled:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase cancelled.')),
        );
      case PremiumPurchaseResult.failed:
        final message = controller.usesStubPurchases
            ? 'Purchase could not be completed.'
            : 'Purchase was cancelled or could not be completed.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }

  Future<bool> _showParentGate(BuildContext context) async {
    final random = Random();
    final a = random.nextInt(8) + 2;
    final b = random.nextInt(8) + 2;

    final passed = await showDialog<bool>(
      context: context,
      builder: (context) => _ParentGateDialog(a: a, b: b),
    );

    return passed == true;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final featured = ProfileIconCatalog.featuredIcons;
    final allIcons = ProfileIconCatalog.allIcons;

    return AppScaffold(
      title: 'Icon Store',
      subtitle: 'Pick a profile icon',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      body: ListView(
        children: [
          if (featured.isNotEmpty) ...[
            Text(
              'Featured',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: featured.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final entry = featured[index];
                  return ProfileIconTile(
                    entry: entry,
                    size: 80,
                    isOwned: controller.isIconOwned(entry),
                    isEquipped: controller.isIconEquipped(entry),
                    onTap: () => _onIconTap(context, entry),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            'All Icons',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: allIcons.length,
            itemBuilder: (context, index) {
              final entry = allIcons[index];
              return ProfileIconTile(
                entry: entry,
                isOwned: controller.isIconOwned(entry),
                isEquipped: controller.isIconEquipped(entry),
                onTap: () => _onIconTap(context, entry),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ParentGateDialog extends StatefulWidget {
  const _ParentGateDialog({required this.a, required this.b});

  final int a;
  final int b;

  @override
  State<_ParentGateDialog> createState() => _ParentGateDialogState();
}

class _ParentGateDialogState extends State<_ParentGateDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final value = int.tryParse(_controller.text.trim());
    Navigator.pop(context, value == widget.a + widget.b);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Parent check'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What is ${widget.a} + ${widget.b}?'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Answer',
            ),
            autofocus: true,
            onSubmitted: (_) => _confirm(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _confirm,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
