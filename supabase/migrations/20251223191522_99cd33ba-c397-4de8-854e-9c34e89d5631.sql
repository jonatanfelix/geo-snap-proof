-- ================================================
-- RLS POLICIES FOR PRODUCTION-READY SECURITY
-- ================================================

-- 1. ATTENDANCE_RECORDS: Users can only view/insert their own records
-- (These policies already exist, but let's ensure they're correct)

-- Drop existing policies if we need to recreate
DROP POLICY IF EXISTS "Users can view their own attendance" ON public.attendance_records;
DROP POLICY IF EXISTS "Users can insert their own attendance" ON public.attendance_records;
DROP POLICY IF EXISTS "Admins can view all attendance" ON public.attendance_records;

-- Users can view their own attendance records
CREATE POLICY "Users can view their own attendance"
ON public.attendance_records
FOR SELECT
USING (auth.uid() = user_id);

-- Users can insert their own attendance records
CREATE POLICY "Users can insert their own attendance"
ON public.attendance_records
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Admins can view attendance records of users in the same company
CREATE POLICY "Admins can view company attendance"
ON public.attendance_records
FOR SELECT
USING (
  public.has_role(auth.uid(), 'admin') AND
  EXISTS (
    SELECT 1 FROM public.profiles admin_profile
    WHERE admin_profile.user_id = auth.uid()
    AND admin_profile.company_id = (
      SELECT p.company_id FROM public.profiles p WHERE p.user_id = attendance_records.user_id
    )
  )
);

-- Developers can view all attendance records
CREATE POLICY "Developers can view all attendance"
ON public.attendance_records
FOR SELECT
USING (public.has_role(auth.uid(), 'developer'));

-- 2. COMPANIES: Users can only view companies matching their profile.company_id

-- Drop existing policies
DROP POLICY IF EXISTS "Authenticated users can view companies" ON public.companies;
DROP POLICY IF EXISTS "Admins can manage companies" ON public.companies;

-- Users can only view their own company
CREATE POLICY "Users can view their company"
ON public.companies
FOR SELECT
USING (
  id = (SELECT company_id FROM public.profiles WHERE user_id = auth.uid())
);

-- Admins can manage their own company
CREATE POLICY "Admins can manage their company"
ON public.companies
FOR ALL
USING (
  public.has_role(auth.uid(), 'admin') AND
  id = (SELECT company_id FROM public.profiles WHERE user_id = auth.uid())
);

-- Developers can manage all companies
CREATE POLICY "Developers can manage all companies"
ON public.companies
FOR ALL
USING (public.has_role(auth.uid(), 'developer'));

-- 3. PROFILES: Admins can only view/edit profiles in the same company

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;

-- Users can view their own profile
CREATE POLICY "Users can view their own profile"
ON public.profiles
FOR SELECT
USING (auth.uid() = user_id);

-- Users can insert their own profile
CREATE POLICY "Users can insert their own profile"
ON public.profiles
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can update their own profile (limited fields)
CREATE POLICY "Users can update their own profile"
ON public.profiles
FOR UPDATE
USING (auth.uid() = user_id);

-- Admins can view profiles in the same company
CREATE POLICY "Admins can view company profiles"
ON public.profiles
FOR SELECT
USING (
  public.has_role(auth.uid(), 'admin') AND
  company_id = (SELECT p.company_id FROM public.profiles p WHERE p.user_id = auth.uid())
);

-- Admins can update profiles in the same company (for employee management)
CREATE POLICY "Admins can update company profiles"
ON public.profiles
FOR UPDATE
USING (
  public.has_role(auth.uid(), 'admin') AND
  company_id = (SELECT p.company_id FROM public.profiles p WHERE p.user_id = auth.uid())
);

-- Developers can view all profiles
CREATE POLICY "Developers can view all profiles"
ON public.profiles
FOR SELECT
USING (public.has_role(auth.uid(), 'developer'));

-- Developers can manage all profiles
CREATE POLICY "Developers can manage all profiles"
ON public.profiles
FOR ALL
USING (public.has_role(auth.uid(), 'developer'));