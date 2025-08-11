# Digital Attendance Register for Tutors** mobile application, including **full feature set, tech stack (Flutter-based)**, and all system architecture details in plain **text format**.

---

# 📄 Product Requirements Document (PRD)

**Project Title:** Digital Attendance Register for Tutors
**Platform:** Mobile App (Flutter – Android + iOS)
**Monetization:** ₹9/month subscription
**Target Users:** Private home tutors, coaching centers (especially in rural/semi-urban areas)

---

## 🧭 1. Objective / Purpose

To provide a simple, mobile-first digital register for tutors to track student attendance, payments, and batch records with export support (PDF/Excel), offline access, and low-cost subscription pricing to suit the needs of rural educators.

---

## 🎯 2. Goals & Success Criteria

* Replace paper registers with a simple digital app.
* Easy data entry for attendance and fees.
* 100% mobile-friendly, no desktop dependency.
* Export records to Excel/PDF.
* Offline mode support.
* Affordable ₹9/month subscription model.
* Local language support (planned in future releases).

---

## 👥 3. Target Audience

* Independent home tutors
* Small coaching institutes
* Tuition teachers in rural/low-income urban areas
* Non-technical users with smartphone access

---

## 🧩 4. Features Overview

### 📚 **Student Management**

* Add/edit/delete students
* Assign to batch/group
* Contact details (optional)
* Join date tracking

### ✅ **Attendance Management**

* Daily attendance marking (Present/Absent)
* Filter by date, batch, or student
* Add optional notes
* Visual overview by calendar or list

### 💰 **Payment Tracking**

* Record student fees
* Track paid/unpaid status
* Add date, amount, mode (cash, UPI)
* Monthly and historical view

### 📤 **Export Reports**

* Export to **Excel (.xlsx)** and **PDF**
* Attendance & Payment exports separately
* Download and share (e.g., via WhatsApp or Email)

### 💳 **Subscription & Billing**

* ₹9/month (intro offer)
* Manual UPI-based or auto-renewal (if supported)
* App access blocked after grace period if unpaid
* Payment reminders & renewal prompt

### 📶 **Offline Support**

* Local storage for attendance and payment data
* Auto-sync when back online
* Data backup to cloud (Firebase or custom backend)

### 🔒 **Security & Access Control**

* OTP or PIN login
* User-specific access control (tutor can access only their data)
* Local encryption of sensitive data (on-device)

---

## 🖥️ 5. MCV Architecture (Model - Controller - View)

### 🗂️ **Model (Data Layer)**

* `Tutor`
* `Student`
* `Batch`
* `Attendance`
* `Payment`
* `Subscription`
* `ExportLog`

### 🧠 **Controller (Business Logic Layer)**

* AuthController
* StudentController
* AttendanceController
* PaymentController
* ExportController
* SubscriptionController

### 🎨 **View (User Interface Layer)**

* Login / Signup screen
* Dashboard (stats, dues, export buttons)
* Student list screen
* Attendance screen
* Payment tracking screen
* Export report screen
* Subscription screen

---

## 🏗️ 6. System Design Overview

### ⚙️ **Mobile Application**

* Built in **Flutter** (Dart)
* Target: Android (primary), iOS (optional)
* Local data stored using **Hive** or **Drift**
* Export generation via native libraries or plugins

### 🌐 **Backend (Cloud)**

| Component      | Technology                                                   |
| -------------- | ------------------------------------------------------------ |
| Backend API    | Node.js (Express.js) or Firebase Functions                   |
| Authentication | Firebase Auth (Phone/OTP)                                    |
| Realtime Sync  | Firebase Firestore / Supabase                                |
| Database       | Firebase Firestore or PostgreSQL                             |
| Export Service | Server-side generation with Puppeteer (PDF), ExcelJS (Excel) |
| Storage        | Firebase Storage or AWS S3 (for download links)              |

### 🔄 **Offline Sync Mechanism**

