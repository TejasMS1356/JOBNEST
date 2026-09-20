# 💼 JOBNEST — Smart Job Discovery App

> **Discover. Explore. Save. Apply.**

JOBNEST is a modern Flutter-based mobile job discovery application designed to help users search, explore, filter, save, and apply for job opportunities through a simple and professional interface. The application integrates the Adzuna Jobs REST API to retrieve real job listings and presents them using a clean Material 3 interface.

---

## ✨ Overview

Finding suitable job opportunities often requires searching across multiple platforms and repeatedly applying different filters. JOBNEST brings the essential job-search workflow into one mobile application.

Users can search for jobs, filter opportunities by job type, sort jobs based on salary, view complete job details, save interesting jobs to Favorites, and continue the application process directly through the company's website.

The application focuses on a smooth user experience, clean architecture, reusable components, proper state management, persistent favorites, responsive UI, and reliable API handling.

---

## 🚀 Features

### 🔎 Job Search
Search for opportunities using keywords such as Software Developer, Web Developer, Flutter Developer, Java Developer, Data Analyst, Software Engineer, and more.

### 🎯 Job Filtering
Filter job opportunities based on available job types and relevant criteria.

### 💰 Salary Sorting
Sort job opportunities based on salary, including High to Low and Low to High ordering.

### ❤️ Favorites
Save interesting jobs using the heart icon and access them later from the Favorites section. Favorite jobs are stored locally so they remain available after closing the application.

### 📄 Job Details
View detailed information about a selected job, including:
- Job Title
- Company
- Location
- Salary / Stipend
- Job Type
- Description
- Skills
- Experience
- Application Link

### 🌐 Apply Through Company Website
Users can continue the application process by opening the company's external application page directly from the application.

### 🌙 Dark & Light Mode
JOBNEST supports both dark and light themes for a comfortable and modern user experience.

### 🔄 Pull to Refresh
Users can refresh the job listing to retrieve the latest available opportunities.

### ⚡ State Handling
The application handles:
- Loading state
- Success state
- Empty state
- Error state

### 🎨 Modern UI
The interface follows Material 3 design principles with:
- Clean job cards
- Consistent spacing
- Clear typography
- Responsive layouts
- Interactive elements
- Smooth navigation
- Theme support
- Professional visual hierarchy

---

## 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Mobile application development |
| Dart | Programming language |
| Material 3 | UI and design system |
| Adzuna API | Job listing data source |
| REST API | Communication between app and job service |
| HTTP | Sending and receiving API requests |
| Provider | State management |
| SharedPreferences | Persistent local storage for favorites |
| URL Launcher | Opening external company application pages |
| Intl | Formatting salary/date-related information |
| Git | Version control |
| GitHub | Source code hosting |
| Android | Mobile deployment platform |

---

## 🏗️ Architecture

JOBNEST follows a layered architecture that separates the user interface, state management, API communication, and local persistence.

    ┌─────────────────────────────┐
    │        Flutter UI           │
    │     Screens & Widgets       │
    └──────────────┬──────────────┘
                   │
                   ▼
    ┌─────────────────────────────┐
    │          Provider           │
    │      State Management       │
    └──────────────┬──────────────┘
                   │
                   ▼
    ┌─────────────────────────────┐
    │        Job Service          │
    │       HTTP / API Layer      │
    └──────────────┬──────────────┘
                   │
                   ▼
    ┌─────────────────────────────┐
    │       Adzuna REST API       │
    │       Job Data Source       │
    └─────────────────────────────┘

    SharedPreferences
            │
            ▼
    Favorite Job Persistence

    URL Launcher
            │
            ▼
    External Company Application Page

---

## 🔄 Application Data Flow

The application follows a simple request-response architecture:

    User
      ↓
    Flutter UI
      ↓
    Provider
      ↓
    Job Service
      ↓
    HTTP REST Request
      ↓
    Adzuna REST API
      ↓
    JSON Response
      ↓
    Job Model
      ↓
    Provider
      ↓
    Flutter UI

This separation keeps the UI independent from API communication and makes the application easier to maintain and extend.

---

## 🌐 API Integration

JOBNEST uses the Adzuna Jobs REST API as its primary source of job information.

The API is accessed through HTTP requests and returns job information in JSON format. The application processes the response and presents the relevant information through reusable Flutter widgets.

The API workflow is:

    Flutter Application
            ↓
      HTTP Request
            ↓
       Adzuna API
            ↓
      JSON Response
            ↓
       Job Model
            ↓
        Provider
            ↓
       Flutter UI

Job information can include:
- Job title
- Company
- Location
- Salary
- Description
- Application URL
- Job information

---

## 🧠 State Management

JOBNEST uses Provider for application state management.

Provider manages important application states such as:
- Job listings
- Search results
- Filters
- Sorting
- Loading state
- Error state
- Favorite jobs
- UI-related state

Using Provider keeps business logic and state management separate from the presentation layer.

---

## ❤️ Favorites Architecture

Favorite jobs are persisted locally using SharedPreferences.

The workflow is:

    User taps ❤️
          ↓
    Provider updates state
          ↓
    SharedPreferences
          ↓
    Favorite saved locally
          ↓
    Favorites Screen

This allows users to close and reopen the application without losing their saved jobs.

---

## 🌐 Application Flow

The primary user journey is:

    Landing Page
          ↓
    Home / Jobs
          ↓
    Search / Filter
          ↓
    Job Listing
          ↓
    Job Details
          ↓
    Save to Favorites
          ↓
    Apply
          ↓
    Company Website

---

## 📱 Main Screens

### 🏠 Landing Page
Introduces the JOBNEST application and provides entry into the job discovery experience.

