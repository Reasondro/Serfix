import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serfix/app/routing/routes.dart';
import 'package:serfix/core/extensions/snackbar_extension.dart';
import 'package:serfix/features/doctor/screening/presentation/cubit/screening_cubit.dart';

class DoctorCaptureScreen extends StatefulWidget {
  const DoctorCaptureScreen({super.key});

  @override
  State<DoctorCaptureScreen> createState() => _DoctorCaptureScreenState();
}

class _DoctorCaptureScreenState extends State<DoctorCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  bool _isUploading = false;
  bool _isCompressing = false;
  int? _originalSize;
  int? _compressedSize;

  final _patientIdController = TextEditingController();
  final _patientAgeController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _patientIdController.dispose();
    _patientAgeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 100, // Get full quality, we'll compress it ourselves
      );

      if (image != null) {
        setState(() => _isCompressing = true);

        final originalFile = File(image.path);
        _originalSize = await originalFile.length();

        // Compress the image
        final compressedFile = await _compressImage(originalFile);

        if (compressedFile != null) {
          _compressedSize = await compressedFile.length();
          setState(() {
            _selectedImage = compressedFile;
            _isCompressing = false;
          });
        } else {
          // Fallback to original if compression fails
          setState(() {
            _selectedImage = originalFile;
            _compressedSize = _originalSize;
            _isCompressing = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isCompressing = false);
      if (mounted) {
        context.showErrorSnackBar('Failed to pick image: $e');
      }
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final filePath = file.path;
      final lastIndex = filePath.lastIndexOf(RegExp(r'.jp|.png'));
      final splitPath = filePath.substring(0, lastIndex);
      final outPath = '${splitPath}_compressed.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: 70,
        minWidth: 1200,
        minHeight: 1200,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        return File(result.path);
      }
      return null;
    } catch (e) {
      debugPrint('Image compression failed: $e');
      return null;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _uploadScreening() async {
    if (_selectedImage == null) {
      context.showErrorSnackBar('Please select an image first');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isUploading = true);

    try {
      await context.read<ScreeningCubit>().createScreening(
            imageFile: _selectedImage!,
            patientIdentifier: _patientIdController.text.isNotEmpty
                ? _patientIdController.text.trim()
                : null,
            patientAge: _patientAgeController.text.isNotEmpty
                ? int.tryParse(_patientAgeController.text.trim())
                : null,
            notes: _notesController.text.isNotEmpty
                ? _notesController.text.trim()
                : null,
          );

      if (mounted) {
        context.showSuccessSnackBar('Screening created successfully');
        // Reset form
        setState(() {
          _selectedImage = null;
          _originalSize = null;
          _compressedSize = null;
          _patientIdController.clear();
          _patientAgeController.clear();
          _notesController.clear();
        });
        // Navigate to screenings
        context.go(Routes.doctorScreenings);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to create screening: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<ScreeningCubit, ScreeningState>(
      listener: (context, state) {
        if (state is ScreeningError) {
          context.showErrorSnackBar(state.message);
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview / Capture Area
              GestureDetector(
                onTap: _isUploading || _isCompressing
                    ? null
                    : () => _showImageSourceDialog(),
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: _selectedImage != null
                        ? colorScheme.surfaceContainerHighest
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedImage != null
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      width: _selectedImage != null ? 2 : 1,
                    ),
                  ),
                  child: _isCompressing
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Compressing image...',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        )
                      : _selectedImage != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    onPressed: _isUploading
                                        ? null
                                        : () => setState(
                                            () => _selectedImage = null),
                                    icon: const Icon(Icons.close),
                                    style: IconButton.styleFrom(
                                      backgroundColor: colorScheme.surface,
                                      foregroundColor: colorScheme.error,
                                    ),
                                  ),
                                ),
                                // Compression info badge
                                if (_originalSize != null &&
                                    _compressedSize != null)
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surface
                                            .withAlpha(230),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.compress,
                                            size: 14,
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${_formatFileSize(_originalSize!)} → ${_formatFileSize(_compressedSize!)}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: colorScheme.onSurface,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 48,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tap to capture or select image',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'For best results, ensure good lighting',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant
                                        .withAlpha(180),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick capture buttons
              if (_selectedImage == null && !_isCompressing)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // Patient Information Section
              Text(
                'Patient Information (Optional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 16),

              // Patient ID
              TextFormField(
                controller: _patientIdController,
                enabled: !_isUploading,
                decoration: InputDecoration(
                  labelText: 'Patient ID',
                  hintText: 'Enter patient identifier',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 2) {
                    return 'Patient ID must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Patient Age
              TextFormField(
                controller: _patientAgeController,
                enabled: !_isUploading,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: InputDecoration(
                  labelText: 'Patient Age',
                  hintText: 'Enter patient age',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final age = int.tryParse(value);
                    if (age == null) {
                      return 'Please enter a valid age';
                    }
                    if (age < 1 || age > 120) {
                      return 'Age must be between 1 and 120';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                enabled: !_isUploading,
                maxLines: 3,
                maxLength: 500,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Add any relevant notes...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 48),
                    child: Icon(Icons.notes_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
              ),

              const SizedBox(height: 24),

              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha(60),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withAlpha(77),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The image will be sent for AI analysis. Results will appear in the Screenings tab.',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed:
                    _selectedImage != null && !_isUploading && !_isCompressing
                        ? _uploadScreening
                        : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Text(
                        'Create Screening',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select Image Source',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.camera_alt, color: colorScheme.primary),
                ),
                title: const Text('Camera'),
                subtitle: const Text('Take a new photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(Icons.photo_library, color: colorScheme.secondary),
                ),
                title: const Text('Gallery'),
                subtitle: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
