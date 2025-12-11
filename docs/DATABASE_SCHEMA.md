# Serfix Database Schema

## Overview

This document outlines the Supabase database schema for Serfix - a cervical cancer screening application. This is the **initial/MVP version** focused on getting core functionality working.

---

## Tables

### 1. `profiles` (Doctors)

Extends Supabase Auth users with doctor-specific information.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `uuid` | PK, FK → auth.users(id) | Links to Supabase Auth |
| `email` | `text` | NOT NULL | Doctor's email |
| `username` | `text` | NOT NULL, UNIQUE | Display username |
| `full_name` | `text` | NOT NULL | Full name with title (e.g., "Dr. John Doe") |
| `license_number` | `text` | | Medical license number |
| `avatar_url` | `text` | | Profile picture URL |
| `created_at` | `timestamptz` | DEFAULT now() | Account creation time |
| `updated_at` | `timestamptz` | DEFAULT now() | Last profile update |

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  username TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL,
  license_number TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

---

### 2. `screenings`

Main table storing each screening session.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | Unique screening ID |
| `doctor_id` | `uuid` | FK → profiles(id), NOT NULL | Doctor who performed screening |
| `patient_identifier` | `text` | | Optional patient ID/code (anonymized) |
| `patient_age` | `integer` | | Patient's age (optional) |
| `notes` | `text` | | Doctor's notes |
| `image_url` | `text` | NOT NULL | URL to uploaded cervical image |
| `status` | `text` | DEFAULT 'pending' | 'pending', 'processing', 'completed', 'failed' |
| `created_at` | `timestamptz` | DEFAULT now() | When screening was created |
| `updated_at` | `timestamptz` | DEFAULT now() | Last update time |

```sql
CREATE TABLE screenings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  doctor_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  patient_identifier TEXT,
  patient_age INTEGER,
  notes TEXT,
  image_url TEXT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

---

### 3. `screening_results`

Stores AI inference results for each screening.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | Unique result ID |
| `screening_id` | `uuid` | FK → screenings(id), NOT NULL, UNIQUE | Links to screening |
| `classification` | `text` | NOT NULL | 'normal', 'abnormal', 'inconclusive' |
| `confidence` | `decimal(5,4)` | | Model confidence score (0.0000 - 1.0000) |
| `detections` | `jsonb` | | Array of detected regions/objects |
| `result_image_url` | `text` | | URL to annotated/segmented image |
| `model_version` | `text` | | AI model version used |
| `inference_time_ms` | `integer` | | Processing time in milliseconds |
| `created_at` | `timestamptz` | DEFAULT now() | When result was created |

```sql
CREATE TABLE screening_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  screening_id UUID NOT NULL UNIQUE REFERENCES screenings(id) ON DELETE CASCADE,
  classification TEXT NOT NULL CHECK (classification IN ('normal', 'abnormal', 'inconclusive')),
  confidence DECIMAL(5,4),
  detections JSONB,
  result_image_url TEXT,
  model_version TEXT,
  inference_time_ms INTEGER,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

**Example `detections` JSONB structure:**
```json
[
  {
    "label": "lesion",
    "confidence": 0.92,
    "bbox": [120, 80, 200, 160],
    "severity": "high"
  },
  {
    "label": "abnormal_cells",
    "confidence": 0.78,
    "bbox": [50, 100, 90, 140],
    "severity": "medium"
  }
]
```

---

## Storage Buckets

### 1. `screening-images`
- **Purpose:** Store original cervical images uploaded by doctors
- **Access:** Private (authenticated doctors only)
- **File naming:** `{doctor_id}/{screening_id}/original.jpg`

### 2. `result-images`
- **Purpose:** Store AI-annotated/segmented result images
- **Access:** Private (authenticated doctors only)
- **File naming:** `{doctor_id}/{screening_id}/result.jpg`

