import 'dart:io';

import 'package:serfix/features/doctor/screening/domain/entities/screening.dart';
import 'package:serfix/features/doctor/screening/domain/repositories/screening_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseScreeningRepository implements ScreeningRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  String get _userId => _supabase.auth.currentUser!.id;

  @override
  Future<List<Screening>> getScreenings() async {
    final response = await _supabase
        .from('screenings')
        .select('*, screening_results(*)')
        .eq('doctor_id', _userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Screening.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Screening?> getScreeningById(String id) async {
    final response = await _supabase
        .from('screenings')
        .select('*, screening_results(*)')
        .eq('id', id)
        .eq('doctor_id', _userId)
        .maybeSingle();

    if (response == null) return null;
    return Screening.fromJson(response);
  }

  @override
  Future<List<Screening>> getScreeningsByStatus(ScreeningStatus status) async {
    final response = await _supabase
        .from('screenings')
        .select('*, screening_results(*)')
        .eq('doctor_id', _userId)
        .eq('status', status.name)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Screening.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ScreeningStats> getScreeningStats() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));

    // Get all screenings for stats calculation
    final response = await _supabase
        .from('screenings')
        .select('id, status, created_at, screening_results(classification)')
        .eq('doctor_id', _userId);

    final screenings = response as List;

    int todayCount = 0;
    int pendingCount = 0;
    int completedThisWeek = 0;
    int abnormalCount = 0;

    for (final s in screenings) {
      final createdAt = DateTime.parse(s['created_at'] as String);
      final status = s['status'] as String;

      // Today count
      if (createdAt.isAfter(todayStart)) {
        todayCount++;
      }

      // Pending count
      if (status == 'pending' || status == 'processing') {
        pendingCount++;
      }

      // Completed this week
      if (status == 'completed' && createdAt.isAfter(weekStart)) {
        completedThisWeek++;
      }

      // Abnormal count
      final results = s['screening_results'];
      if (results != null && results is List && results.isNotEmpty) {
        final classification = results.first['classification'];
        if (classification == 'abnormal') {
          abnormalCount++;
        }
      }
    }

    return ScreeningStats(
      todayCount: todayCount,
      pendingCount: pendingCount,
      completedThisWeek: completedThisWeek,
      abnormalCount: abnormalCount,
    );
  }

  @override
  Future<Screening> createScreening({
    required File imageFile,
    String? patientIdentifier,
    int? patientAge,
    String? notes,
  }) async {
    // Generate unique file path
    final fileExt = imageFile.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = '$_userId/$fileName';

    // Upload image to storage
    await _supabase.storage.from('screening-images').upload(
          filePath,
          imageFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    // Get public URL
    final imageUrl =
        _supabase.storage.from('screening-images').getPublicUrl(filePath);

    // Create screening record
    final response = await _supabase
        .from('screenings')
        .insert({
          'doctor_id': _userId,
          'patient_identifier': patientIdentifier,
          'patient_age': patientAge,
          'notes': notes,
          'image_url': imageUrl,
          'status': ScreeningStatus.pending.name,
        })
        .select('*, screening_results(*)')
        .single();

    return Screening.fromJson(response);
  }

  @override
  Future<Screening> updateScreening({
    required String id,
    String? patientIdentifier,
    int? patientAge,
    String? notes,
    ScreeningStatus? status,
  }) async {
    final updates = <String, dynamic>{};

    if (patientIdentifier != null) {
      updates['patient_identifier'] = patientIdentifier;
    }
    if (patientAge != null) updates['patient_age'] = patientAge;
    if (notes != null) updates['notes'] = notes;
    if (status != null) updates['status'] = status.name;

    final response = await _supabase
        .from('screenings')
        .update(updates)
        .eq('id', id)
        .eq('doctor_id', _userId)
        .select('*, screening_results(*)')
        .single();

    return Screening.fromJson(response);
  }

  @override
  Future<void> deleteScreening(String id) async {
    // Get the screening to find the image path
    final screening = await getScreeningById(id);
    if (screening == null) return;

    // Delete from database (cascade will delete results)
    await _supabase
        .from('screenings')
        .delete()
        .eq('id', id)
        .eq('doctor_id', _userId);

    // Try to delete the image from storage
    try {
      final uri = Uri.parse(screening.imageUrl);
      final pathSegments = uri.pathSegments;
      final storagePath = pathSegments
          .skipWhile((s) => s != 'screening-images')
          .skip(1)
          .join('/');
      if (storagePath.isNotEmpty) {
        await _supabase.storage.from('screening-images').remove([storagePath]);
      }
    } catch (_) {
      // Ignore storage deletion errors
    }
  }
}
