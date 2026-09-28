Life Share – Organ Donation App

A Flutter-based organ donation platform designed to connect potential donors and recipients through registration, search, matching, and administrative management.

📌 About the Project

Life Share is an organ donation management application developed as my 3rd-year Diploma major project in Computer Engineering.

The application provides separate workflows for organ donors and recipients, allowing users to submit their information, search for potential donors, and identify potential matches based on organ type and blood group.

The system also includes an admin login and management functionality, along with an AI-powered assistant to help users with application-related queries.

✨ Key Features
👤 Donor
Donor registration
Organ donation information submission
Blood group and personal details
Donor profile management
Availability for potential matching
❤️ Recipient
Recipient registration
Required organ submission
Blood group and personal details
Search for potential donors
Immediate display of potential matching donors when matching information is available
🔎 Matching

The application performs application-level matching using:

Required / available organ
Blood group

Potential matches can be displayed to the recipient based on the available donor and recipient information.

🔐 Admin
Admin authentication
View registered donors
View registered recipients
Review submitted information
Manage potential matches
🤖 AI Assistant

Life Share includes an AI-powered chat assistant that helps users with application-related queries.

The AI functionality is integrated through an external AI API.

☁️ Firebase Backend

Firebase is used as the backend platform for application data and services.

The project includes:

Firebase Authentication
Cloud Firestore
Firebase Realtime Database
Firebase Analytics
Firebase Crashlytics
🛠️ Technology Stack
Category	Technology
Programming Language	Dart
Framework	Flutter
Backend	Firebase
Database	Cloud Firestore, Firebase Realtime Database
Authentication	Firebase Authentication
State Management	Provider
AI Integration	External AI API
API Communication	HTTP
Analytics	Firebase Analytics
Crash Reporting	Firebase Crashlytics
UI	Material Design, Google Fonts, Flutter SVG
🏗️ Application Flow
                         LIFE SHARE
                              │
                  ┌───────────┴───────────┐
                  │                       │
               DONOR                  RECIPIENT
                  │                       │
          Registration Form        Registration Form
                  │                       │
                  └───────────┬───────────┘
                              │
                              ▼
                         Firebase
                              │
                              ▼
                     Matching System
                              │
                   Organ + Blood Group
                              │
                              ▼
                     Potential Match
                              │
                              ▼
                       Admin Review
📱 Main Modules
Authentication
User Registration
Donor Registration
Recipient Registration
Dashboard
Donor Search
Organ Matching
User Profiles
AI Chat Assistant
Firebase Data Management
Admin Management
🔒 Security & API Configuration

API credentials should not be hard-coded or committed to the repository.

For example, sensitive API keys should be supplied through a secure configuration mechanism rather than being stored directly in Dart source files.

Important: Never commit private API keys, passwords, service-account credentials, or other secrets to GitHub.

🚀 Getting Started
Prerequisites

Make sure you have installed:

Flutter SDK
Dart SDK
Android Studio or another Flutter-compatible IDE
Firebase project configuration
Installation

Clone the repository:

git clone https://github.com/AntonyJos-coder/Life-Share-OrganDonation-App.git

Navigate to the project:

cd Life-Share-OrganDonation-App

Install dependencies:

flutter pub get

Run the application:

flutter run
🔥 Firebase Setup

The application requires Firebase configuration to run its backend features.

Configure your Firebase project for the required services:

Firebase Authentication
Cloud Firestore
Firebase Realtime Database
Firebase Analytics
Firebase Crashlytics

Make sure the appropriate Firebase configuration files and project settings are available for your target platform.

🧪 Project Status

This project was developed as an academic Diploma 3rd-year major project to demonstrate the development of a real-world Flutter application with Firebase backend services, user authentication, database integration, search and matching functionality, administrative management, and API-based AI integration.

⚠️ Medical Disclaimer

The matching functionality in this application is an application-level matching mechanism based on the organ and blood-group information provided by users.

It does not determine medical suitability or transplant compatibility. Actual organ donation and transplantation require professional medical evaluation, clinical compatibility assessment, and authorization by qualified healthcare professionals and relevant authorities.

👨‍💻 Developer

Antony Jos

Diploma in Computer Engineering
Carmel Polytechnic College, Alappuzha

⭐ If you find this project interesting, consider giving the repository a star.
