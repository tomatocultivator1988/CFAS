# 📚 CFAS EXAM SYSTEM - FACULTY GUIDE
## Complete Guide para sa Faculty (Bisaya Version)

---

## 🎯 ANO INI NGA SYSTEM?

Ang **CFAS Exam System** isa ka online examination system para sa review center. Pwede mo ini gamiton para:
- Mag-create sang exam questions
- Mag-manage sang students (reviewees)
- Mag-conduct sang online exams
- Mag-view sang scores kag results
- Mag-export sang reports

---

## 🚀 PART 1: FIRST TIME SETUP

### Hakang 1: Install XAMPP (Kon wala pa)
1. Download XAMPP from: https://www.apachefriends.org
2. Install sa `C:\xampp`
3. I-run ang XAMPP Control Panel

### Hakang 2: Create Desktop Shortcut
1. Adto sa folder sang CFAS System
2. Double-click ang: `CREATE-DESKTOP-SHORTCUT-ULTIMATE.bat`
3. Makita mo ang icon sa desktop: **"CFAS Exam System"**

### Hakang 3: Test ang System
1. I-start ang XAMPP (Apache + MySQL)
2. Double-click ang desktop icon
3. Mag-open ang browser automatically
4. Try mag-login gamit ang admin account

---

## 💻 PART 2: DAILY USE (Kada Adlaw)

### Paano Mag-Start:

#### Hakang 1: Start XAMPP
1. Buksan ang **XAMPP Control Panel**
2. I-click ang **Start** button sa Apache (dapat mag-green)
3. I-click ang **Start** button sa MySQL (dapat mag-green)
4. Antay hasta mag-green ang duha

#### Hakang 2: Start CFAS System
1. Double-click ang **CFAS Exam System** icon sa desktop
2. Mag-appear ang window nga naga-say "Starting system..."
3. Antay 5-10 seconds
4. Automatic mag-open ang browser
5. Pwede na mag-login!

#### Hakang 3: Login
1. Sa login page, i-type:
   - **Username:** `admin`
   - **Password:** `admin123`
2. I-click ang **Login** button
3. Makita mo ang Admin Dashboard

### Paano Mag-Stop:

#### Kon Human na Mag-gamit:
1. I-close lang ang browser
2. Adto sa XAMPP Control Panel
3. I-click ang **Stop** sa Apache
4. I-click ang **Stop** sa MySQL
5. I-close ang XAMPP
6. **TAPOS NA!**

---

## 👥 PART 3: MANAGING STUDENTS (REVIEWEES)

### Paano Mag-Add sang Bag-o nga Student:

1. Login as Admin
2. I-click ang **User Management** sa sidebar
3. I-click ang **Add New User** button
4. I-fill up ang form:
   - **Name:** Full name sang student
   - **Username:** Unique username (e.g., `student001`)
   - **Password:** Temporary password (e.g., `password123`)
   - **Role:** Select "Reviewee"
5. I-click ang **Save** button
6. Tapos na! Pwede na mag-login ang student

### Paano Mag-Edit sang Student Info:

1. Adto sa **User Management**
2. Pangitaon ang student sa list
3. I-click ang **Edit** button (pencil icon)
4. I-update ang information
5. I-click ang **Save** button

### Paano Mag-Delete sang Student:

1. Adto sa **User Management**
2. Pangitaon ang student sa list
3. I-click ang **Delete** button (trash icon)
4. I-confirm ang deletion
5. Tapos na!

---

## 📝 PART 4: CREATING EXAMS

### Method 1: Manual Question Entry

1. Login as Admin
2. I-click ang **Question Bank** sa sidebar
3. I-click ang **Add Question** button
4. I-fill up ang form:
   - **Question Text:** Ang question
   - **Choice A:** First choice
   - **Choice B:** Second choice
   - **Choice C:** Third choice
   - **Choice D:** Fourth choice
   - **Correct Answer:** Select ang correct choice
   - **Category:** Select category (e.g., "Math", "Science")
5. I-click ang **Save** button
6. Repeat para sa iban nga questions

### Method 2: Import from Word Document (AI-Powered)

1. Prepare ang Word document:
   - Format: Question text, then choices A, B, C, D
   - Bold ang correct answer
   - Example:
     ```
     1. What is 2+2?
     A. 3
     B. 4 (bold ini - correct answer)
     C. 5
     D. 6
     ```

2. Import ang document:
   - Adto sa **Question Bank**
   - I-click ang **Import from Word** button
   - I-select ang .docx file
   - I-click ang **Upload** button
   - Antay mag-process (may progress bar)
   - Automatic ma-import ang tanan nga questions!

### Creating an Exam:

1. Adto sa **Exam Management**
2. I-click ang **Create Exam** button
3. I-fill up ang form:
   - **Exam Title:** Name sang exam (e.g., "Midterm Exam")
   - **Description:** Short description
   - **Time Limit:** Minutes (e.g., 60 for 1 hour)
   - **Passing Score:** Percentage (e.g., 75%)
4. I-select ang questions from question bank
5. I-click ang **Create Exam** button
6. Tapos na! Ready na ang exam

---

## 📊 PART 5: VIEWING RESULTS

### Paano Mag-View sang Scores:

1. Login as Admin
2. I-click ang **View Scores** sa sidebar
3. Makita mo ang list sang tanan nga students kag scores
4. Pwede mo i-filter by:
   - Exam name
   - Date
   - Student name
5. Pwede mo i-sort by:
   - Score (highest to lowest)
   - Name (alphabetical)
   - Date taken

### Paano Mag-Export sang Reports:

