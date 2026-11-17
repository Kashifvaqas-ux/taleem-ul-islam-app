-- Taleem ul Islam Senior Secondary School portal
-- Run this in Supabase SQL Editor using the school's authorised administrator account.
-- Do not expose a service_role key in browser code.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  role text not null default 'student' check (role in ('student','teacher','admin')),
  class_group text,
  created_at timestamptz not null default now()
);

create table if not exists public.school_entries (
  id uuid primary key default gen_random_uuid(),
  entry_type text not null check (entry_type in ('Classes','Classwork','Attendance','Homework','Events','Competitions','Exams','Notices','Notes')),
  title text not null,
  details text,
  entry_date date not null,
  start_time time,
  status text not null default 'Scheduled',
  class_group text,
  scope text not null default 'school' check (scope in ('school','class','student')),
  student_id uuid references public.profiles(id) on delete cascade,
  created_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint student_scope_requires_student check (scope <> 'student' or student_id is not null)
);

create table if not exists public.homework_submissions (
  id uuid primary key default gen_random_uuid(),
  entry_id uuid not null references public.school_entries(id) on delete cascade,
  student_id uuid not null references public.profiles(id) on delete cascade,
  submission_text text,
  submitted_at timestamptz,
  status text not null default 'Not submitted' check (status in ('Not submitted','Submitted','Reviewed')),
  teacher_feedback text,
  created_at timestamptz not null default now(),
  unique(entry_id, student_id)
);

create index if not exists school_entries_date_idx on public.school_entries(entry_date);
create index if not exists school_entries_type_idx on public.school_entries(entry_type);
create index if not exists school_entries_class_idx on public.school_entries(class_group);
create index if not exists homework_submissions_student_idx on public.homework_submissions(student_id);

alter table public.profiles enable row level security;
alter table public.school_entries enable row level security;
alter table public.homework_submissions enable row level security;

create or replace function public.current_role()
returns text language sql stable security definer set search_path = public
as $$ select role from public.profiles where id = auth.uid() $$;

create or replace function public.current_class()
returns text language sql stable security definer set search_path = public
as $$ select class_group from public.profiles where id = auth.uid() $$;

create or replace function public.is_school_staff()
returns boolean language sql stable security definer set search_path = public
as $$ select coalesce(public.current_role() in ('teacher','admin'), false) $$;

drop policy if exists "profile self or staff read" on public.profiles;
create policy "profile self or staff read" on public.profiles for select to authenticated
using (id = auth.uid() or public.is_school_staff());

drop policy if exists "profile self update limited" on public.profiles;
create policy "profile self update limited" on public.profiles for update to authenticated
using (id = auth.uid()) with check (id = auth.uid() and role = public.current_role());

drop policy if exists "entries visible by scope" on public.school_entries;
create policy "entries visible by scope" on public.school_entries for select to authenticated
using (
  public.is_school_staff()
  or scope = 'school'
  or (scope = 'class' and class_group = public.current_class())
  or (scope = 'student' and student_id = auth.uid())
);

drop policy if exists "staff create entries" on public.school_entries;
create policy "staff create entries" on public.school_entries for insert to authenticated
with check (public.is_school_staff() and created_by = auth.uid());

drop policy if exists "staff update entries" on public.school_entries;
create policy "staff update entries" on public.school_entries for update to authenticated
using (public.is_school_staff())
with check (public.is_school_staff());

drop policy if exists "staff delete entries" on public.school_entries;
create policy "staff delete entries" on public.school_entries for delete to authenticated
using (public.is_school_staff());

drop policy if exists "student and staff read submissions" on public.homework_submissions;
create policy "student and staff read submissions" on public.homework_submissions for select to authenticated
using (student_id = auth.uid() or public.is_school_staff());

drop policy if exists "student submit own homework" on public.homework_submissions;
create policy "student submit own homework" on public.homework_submissions for insert to authenticated
with check (student_id = auth.uid());

drop policy if exists "student update own unreviewed submission" on public.homework_submissions;
create policy "student update own unreviewed submission" on public.homework_submissions for update to authenticated
using (student_id = auth.uid() and status <> 'Reviewed')
with check (student_id = auth.uid());

drop policy if exists "staff review submissions" on public.homework_submissions;
create policy "staff review submissions" on public.homework_submissions for update to authenticated
using (public.is_school_staff()) with check (public.is_school_staff());

-- IMPORTANT ACCOUNT SETUP:
-- 1) Create/invite users in Supabase Authentication > Users (disable public sign-ups).
-- 2) Add a matching profile row for each user ID.
-- 3) Set role to student, teacher, or admin only after verifying their identity/authority.
-- Example (replace values):
-- insert into public.profiles(id, full_name, role, class_group)
-- values ('AUTH-USER-UUID', 'Student Name', 'student', 'Class 9-A');
-- Never make someone an admin just because they request access.
