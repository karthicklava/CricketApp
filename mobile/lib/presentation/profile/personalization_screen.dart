import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/launcher_icon_service.dart';
import 'profile_state.dart';
import 'profile_notifier.dart';
import '../common/widgets/cricket_badge_widget.dart';
import '../../core/theme.dart';

class PersonalizationScreen extends ConsumerStatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  ConsumerState<PersonalizationScreen> createState() =>
      _PersonalizationScreenState();
}

class _PersonalizationScreenState extends ConsumerState<PersonalizationScreen> {
  late TextEditingController _nameController;
  late TextEditingController _jerseyController;
  late CricketIconStyle _selectedStyle;
  late String _selectedColorHex;
  late bool _includePdf;
  bool _previewDarkMode = false;
  String? _inlineError;

  final List<Map<String, String>> _colorPresets = const [
    {'name': 'Classic Blue', 'hex': '#0D6EFD'},
    {'name': 'Victory Green', 'hex': '#198754'},
    {'name': 'Power Red', 'hex': '#DC3545'},
    {'name': 'Royal Purple', 'hex': '#6F42C1'},
    {'name': 'Golden Captain', 'hex': '#FFC107'},
    {'name': 'Dark Knight', 'hex': '#212529'},
  ];

  final List<String> _popularSuggestions = const [
    '7',
    '10',
    '18',
    '45',
    '77',
    '99'
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileNotifierProvider);
    _nameController = TextEditingController(text: profile.userName);
    _jerseyController =
        TextEditingController(text: profile.jerseyNumberDisplay);
    _selectedStyle = profile.iconStyle;
    _selectedColorHex = profile.primaryColorHex;
    _includePdf = profile.includeProfileInPdf;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jerseyController.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF0D6EFD);
    }
  }

  void _validateAndSetJersey(String val) {
    final trimmed = val.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _jerseyController.text = '';
        _inlineError = null;
      });
      return;
    }

    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < 1 || parsed > 99) {
      setState(
          () => _inlineError = 'Please enter a valid number between 1 and 99');
    } else {
      setState(() {
        _inlineError = null;
      });
    }
  }

  void _increment() {
    final current = int.tryParse(_jerseyController.text.trim()) ?? 0;
    if (current < 99) {
      final next = current + 1;
      _jerseyController.text = '$next';
      _validateAndSetJersey(_jerseyController.text);
    }
  }

  void _decrement() {
    final current = int.tryParse(_jerseyController.text.trim()) ?? 0;
    if (current > 0) {
      final next = current - 1;
      _jerseyController.text = '$next';
      _validateAndSetJersey(_jerseyController.text);
    }
  }

  void _save() async {
    if (_inlineError != null) return;
    final text = LauncherIconService.normalizeJerseyNumber(
        _jerseyController.text.trim().isEmpty ? '18' : _jerseyController.text);

    await ref.read(profileNotifierProvider.notifier).updateProfile(
          userName: _nameController.text.isEmpty
              ? 'Guest Scorer'
              : _nameController.text,
          jerseyNumberDisplay: text,
          iconStyle: _selectedStyle,
          primaryColorHex: _selectedColorHex,
          includeProfileInPdf: _includePdf,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Your cricket identity has been updated successfully.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPrimary = _parseColor(_selectedColorHex);

    return Scaffold(
      appBar: AppBar(title: const Text('Personalize Identity & Badge')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Live Preview Container
          Card(
            color:
                _previewDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LIVE BADGE PREVIEW',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _previewDarkMode
                              ? Colors.white70
                              : Colors.grey.shade700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                            _previewDarkMode
                                ? Icons.light_mode
                                : Icons.dark_mode,
                            size: 18),
                        tooltip: 'Toggle Theme Preview',
                        onPressed: () => setState(
                            () => _previewDarkMode = !_previewDarkMode),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CricketBadgeWidget(
                    jerseyNumber: _jerseyController.text.trim(),
                    style: _selectedStyle,
                    primaryColor: currentPrimary,
                    size: 110,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _nameController.text.isEmpty
                        ? 'Guest Scorer'
                        : _nameController.text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _previewDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'Jersey No. ${_jerseyController.text.isEmpty ? "18" : _jerseyController.text}',
                    style: TextStyle(
                        fontSize: 13,
                        color: _previewDarkMode ? Colors.white60 : Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // User Name Input
          const Text('Your Name / Scorer Identity:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'e.g. Karthick',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => setState(() {}),
          ),
          const SizedBox(height: 20),

          // Jersey Number Input & Controls
          const Text('Choose Your Jersey Number (1 - 99):',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton.filledTonal(
                icon: const Icon(Icons.remove),
                onPressed: _decrement,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _jerseyController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '18',
                    errorText: _inlineError,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: _validateAndSetJersey,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: const Icon(Icons.add),
                onPressed: _increment,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Popular Suggestion Chips
          const Text('Popular Numbers:',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: _popularSuggestions.map((num) {
              return ChoiceChip(
                label: Text('#$num'),
                selected: _jerseyController.text.trim() == num,
                onSelected: (selected) {
                  if (selected) {
                    _jerseyController.text = num;
                    _validateAndSetJersey(num);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Icon Style Selector
          const Text('Select Badge Style:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: CricketIconStyle.values.map((style) {
              final isSelected = _selectedStyle == style;
              return InkWell(
                onTap: () => setState(() => _selectedStyle = style),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent,
                    border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      CricketBadgeWidget(
                        jerseyNumber: _jerseyController.text.trim(),
                        style: style,
                        primaryColor: currentPrimary,
                        size: 44,
                      ),
                      const SizedBox(height: 4),
                      Text(style.name.toUpperCase(),
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.black87)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Color Scheme Selector
          const Text('Select Theme Color:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: _colorPresets.map((preset) {
              final color = _parseColor(preset['hex']!);
              final isSelected = _selectedColorHex == preset['hex'];
              return ChoiceChip(
                avatar: CircleAvatar(backgroundColor: color),
                label: Text(preset['name']!),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedColorHex = preset['hex']!);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // PDF Privacy Toggle
          SwitchListTile(
            title: const Text('Include profile in shared scorecards'),
            subtitle: const Text(
                'Displays "Scored by [Name] • Jersey No. [X]" in PDF scorecard footer'),
            value: _includePdf,
            onChanged: (val) => setState(() => _includePdf = val),
          ),
          const SizedBox(height: 32),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white),
              icon: const Icon(Icons.check),
              label: const Text('SAVE PERSONALIZATION',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: _save,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () async {
              await ref.read(profileNotifierProvider.notifier).resetToDefault();
              final reset = ref.read(profileNotifierProvider);
              setState(() {
                _nameController.text = reset.userName;
                _jerseyController.text = reset.jerseyNumberDisplay;
                _selectedStyle = reset.iconStyle;
                _selectedColorHex = reset.primaryColorHex;
                _includePdf = reset.includeProfileInPdf;
                _inlineError = null;
              });
            },
            child: const Text('Reset to Default',
                style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
