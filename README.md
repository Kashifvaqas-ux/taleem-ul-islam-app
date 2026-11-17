# Taleem ul Islam Senior Secondary School App

This is a **starter project** for an official shared school portal. It includes a mobile-friendly web interface, role-aware publishing controls, a Supabase database schema with Row Level Security (RLS), and the original task manager page retained as `task-manager.html`.

## Included sections
- Today's classes
- Classwork
- Attendance
- Homework
- Events
- Competitions
- Exams & results
- Notices
- Study notes

## Important: school approval and privacy
This is not yet a live official school service. Before collecting real student information, the school administration must approve the project, choose an authorised operator, set its privacy/retention rules, and verify staff/student accounts. Do not upload real student names, attendance, grades, phone numbers, addresses, or other private information to a public repository.

## 1. Create the shared database
1. An authorised school administrator creates a Supabase project at https://supabase.com/.
2. Open the project's SQL Editor.
3. Run the complete contents of `supabase/schema.sql`.
4. In Authentication settings, disable public sign-ups. Accounts should be invited/created only by authorised school staff.
5. Create the first administrator account in Supabase Authentication. Copy that user's UUID.
6. Add the administrator profile using SQL:
   ```sql
   insert into public.profiles(id, full_name, role, class_group)
   values ('PASTE-AUTH-USER-UUID', 'School Administrator', 'admin', null);
   ```
7. Invite each teacher/student through the school's approved process, then add a matching `profiles` row. Use role `teacher` or `student`; assign the correct `class_group` to students.

## 2. Connect the website
1. In Supabase Project Settings > API, copy the Project URL and the public anon/publishable key.
2. Open `index.html` in a code editor.
3. Replace `YOUR_SUPABASE_PROJECT_URL` and `YOUR_SUPABASE_ANON_KEY`.
4. Never paste a `service_role` or secret key into `index.html`, GitHub, or any browser code.

## 3. Test safely before real use
- Use test accounts and fictional records first.
- Test that a student can only see school-wide, their class, and their own student-scoped records.
- Test that students cannot create/edit/delete school notices, attendance or other official records.
- Test teacher/admin permissions with separate accounts.
- Have the school's responsible administrator or a qualified developer review the database policies before launch.

## 4. Publish
You can host the static website on GitHub Pages after connecting the Supabase URL and public key. Keep `index.html` and `supabase/` in the repository. Do not upload private student data or database secrets. Use HTTPS.

## Current starter limitations
- The interface currently lists and lets staff manage shared school entries. The homework submission table is prepared in the database, but a student submission/teacher grading screen still needs to be added.
- Attendance is represented as school entries in this starter; a full attendance register with per-student daily roll-call, correction approvals and reports is a next development stage.
- Fees, transport, parent accounts, messaging, push notifications, downloadable report cards, timetable recurrence and audit logs are not included yet.
- The existing task manager is retained separately in `task-manager.html`; it has its own local browser storage and is not yet synced to school accounts.

A school's official app should be launched only after the school approves it and tests access controls with sample accounts.
