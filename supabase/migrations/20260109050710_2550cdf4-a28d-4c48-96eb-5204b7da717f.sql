-- Drop the existing check constraint and add a new one that includes break types
ALTER TABLE public.attendance_records DROP CONSTRAINT IF EXISTS attendance_records_record_type_check;

ALTER TABLE public.attendance_records ADD CONSTRAINT attendance_records_record_type_check 
  CHECK (record_type IN ('clock_in', 'clock_out', 'break_out', 'break_in'));