### 💼 Home / Jobs
Displays available job opportunities in an easy-to-browse card-based interface.

### 🔍 Search
Allows users to search for specific job roles, skills, or technologies.

### 🎯 Filters & Sorting
Allows users to filter jobs and sort opportunities based on salary.

### ❤️ Favorites
Displays all jobs saved by the user.

### 📄 Job Details
Shows complete information about a selected job.

### 🌐 Application Page
Redirects users to the external company website where they can continue the application process.

---

## 🎨 UI / UX Design

JOBNEST is designed to provide a professional mobile experience rather than simply demonstrating API functionality.

The interface uses:
- Material 3 components
- Consistent spacing
- Modern typography
- Rounded cards
- Clear information hierarchy
- Responsive layouts
- Interactive icons
- Dark and light themes
- Smooth navigation
- Clear action buttons
- Loading and empty-state interfaces

The design prioritizes readability and allows users to quickly understand important job information.

---

## 📂 Project Structure

    JOBNEST/
    │
    ├── android/
    │   └── Android application configuration
    │
    ├── assets/
    │   └── images/
    │       └── Application assets
    │
    ├── lib/
    │   └── Flutter application source code
    │
    ├── web/
    │   └── Web platform configuration
    │
    ├── pubspec.yaml
    │   └── Project configuration and dependencies
    │
    ├── pubspec.lock
    │   └── Locked dependency versions
    │
    ├── analysis_options.yaml
    │   └── Dart analysis configuration
    │
    ├── .gitignore
    │   └── Git ignored files
    │
    └── README.md
        └── Project documentation

---

## 📦 Major Dependencies

### HTTP
Used for communicating with the Adzuna REST API and handling API requests and responses.

### Provider
Used for managing application state and keeping business logic separate from the UI.

### SharedPreferences
Used for storing favorite jobs locally and providing persistence across application sessions.

### URL Launcher
Used to open external company application links in the device browser.

### Intl
Used for formatting values such as salary and date information.

---

## 🔐 Error Handling

JOBNEST provides appropriate feedback for different application conditions.

### Loading
Displayed while job information is being retrieved from the API.

### Success
Displays the retrieved job opportunities.

### Empty
Shown when no jobs are available or when a search does not return matching opportunities.

### Error
Displayed when an API request fails or job data cannot be retrieved.

This ensures that the application remains understandable and usable even when network or data-related problems occur.

---

## ⚙️ Setup

### 1. Clone the repository

    git clone https://github.com/TejasMS1356/JOBNEST.git

### 2. Open the project

    cd JOBNEST

### 3. Install dependencies

    flutter pub get

### 4. Configure Adzuna API

Configure the required Adzuna API credentials according to the application's configuration.

> ⚠️ API keys and private credentials should never be committed to a public GitHub repository.

### 5. Run the application

    flutter run

---

## 📦 Build Release APK

Generate the Android release APK using:

    flutter build apk --release

The generated APK will be available at:

    build/app/outputs/flutter-apk/app-release.apk

The APK can be installed directly on a compatible Android device.

---

## 📸 Application Screenshots

The project demonstrates the following screens and interactions:

1. Landing Page
2. Home Page
3. Light Mode
4. Tech Jobs in Bangalore
5. Salary Sorting — High to Low
6. Web Developer Search
7. Adding a Job to Favorites
8. Job Details
9. Apply Through Company Website

---

## 🔁 Complete User Workflow

    ┌───────────────┐
    │ Landing Page  │
    └───────┬───────┘
            ↓
    ┌───────────────┐
    │   Home Page   │
    └───────┬───────┘
            ↓
    ┌─────────────────────┐
    │ Search / Filter     │
    │ / Sort Jobs         │
    └──────────┬──────────┘
               ↓
    ┌─────────────────────┐
    │   Job Listing       │
    └──────────┬──────────┘
               ↓
    ┌─────────────────────┐
    │    Job Details      │
    └───────┬───────┬─────┘
            │       │
          ❤️       Apply
            │       │
            ↓       ↓
    ┌────────────┐ ┌──────────────────┐
    │ Favorites  │ │ Company Website  │
    └────────────┘ └──────────────────┘

---

## 💡 Project Highlights

- Real job data through Adzuna REST API
- Modern Flutter Material 3 interface
- Clean layered architecture
- Provider-based state management
- Persistent favorite jobs
- Search functionality
- Job-type filtering
- Salary sorting
- Job detail pages
- External application support
- Dark and light themes
- Pull-to-refresh
- Loading, empty and error states
- Responsive mobile UI
- Git and GitHub integration

---

## 🚀 Future Enhancements

The application can be extended with additional features such as:

- 🤖 AI-powered job recommendations
- 🔔 Job alerts and notifications
- 📍 Location-based recommendations
- 📄 Resume upload and analysis
- 🧠 Resume-to-job matching
- 📊 Application tracking
- ☁️ Cloud synchronization
- 🔐 User authentication
- 🔖 Advanced job filtering
- 💬 Personalized career assistance

---

## 🎯 Project Objective

The objective of JOBNEST is to create a simple, modern and efficient mobile platform for discovering job opportunities.

Instead of repeatedly searching through different platforms, users can use a single application to:

    SEARCH → FILTER → EXPLORE → SAVE → APPLY

JOBNEST combines real job data, modern mobile UI, persistent favorites and external application support into one streamlined job discovery experience.

---

## 👨‍💻 Developer

**Tejas M S**

GitHub:  
https://github.com/TejasMS1356

Project Repository:  
https://github.com/TejasMS1356/JOBNEST

---

<p align="center">

## 💼 JOBNEST

### Discover Opportunities. Save What Matters. Take the Next Step.

**Built with Flutter & Dart ❤️**

</p>
