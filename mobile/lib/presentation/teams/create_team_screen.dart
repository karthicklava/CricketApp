import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/team_repository.dart';
import '../../core/theme.dart';

class CreateTeamScreen extends ConsumerStatefulWidget {
  final String? initialTeamId;

  const CreateTeamScreen({super.key, this.initialTeamId});

  @override
  ConsumerState<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends ConsumerState<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  String _selectedColor = '#0F5132';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTeamId != null) {
      _loadExistingTeam();
    }
  }

  Future<void> _loadExistingTeam() async {
    final team = await ref
        .read(teamRepositoryProvider)
        .getTeamById(widget.initialTeamId!);
    if (team != null && mounted) {
      setState(() {
        _nameController.text = team.name;
        _cityController.text = team.city ?? '';
        if (team.color != null) _selectedColor = team.color!;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  String _deriveShortName(String teamName) {
    final words = teamName.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      final initials = words
          .take(3)
          .map((w) => w.isNotEmpty ? w[0] : '')
          .join('')
          .toUpperCase();
      if (initials.isNotEmpty) return initials;
    }
    final clean = teamName.replaceAll(RegExp(r'[^\w]'), '').toUpperCase();
    return clean.length >= 3
        ? clean.substring(0, 3)
        : (clean.isNotEmpty ? clean : 'TM');
  }

  Future<void> _saveTeam(bool addPlayers) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final name = _nameController.text.trim();
      final shortName = _deriveShortName(name);

      String teamId;
      if (widget.initialTeamId != null) {
        await ref.read(teamRepositoryProvider).updateTeam(
              id: widget.initialTeamId!,
              name: name,
              shortName: shortName,
              city: _cityController.text.trim(),
              color: _selectedColor,
            );
        teamId = widget.initialTeamId!;
      } else {
        teamId = await ref.read(teamRepositoryProvider).createTeam(
              name: name,
              shortName: shortName,
              city: _cityController.text.trim(),
              color: _selectedColor,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Team "$name" saved successfully!')),
        );

        if (addPlayers) {
          context.pushReplacement('/teams/add-players/$teamId');
        } else {
          final team =
              await ref.read(teamRepositoryProvider).getTeamById(teamId);
          if (team != null && mounted) {
            context.pushReplacement('/teams/details', extra: team);
          } else {
            context.pop();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.wicketRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialTeamId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Team' : 'Create New Team')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Team General Information',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Team Name *',
                        hintText: 'e.g. Royal Challengers',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Team name is mandatory';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City / Location (Optional)',
                        hintText: 'e.g. Bangalore',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Team Theme Colour',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      children: [
                        '#0F5132',
                        '#DC3545',
                        '#0D6EFD',
                        '#6F42C1',
                        '#FFC107',
                        '#FD7E14'
                      ].map((colorStr) {
                        final color = Color(
                            int.parse(colorStr.replaceFirst('#', '0xFF')));
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedColor = colorStr),
                          child: CircleAvatar(
                            backgroundColor: color,
                            radius: 20,
                            child: _selectedColor == colorStr
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 22)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),

                    // Actions
                    SizedBox(
                      width: double.infinity,
                      height: AppCtaStyle.height,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.group_add),
                        label: const Text('SAVE & ADD PLAYERS',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _saveTeam(true),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: AppCtaStyle.height,
                      child: OutlinedButton(
                        onPressed: () => _saveTeam(false),
                        child: const Text('SAVE TEAM ONLY'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