```sql
-- Create storage buckets (run in Supabase SQL editor)
INSERT INTO storage.buckets (id, name, public) VALUES ('screening-images', 'screening-images', false);
INSERT INTO storage.buckets (id, name, public) VALUES ('result-images', 'result-images', false);
```

---

## Row Level Security (RLS) Policies

### Profiles Table

```sql
-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Users can read their own profile
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Users can insert their own profile (on signup)
CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);
```

### Screenings Table

```sql
-- Enable RLS
ALTER TABLE screenings ENABLE ROW LEVEL SECURITY;

-- Doctors can view their own screenings
CREATE POLICY "Doctors can view own screenings"
  ON screenings FOR SELECT
  USING (auth.uid() = doctor_id);

-- Doctors can create screenings
CREATE POLICY "Doctors can create screenings"
  ON screenings FOR INSERT
  WITH CHECK (auth.uid() = doctor_id);

-- Doctors can update their own screenings
CREATE POLICY "Doctors can update own screenings"
  ON screenings FOR UPDATE
  USING (auth.uid() = doctor_id);

-- Doctors can delete their own screenings
CREATE POLICY "Doctors can delete own screenings"
  ON screenings FOR DELETE
  USING (auth.uid() = doctor_id);
```

### Screening Results Table

```sql
-- Enable RLS
ALTER TABLE screening_results ENABLE ROW LEVEL SECURITY;

-- Doctors can view results for their screenings
CREATE POLICY "Doctors can view own screening results"
  ON screening_results FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM screenings
      WHERE screenings.id = screening_results.screening_id
      AND screenings.doctor_id = auth.uid()
    )
  );

-- Allow insert from service role (for AI backend to insert results)
-- This will be done via service_role key from backend
CREATE POLICY "Service can insert results"
  ON screening_results FOR INSERT
  WITH CHECK (true);  -- Restricted by service_role key usage
```

### Storage Policies

```sql
-- Screening images bucket
CREATE POLICY "Doctors can upload screening images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'screening-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Doctors can view own screening images"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'screening-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Result images bucket
CREATE POLICY "Doctors can view own result images"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'result-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Service role can upload result images (from AI backend)
CREATE POLICY "Service can upload result images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'result-images');
```

---

## Database Functions & Triggers

### Auto-update `updated_at` timestamp

```sql
-- Function to update timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for profiles
CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Trigger for screenings
CREATE TRIGGER screenings_updated_at
  BEFORE UPDATE ON screenings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
```

### Auto-create profile on signup

```sql
-- Function to create profile from auth.users
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, username, full_name, license_number)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'username',
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'license_number'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users insert
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();
```

### Update screening status when result is added

```sql
-- Function to update screening status
CREATE OR REPLACE FUNCTION update_screening_on_result()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE screenings
  SET status = 'completed', updated_at = now()
  WHERE id = NEW.screening_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on screening_results insert
CREATE TRIGGER on_result_created
  AFTER INSERT ON screening_results
  FOR EACH ROW
  EXECUTE FUNCTION update_screening_on_result();
```

---

## Indexes

```sql
-- For faster lookups
CREATE INDEX idx_screenings_doctor_id ON screenings(doctor_id);
CREATE INDEX idx_screenings_status ON screenings(status);
CREATE INDEX idx_screenings_created_at ON screenings(created_at DESC);
CREATE INDEX idx_screening_results_screening_id ON screening_results(screening_id);
```

---

## App Flow Summary

```
1. Doctor signs up
   └── auth.users created
   └── trigger: profiles row auto-created

2. Doctor captures image
   └── Image uploaded to 'screening-images' bucket
   └── New row in 'screenings' (status: 'pending')

3. AI processes image
   └── App sends image URL to AI endpoint
   └── Screening status updated to 'processing'

4. AI returns result
   └── Result image uploaded to 'result-images' bucket
   └── New row in 'screening_results'
   └── trigger: screening status → 'completed'

5. Doctor views result
   └── Fetch screening + screening_results
   └── Display annotated image and classification
```

