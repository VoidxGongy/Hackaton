import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supervisacampo/core/repositories/visits_repository.dart';
import 'package:supervisacampo/core/theme/app_theme.dart';
import 'package:supervisacampo/core/widgets/design_system.dart';

class SupervisorIncidentScreen extends StatefulWidget {
  const SupervisorIncidentScreen({super.key, required this.repository});

  final VisitsRepository repository;

  @override
  State<SupervisorIncidentScreen> createState() =>
      _SupervisorIncidentScreenState();
}

class _SupervisorIncidentScreenState extends State<SupervisorIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  String _priority = 'Media';
  String? _visitId;
  String? _photoPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final currentUserId = widget.repository.currentUser?.id;
    _visitId = widget.repository.visits
        .where((visit) => visit.supervisorId == currentUserId)
        .firstOrNull
        ?.id;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supervisorId = widget.repository.currentUser?.id;
    final visits = widget.repository.visits
        .where((visit) => visit.supervisorId == supervisorId)
        .toList();
    return Scaffold(
      backgroundColor: AppColors.baldosa,
      appBar: AppBar(title: const Text('Registrar novedad')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _visitId,
                decoration: const InputDecoration(labelText: 'Visita'),
                items: visits
                    .map(
                      (visit) => DropdownMenuItem(
                        value: visit.id,
                        child: Text(
                          visit.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _visitId = value),
                validator: (value) => value == null
                    ? 'No hay visitas disponibles para asociar.'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Título de la novedad',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Escribe un título.'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _description,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Describe la novedad.'
                    : null,
              ),
              const SizedBox(height: 14),
              Text(
                'Prioridad de la novedad',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Alta', 'Media', 'Baja']
                    .map(
                      (value) => ChoiceChip(
                        label: Text(value),
                        selected: _priority == value,
                        onSelected: (_) => setState(() => _priority = value),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
              HazardTag(priority: _priority),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(
                  _photoPath != null
                      ? 'Fotografía adjunta'
                      : Platform.isLinux ||
                            Platform.isWindows ||
                            Platform.isMacOS
                      ? 'Seleccionar fotografía'
                      : 'Tomar fotografía',
                ),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'Guardar novedad',
                icon: Icons.save_outlined,
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    try {
      final image = await ImagePicker().pickImage(
        source: Platform.isLinux || Platform.isWindows || Platform.isMacOS
            ? ImageSource.gallery
            : ImageSource.camera,
      );
      if (image == null) return;
      final path =
          '${Directory.systemTemp.path}/suthon-novedad-${DateTime.now().microsecondsSinceEpoch}.jpg';
      final compressed = await FlutterImageCompress.compressAndGetFile(
        image.path,
        path,
        minWidth: 800,
        minHeight: 800,
        quality: 70,
      );
      if (compressed == null) {
        throw StateError('No fue posible comprimir la fotografía.');
      }
      final savedPath = await widget.repository.saveEvidence(compressed.path);
      if (mounted) setState(() => _photoPath = savedPath);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No fue posible adjuntar la foto: $error')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      widget.repository.createIncident(
        _visitId!,
        _title.text,
        _description.text,
        priority: _priority,
        photoPath: _photoPath,
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No fue posible guardar la novedad: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