* Store attendance, students, payments locally
* Sync on background when network available
* Show "sync pending" badge for unsynced data

---

## 🧾 7. Database Schema (High-Level)

### `tutors`

* id, name, phone, subscription\_status, created\_at

### `students`

* id, tutor\_id, name, batch, join\_date

### `attendance`

* id, student\_id, date, status, note

### `payments`

* id, student\_id, amount, date, mode, status

### `subscriptions`

* id, tutor\_id, start\_date, end\_date, status

### `exports`

* id, tutor\_id, type (pdf/xlsx), created\_at, file\_url

---

## 🧪 8. User Flows

### 🔑 **Login Flow**

1. Phone number entry
2. OTP verification (via Firebase Auth)
3. Session starts

### 🧒 **Student Flow**

1. Add new student
2. Assign to batch
3. Edit or delete as needed

### 📅 **Attendance Flow**

1. Select batch & date
2. Mark students as present/absent
3. Submit and auto-sync (or store locally)

### 💸 **Payment Flow**

1. Tap student → Add payment
2. Enter amount, mode, date
3. Track dues on dashboard

### 📤 **Export Flow**

1. Choose module (Attendance/Payment)
2. Select date range
3. Generate → download or share

### 💳 **Subscription Flow**

1. Show active/inactive status
2. In-app link to pay ₹9 via UPI
3. Store status, restrict if expired

---

## 📊 9. KPIs & Metrics

| KPI                        | Target                       |
| -------------------------- | ---------------------------- |
| Monthly Active Tutors      | 1,000+ in 6 months           |
| Subscription Renewal Rate  | > 80%                        |
| Monthly Exports            | 60% tutors exporting reports |
| Offline Usage Success Rate | > 90%                        |
| Support Requests           | < 5% of user base            |

---

## 🔧 10. Tech Stack Summary

| Layer                   | Technology                                            |
| ----------------------- | ----------------------------------------------------- |
| **Frontend (Mobile)**   | Flutter (Dart)                                        |
| **State Management**    | Riverpod or Bloc                                      |
| **Local DB**            | Hive or Drift                                         |
| **Authentication**      | Firebase Auth                                         |
| **Backend APIs**        | Node.js (Express.js) or Firebase Functions            |
| **Database**            | Firebase Firestore / Supabase PostgreSQL              |
| **File Storage**        | Firebase Storage or AWS S3                            |
| **PDF Export**          | `pdf` plugin or custom Node.js service with Puppeteer |
| **Excel Export**        | `exceljs` in backend or Flutter plugin                |
| **Payments (₹9/month)** | Razorpay, PhonePe UPI Intent, Cash entry              |
| **Notifications**       | Firebase Cloud Messaging (reminders)                  |

---

## 📆 11. Roadmap (8-Week MVP Plan)

| Phase    | Duration             | Milestone                          |
| -------- | -------------------- | ---------------------------------- |
| Week 1   | Planning             | Wireframes, PRD finalization       |
| Week 2-3 | Development Sprint 1 | Authentication, Student management |
| Week 4-5 | Development Sprint 2 | Attendance + Payments              |
| Week 6   | Sprint 3             | Exports (PDF, Excel), Offline sync |
| Week 7   | Sprint 4             | Subscription billing + testing     |
| Week 8   | Release              | Pilot launch & feedback collection |

---

## ✅ 12. Assumptions

* Users have smartphones and basic mobile literacy.
* ₹9/month is affordable and acceptable.
* Tutors prefer mobile apps over web dashboards.
* UPI is the most common payment mode.
* Offline-first approach is critical for rural areas.

---

## ⚠️ 13. Risks & Mitigation

| Risk                        | Mitigation                                 |
| --------------------------- | ------------------------------------------ |
| Poor network in rural areas | Strong offline mode with auto-sync         |
| Non-payment of ₹9           | Gentle reminders, offer 7-day grace period |
| Technical illiteracy        | Simple UI/UX, local language content       |
| Data loss                   | Daily auto-backup to cloud when online     |