1. Adto sa **Export Reports**
2. I-select ang exam
3. I-select ang format:
   - **CSV** - Para sa Excel
   - **PDF** - Para sa printing
4. I-click ang **Export** button
5. I-download ang file
6. Pwede na i-open sa Excel o i-print

---

## 🌐 PART 6: LAN ACCESS (Para sa Iban nga Computer)

### Paano Ma-Access sa Iban nga Computer:

1. Siguraduhon nga connected ang tanan nga computers sa same network
2. Sa server computer (imo computer):
   - I-start ang XAMPP
   - I-start ang CFAS System
3. Sa client computer (iban nga computer):
   - Buksan ang browser
   - I-type sa address bar: `http://192.168.11.40/exam-frontend`
   - Press Enter
   - Pwede na mag-login!

### Important Notes para sa LAN:
- Ang server computer dapat nag-run permi
- Indi dapat i-sleep o i-shutdown ang server
- Ang firewall dapat i-allow ang connections
- Ang IP address dapat tama: `192.168.11.40`

---

## 🆘 PART 7: TROUBLESHOOTING

### Problem: "Cannot start Apache" sa XAMPP

**Possible Causes:**
- May iban nga program nga nag-gamit sang port 80
- Skype, IIS, o iban nga web server

**Solution:**
1. I-close ang Skype o iban nga programs
2. I-restart ang computer
3. I-try ulit mag-start sang Apache

### Problem: "Cannot start MySQL" sa XAMPP

**Possible Causes:**
- May iban nga MySQL service nga nag-run
- Corrupted database files

**Solution:**
1. I-restart ang computer
2. I-try ulit mag-start sang MySQL
3. Kon indi pa gid, contact IT support

### Problem: "Backend is taking longer than expected"

**Solution:**
1. Antay lang 30 seconds
2. Kon indi pa gid, i-close ang window
3. I-run ulit ang CFAS System
4. Kon indi pa gid, i-restart ang computer

### Problem: "Cannot connect to backend" sa browser

**Solution:**
1. Check kon nag-run ang XAMPP (Apache + MySQL)
2. Check kon nag-run ang backend:
   - Open Command Prompt
   - Type: `netstat -ano | findstr :8000`
   - Dapat may result
3. Kon wala, i-restart ang CFAS System

### Problem: Login indi mag-work

**Solution:**
1. Check ang username kag password (case-sensitive!)
2. Check kon nag-run ang MySQL sa XAMPP
3. Try i-clear ang browser cache:
   - Press `Ctrl + Shift + Delete`
   - I-select "Cached images and files"
   - I-click "Clear data"
4. I-refresh ang page (`F5`)

### Problem: Ang iban nga computer indi maka-access

**Solution:**
1. Check kon same network kamo
2. Check ang IP address:
   - Sa server computer, open Command Prompt
   - Type: `ipconfig`
   - Pangitaon ang "IPv4 Address"
   - Dapat `192.168.11.40`
3. Check ang firewall:
   - I-allow ang Apache sa Windows Firewall
4. Try i-ping ang server:
   - Sa client computer, open Command Prompt
   - Type: `ping 192.168.11.40`
   - Dapat may reply

---

## 📞 PART 8: GETTING HELP

### Kon May Problema Pa:

1. **Check ang guide ini first** - Basi naa diri ang solution
2. **I-restart ang system** - Solve na gid ang kadamo nga problems
3. **Contact IT Support** - Kon indi pa gid ma-solve

### Contact Information:
- **IT Support:** [Your contact info here]
- **System Administrator:** [Your contact info here]

---

## 📋 QUICK REFERENCE CARD

### Daily Checklist:

**Morning (Pag-start):**
- [ ] Start XAMPP Control Panel
- [ ] Start Apache (green)
- [ ] Start MySQL (green)
- [ ] Double-click CFAS icon
- [ ] Wait for browser to open
- [ ] Login as admin
- [ ] Ready!

**Evening (Pag-close):**
- [ ] Close browser
- [ ] Stop Apache sa XAMPP
- [ ] Stop MySQL sa XAMPP
- [ ] Close XAMPP
- [ ] Done!

### Important URLs:

- **Local Access:** `http://localhost/exam-frontend`
- **LAN Access:** `http://192.168.11.40/exam-frontend`
- **Backend API:** `http://127.0.0.1:8000`

### Default Credentials:

- **Admin Username:** `admin`
- **Admin Password:** `admin123`

---

## 🎓 TIPS & BEST PRACTICES

1. **Backup ang database regularly** - Para indi mawala ang data
2. **Change ang admin password** - Para sa security
3. **Test ang exams first** - Before i-give sa students
4. **Keep ang system updated** - Para sa bug fixes
5. **Train ang students** - Paano mag-gamit sang system
6. **Have a backup plan** - Kon may technical issues

---

## ✅ SUMMARY

**Para mag-start:**
1. Start XAMPP (Apache + MySQL)
2. Double-click CFAS icon
3. Login!

**Para mag-stop:**
1. Close browser
2. Stop XAMPP
3. Done!

**Para mag-add sang student:**
1. User Management → Add New User
2. Fill up form → Save

**Para mag-create sang exam:**
1. Question Bank → Add Questions
2. Exam Management → Create Exam
3. Select questions → Save

**Para mag-view sang results:**
1. View Scores → See all results
2. Export Reports → Download

---

**System Version:** CFAS Exam System v2.0  
**Guide Version:** 1.0  
**Last Updated:** March 2026  
**Language:** Hiligaynon/Bisaya

---

## 📖 END OF GUIDE

Salamat sa pag-gamit sang CFAS Exam System! 🎉

Kon may questions pa, feel free to contact ang IT support.

**Good luck sa imo exams!** 📝✨
