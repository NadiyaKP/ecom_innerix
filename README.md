# 🛒 Ecom Innerix - Flutter E-commerce App

A Flutter 3.x application built for an e-commerce application
This project implements the **Onboarding**, **Login (Password + OTP)**, **OTP Verification**, and **Home** screens with REST API integration following **MVVM architecture** and **SOLID principles**.
## 📱 Screens Implemented

1. **Onboarding**  
   - 3-page onboarding flow with PageView, dot indicators, and skip/next/get started navigation.
   
2. **Login Screen**  
   - Email & Password login (API integrated)  
   - OTP login (request OTP → verify OTP)  

3. **OTP Verification Screen**  
   - Enter OTP, verify via API, navigate to Home on success.

4. **Home Screen**  
   - Displays categories, products, and offers from APIs.  
   - Placeholder images for null values.  
   - Responsive layout.
## 🛠 Tech Stack & Architecture

- **Flutter 3.x**
- **State Management:** Provider
- **Architecture:** MVVM (Model-View-ViewModel)
- **Networking:** `http` package
- **UI:** Responsive layout with reusable widgets
- **Version Control:** Git (GitHub)

---

## 🧑‍💻 API Endpoints Used

### 🔐 Authentication
- **Login (Password)**  
  `POST https://app.ecominnerix.com/api/login`  
  Form Data: `email`, `password`

- **Request OTP**  
  `POST https://app.ecominnerix.com/api/request-otp`  
  Form Data: `email`

- **Verify OTP**  
  `POST https://app.ecominnerix.com/api/verify-email-otp`  
  Form Data: `email`, `otp`

### 🏠 Home
- **Home Data:**  
  `GET https://app.ecominnerix.com/api/v1/home`

- **Product Listing:**  
  `GET https://app.ecominnerix.com/api/products?shop_id=1&page_size=100&page=1`

## ⚙️ Project Setup Instructions

1️⃣ **clone the repository**
git clone https://github.com/NadiyaKP/ecom_innerix.git
cd ecom_innerix

2️⃣ **Install Dependencies**
flutter pub get

3️⃣ **Run the Application**
Start your Android emulator or connect a physical device.
Run:flutter run

4️⃣ Build APK for Testing
flutter build apk --release

The APK will be located in:
build/app/outputs/flutter-apk/app-release.apk


