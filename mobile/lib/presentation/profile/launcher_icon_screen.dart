import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/launcher_icon_service.dart';
import '../../main.dart';
import 'profile_notifier.dart';

class LauncherIconScreen extends ConsumerStatefulWidget {
  const LauncherIconScreen({super.key});

  @override
  ConsumerState<LauncherIconScreen> createState() => _LauncherIconScreenState();
}

class _LauncherIconScreenState extends ConsumerState<LauncherIconScreen> {
  late final TextEditingController _controller;
  bool _applying = false;
  bool? _supported;
  String? _appliedIconId;
  String? _error;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPrefsProvider);
    final storedNumber = prefs.get(LauncherIconService.selectedJerseyNumberKey);
    final validStoredNumber = storedNumber is int &&
            storedNumber >= LauncherIconService.minimumJerseyNumber &&
            storedNumber <= LauncherIconService.maximumJerseyNumber
        ? storedNumber
        : null;
    _controller = TextEditingController(
      text:
          '${validStoredNumber ?? ref.read(profileNotifierProvider).jerseyNumberValue}',
    );
    _loadState();
  }

  LauncherIconService get _service =>
      LauncherIconService(ref.read(sharedPrefsProvider));

  Future<void> _loadState() async {
    final prefs = ref.read(sharedPrefsProvider);
    final showMigration =
        prefs.getBool(LauncherIconService.launcherIconMigrationPromptKey) ??
            false;
    final supported = await _service.isSupported();
    final selected = await _service.getSelectedIcon();
    if (mounted) {
      setState(() {
        _supported = supported;
        _appliedIconId = selected;
        if (showMigration) {
          _error =
              'Your previous launcher-icon number is no longer supported. Choose a jersey number between 1 and 99.';
        }
      });
      if (showMigration) {
        await prefs.remove(LauncherIconService.launcherIconMigrationPromptKey);
      }
    }
  }

  String? get _display {
    try {
      return LauncherIconService.normalizeJerseyNumber(_controller.text);
    } on FormatException {
      return null;
    }
  }

  void _step(int delta) {
    final current = int.tryParse(_controller.text) ?? 0;
    final next = (current + delta).clamp(1, 99);
    setState(() {
      _controller.text = '$next';
      _error = null;
    });
  }

  Future<void> _apply() async {
    final display = _display;
    if (display == null) {
      setState(() => _error = _validationMessage(_controller.text));
      return;
    }
    setState(() {
      _applying = true;
      _error = null;
    });
    final profile = ref.read(profileNotifierProvider);
    await ref.read(profileNotifierProvider.notifier).updateProfile(
          userName: profile.userName,
          jerseyNumberDisplay: display,
          iconStyle: profile.iconStyle,
          primaryColorHex: profile.primaryColorHex,
          includeProfileInPdf: profile.includeProfileInPdf,
        );
    final result = await _service.applyJerseyIcon(display);
    if (!mounted) return;
    setState(() {
      _applying = false;
      _appliedIconId = result.success ? result.iconId : _appliedIconId;
      _error = result.error;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result.success
          ? 'Launcher icon updated to Jersey #$display. It may take a few seconds for your home screen to refresh.'
          : 'We could not update the launcher icon on this device. Your in-app jersey badge is still saved.'),
    ));
  }

  String? _validationMessage(String input) {
    try {
      LauncherIconService.parseJerseyNumber(input);
      return null;
    } on FormatException catch (error) {
      return error.message;
    }
  }

  Future<void> _restore() async {
    setState(() => _applying = true);
    final result = await _service.restoreDefaultIcon();
    if (!mounted) return;
    setState(() {
      _applying = false;
      if (result.success) _appliedIconId = null;
      _error = result.error;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result.success
          ? 'Default launcher icon restored.'
          : 'We could not restore the default launcher icon.'),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final display = _display ?? '--';
    return Scaffold(
      appBar: AppBar(title: const Text('Launcher Icon')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Launcher Icon Preview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Semantics(
            label: 'Launcher icon preview, jersey number $display.',
            image: true,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                _LauncherPreview(number: display, shape: BoxShape.rectangle),
                _LauncherPreview(number: display, shape: BoxShape.circle),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Jersey #$display',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const Text('Choose Jersey Number',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('Allowed range: 1–99'),
          const SizedBox(height: 8),
          Row(children: [
            IconButton.filledTonal(
                tooltip: 'Previous jersey number',
                onPressed: () => _step(-1),
                icon: const Icon(Icons.remove)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                decoration: InputDecoration(
                  labelText: 'Jersey Number',
                  errorText: _error,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) =>
                    setState(() => _error = _validationMessage(value)),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
                tooltip: 'Next jersey number',
                onPressed: () => _step(1),
                icon: const Icon(Icons.add)),
          ]),
          const SizedBox(height: 16),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Available icon styles'),
            subtitle: Text('Shield'),
            leading: Icon(Icons.shield),
          ),
          if (_supported == false)
            const Text(
                'Launcher icon switching is not supported on this device.',
                style: TextStyle(color: Colors.red)),
          if (_appliedIconId != null)
            Text(
                'Currently applied: ${_appliedIconId!.replaceFirst('jersey_', 'Jersey #')}'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _applying || _supported != true || _display == null
                ? null
                : _apply,
            icon: _applying
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.app_shortcut),
            label: Text('Apply Jersey #$display to Phone'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _applying || _supported != true ? null : _restore,
            child: const Text('Restore Default Icon'),
          ),
        ],
      ),
    );
  }
}

class _LauncherPreview extends StatelessWidget {
  final String number;
  final BoxShape shape;

  const _LauncherPreview({required this.number, required this.shape});

  @override
  Widget build(BuildContext context) => Container(
        width: 128,
        height: 128,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: shape,
          borderRadius:
              shape == BoxShape.rectangle ? BorderRadius.circular(28) : null,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        child: number == '--'
            ? const ColoredBox(
                color: Color(0xFF043F30),
                child: Center(
                    child: Text('--',
                        style: TextStyle(color: Colors.white, fontSize: 40))))
            : Image.asset(
                'assets/branding/launcher_previews/jersey_$number.png',
                fit: BoxFit.cover,
              ),
      );
}
