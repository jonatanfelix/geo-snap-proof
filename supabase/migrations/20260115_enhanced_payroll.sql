-- Enhanced Payroll System Migration
-- Adds support for BPJS, PPh 21, and custom payroll components

-- 1. Add BPJS and tax configuration to companies table
ALTER TABLE companies 
ADD COLUMN IF NOT EXISTS bpjs_kesehatan_employee_rate DECIMAL(5,2) DEFAULT 1.0,
ADD COLUMN IF NOT EXISTS bpjs_kesehatan_employer_rate DECIMAL(5,2) DEFAULT 4.0,
ADD COLUMN IF NOT EXISTS bpjs_tk_jht_employee_rate DECIMAL(5,2) DEFAULT 2.0,
ADD COLUMN IF NOT EXISTS bpjs_tk_jht_employer_rate DECIMAL(5,2) DEFAULT 3.7,
ADD COLUMN IF NOT EXISTS bpjs_tk_jp_employee_rate DECIMAL(5,2) DEFAULT 1.0,
ADD COLUMN IF NOT EXISTS bpjs_tk_jp_employer_rate DECIMAL(5,2) DEFAULT 2.0,
ADD COLUMN IF NOT EXISTS ptkp_status_default TEXT DEFAULT 'TK/0',
ADD COLUMN IF NOT EXISTS use_pph21_calculation BOOLEAN DEFAULT false;

-- Comments for BPJS columns
COMMENT ON COLUMN companies.bpjs_kesehatan_employee_rate IS 'BPJS Kesehatan employee contribution rate (%)';
COMMENT ON COLUMN companies.bpjs_kesehatan_employer_rate IS 'BPJS Kesehatan employer contribution rate (%)';
COMMENT ON COLUMN companies.bpjs_tk_jht_employee_rate IS 'BPJS TK JHT (Jaminan Hari Tua) employee rate (%)';
COMMENT ON COLUMN companies.bpjs_tk_jht_employer_rate IS 'BPJS TK JHT employer rate (%)';
COMMENT ON COLUMN companies.bpjs_tk_jp_employee_rate IS 'BPJS TK JP (Jaminan Pensiun) employee rate (%)';
COMMENT ON COLUMN companies.bpjs_tk_jp_employer_rate IS 'BPJS TK JP employer rate (%)';
COMMENT ON COLUMN companies.ptkp_status_default IS 'Default PTKP status for new employees';
COMMENT ON COLUMN companies.use_pph21_calculation IS 'Enable PPh 21 tax calculation';

-- 2. Add salary and tax fields to profiles table
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS base_salary DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS ptkp_status TEXT DEFAULT 'TK/0';

COMMENT ON COLUMN profiles.base_salary IS 'Employee base monthly salary';
COMMENT ON COLUMN profiles.ptkp_status IS 'PTKP status for PPh 21 calculation (TK/0, K/0, K/1, etc.)';

-- 3. Create payroll_components table for allowances and deductions
CREATE TABLE IF NOT EXISTS payroll_components (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('allowance', 'deduction')),
  amount_type TEXT NOT NULL CHECK (amount_type IN ('fixed', 'percentage')),
  amount DECIMAL(15,2) NOT NULL,
  is_taxable BOOLEAN DEFAULT false,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE payroll_components IS 'Reusable payroll component templates (allowances and deductions)';
COMMENT ON COLUMN payroll_components.type IS 'Component type: allowance or deduction';
COMMENT ON COLUMN payroll_components.amount_type IS 'Fixed amount or percentage of base salary';
COMMENT ON COLUMN payroll_components.is_taxable IS 'Whether this component affects taxable income';

-- 4. Create employee_payroll_components table for assignments
CREATE TABLE IF NOT EXISTS employee_payroll_components (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  component_id UUID REFERENCES payroll_components(id) ON DELETE CASCADE,
  custom_amount DECIMAL(15,2), -- Override component amount if needed
  effective_from DATE NOT NULL,
  effective_to DATE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE employee_payroll_components IS 'Links employees to payroll components with date ranges';
COMMENT ON COLUMN employee_payroll_components.custom_amount IS 'Override amount if different from component template';
COMMENT ON COLUMN employee_payroll_components.effective_from IS 'Start date for this component assignment';
COMMENT ON COLUMN employee_payroll_components.effective_to IS 'End date (NULL = ongoing)';

-- 5. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_payroll_components_company ON payroll_components(company_id);
CREATE INDEX IF NOT EXISTS idx_payroll_components_active ON payroll_components(is_active);
CREATE INDEX IF NOT EXISTS idx_employee_payroll_components_user ON employee_payroll_components(user_id);
CREATE INDEX IF NOT EXISTS idx_employee_payroll_components_dates ON employee_payroll_components(effective_from, effective_to);

-- 6. Enable RLS on new tables
ALTER TABLE payroll_components ENABLE ROW LEVEL SECURITY;
ALTER TABLE employee_payroll_components ENABLE ROW LEVEL SECURITY;

-- 7. RLS Policies for payroll_components
CREATE POLICY "Admins can manage payroll components"
  ON payroll_components
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role IN ('admin', 'developer')
    )
  );

CREATE POLICY "Employees can view payroll components"
  ON payroll_components
  FOR SELECT
  TO authenticated
  USING (is_active = true);

-- 8. RLS Policies for employee_payroll_components
CREATE POLICY "Admins can manage employee payroll components"
  ON employee_payroll_components
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role IN ('admin', 'developer')
    )
  );

CREATE POLICY "Employees can view own payroll components"
  ON employee_payroll_components
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());
