# Generate Analytics Sample Data for LAN Server

## Nag-generate na ko sang sample data sa development database!

Ang sample data generation script (`generate-analytics-sample-data.php`) nag-generate na sang:
- **472 exam attempts** (mga pag-take sang exam)
- **4,038 answers** (mga tubag sa questions)
- **44 active students**
- **Average score: 83.06%**
- Realistic score distribution (may low, average, kag high performers)
- Data spread over last 90 days para may trend analysis

## Para ma-generate ang data sa LAN server database:

### Option 1: Run ang script sa XAMPP (Recommended)

1. Open Command Prompt or PowerShell
2. Navigate sa XAMPP htdocs folder:
   ```
   cd C:\xampp\htdocs\Exam-Main
   ```

3. Run ang script:
   ```
   php generate-analytics-sample-data.php
   ```

### Option 2: Copy ang database

Kung gusto mo i-copy lang ang existing data:

1. Export ang development database:
   ```
   mysqldump -u root review_center_exam > analytics_data.sql
   ```

2. Import sa LAN server database:
   ```
   mysql -u root review_center_exam < analytics_data.sql
   ```

## Ano ang ma-generate:

✓ 20 sample students (kung wala pa)
✓ 1-3 exam attempts per student per exam
✓ Realistic score distribution:
  - 20% low performers (30-59%)
  - 60% average performers (60-85%)
  - 20% high performers (86-100%)
✓ Random dates over last 90 days
✓ Complete answer records for each attempt

## After generating data:

1. Login as admin sa LAN server
2. Go to Analytics page
3. May makita ka na nga actual charts kag data!

## Troubleshooting:

Kung may error:
- Make sure XAMPP MySQL is running
- Check kung naa ang backend folder sa htdocs/Exam-Main
- Verify database connection settings sa .env file

## Current Status:

✓ Sample data generated successfully sa development database
✓ Analytics API working with real data
✓ Backend server running at http://localhost:8000
✓ Ready to deploy to LAN server

Pwede na nimo i-test ang analytics dashboard sa development environment!
