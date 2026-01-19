-- Add missing payroll and BPJS columns to companies table
ALTER TABLE public.companies
ADD COLUMN IF NOT EXISTS late_penalty_per_minute numeric DEFAULT 1000,
ADD COLUMN IF NOT EXISTS standard_work_hours integer DEFAULT 8,
ADD COLUMN IF NOT EXISTS bpjs_kesehatan_employee_rate numeric DEFAULT 1.0,
ADD COLUMN IF NOT EXISTS bpjs_kesehatan_employer_rate numeric DEFAULT 4.0,
ADD COLUMN IF NOT EXISTS bpjs_tk_jht_employee_rate numeric DEFAULT 2.0,
ADD COLUMN IF NOT EXISTS bpjs_tk_jht_employer_rate numeric DEFAULT 3.7,
ADD COLUMN IF NOT EXISTS bpjs_tk_jp_employee_rate numeric DEFAULT 1.0,
ADD COLUMN IF NOT EXISTS bpjs_tk_jp_employer_rate numeric DEFAULT 2.0,
ADD COLUMN IF NOT EXISTS ptkp_status_default text DEFAULT 'TK/0',
ADD COLUMN IF NOT EXISTS use_pph21_calculation boolean DEFAULT false;