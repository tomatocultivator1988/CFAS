# Database Schema Export

This folder contains a schema-only SQL export for the CFAS Review Center Examination System.

## File

- `review_center_exam_schema.sql`

## Purpose

Use this file when you want to create the database tables without importing existing users, exams, attempts, scores, or other live data.

## Import Example

Create the database first:

```sql
CREATE DATABASE review_center_exam CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Then import the schema:

```powershell
C:\xampp\mysql\bin\mysql.exe -u root review_center_exam < backend\database\schema\review_center_exam_schema.sql
```

After importing, create or seed an admin user before logging in.