---

## Future Enhancements (Not in MVP)

- [ ] `patients` table for proper patient management
- [ ] `screening_history` for tracking re-screenings of same patient
- [ ] Doctor verification/approval workflow
- [ ] Multi-clinic support with `organizations` table
- [ ] Audit logging for compliance
- [ ] Report generation and export

---

## Quick Setup Script

Run this complete SQL in Supabase SQL Editor:

```sql
-- ============================================
-- SERFIX DATABASE SETUP - MVP VERSION
-- ============================================

-- 1. Create tables
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  username TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL,
  license_number TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE screenings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  doctor_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  patient_identifier TEXT,
  patient_age INTEGER,
  notes TEXT,
  image_url TEXT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE screening_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  screening_id UUID NOT NULL UNIQUE REFERENCES screenings(id) ON DELETE CASCADE,
  classification TEXT NOT NULL CHECK (classification IN ('normal', 'abnormal', 'inconclusive')),
  confidence DECIMAL(5,4),
  detections JSONB,
  result_image_url TEXT,
  model_version TEXT,
  inference_time_ms INTEGER,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Create indexes
CREATE INDEX idx_screenings_doctor_id ON screenings(doctor_id);
CREATE INDEX idx_screenings_status ON screenings(status);
CREATE INDEX idx_screenings_created_at ON screenings(created_at DESC);
CREATE INDEX idx_screening_results_screening_id ON screening_results(screening_id);

-- 3. Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE screenings ENABLE ROW LEVEL SECURITY;
ALTER TABLE screening_results ENABLE ROW LEVEL SECURITY;

-- 4. Profiles policies
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- 5. Screenings policies
CREATE POLICY "Doctors can view own screenings" ON screenings FOR SELECT USING (auth.uid() = doctor_id);
CREATE POLICY "Doctors can create screenings" ON screenings FOR INSERT WITH CHECK (auth.uid() = doctor_id);
CREATE POLICY "Doctors can update own screenings" ON screenings FOR UPDATE USING (auth.uid() = doctor_id);
CREATE POLICY "Doctors can delete own screenings" ON screenings FOR DELETE USING (auth.uid() = doctor_id);

-- 6. Screening results policies
CREATE POLICY "Doctors can view own screening results" ON screening_results FOR SELECT
  USING (EXISTS (SELECT 1 FROM screenings WHERE screenings.id = screening_results.screening_id AND screenings.doctor_id = auth.uid()));
CREATE POLICY "Service can insert results" ON screening_results FOR INSERT WITH CHECK (true);

-- 7. Functions
CREATE OR REPLACE FUNCTION update_updated_at() RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION handle_new_user() RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, username, full_name, license_number)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'username', NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'license_number');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION update_screening_on_result() RETURNS TRIGGER AS $$
BEGIN
  UPDATE screenings SET status = 'completed', updated_at = now() WHERE id = NEW.screening_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Triggers
CREATE TRIGGER profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER screenings_updated_at BEFORE UPDATE ON screenings FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_new_user();
CREATE TRIGGER on_result_created AFTER INSERT ON screening_results FOR EACH ROW EXECUTE FUNCTION update_screening_on_result();

-- 9. Storage buckets
INSERT INTO storage.buckets (id, name, public) VALUES ('screening-images', 'screening-images', false);
INSERT INTO storage.buckets (id, name, public) VALUES ('result-images', 'result-images', false);

-- 10. Storage policies
CREATE POLICY "Doctors can upload screening images" ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'screening-images' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Doctors can view own screening images" ON storage.objects FOR SELECT
  USING (bucket_id = 'screening-images' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Doctors can view own result images" ON storage.objects FOR SELECT
  USING (bucket_id = 'result-images' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Service can upload result images" ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'result-images');
```

---

*Last updated: Initial MVP version*
