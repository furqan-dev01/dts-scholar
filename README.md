# DevTri Campus

This is a Flutter-based mobile application designed to manage school-related activities for users, potentially including students and administrators. It leverages Firebase for backend services, providing a robust and scalable solution for various school management tasks.

## Features

The application includes a comprehensive set of features, categorized for different user roles:

### Authentication
*   User login
*   Role selection (e.g., Admin, Student)
*   Loading screen for initial setup/authentication checks

### Admin Features
*   **Student Management:** Add, edit, and view student details.
*   **Notice Management:** Create and manage school notices.
*   **Video Management:** Upload and manage educational videos.
*   **Fee Management:** Track and manage student fees.
*   **Admin Dashboard:** Overview of key administrative data.

### User Dashboard
*   Personalized dashboard for general users.
*   Invoice viewing.
*   Notification display.
*   Video playback for educational content.

## Technologies Used

*   **Flutter:** UI Toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
*   **Firebase:**
    *   **Firestore:** NoSQL cloud database for data storage and synchronization.
    *   **Firebase Authentication:** Secure user authentication.
    *   **Firebase Cloud Functions (potential):** Serverless backend logic.
*   **Provider (potential):** State management solution for Flutter.
*   **Local Notifications:** For in-app notifications.

## Project Structure

The project follows a modular architecture to ensure maintainability and scalability:

*   `lib/config`: Configuration files, such as Firestore settings.
*   `lib/features`: Contains distinct feature modules (e.g., `admin`, `auth`, `dashboard`, `splash`). Each feature has its own `screens` and `widgets` subdirectories.
*   `lib/global`: Global assets or data, like video data.
*   `lib/services`: Backend service integrations (e.g., `auth_service`, `notice_service`, `local_notification_service`).
*   `lib/theme`: Application-wide theming and color definitions.
*   `lib/widgets`: Reusable global widgets.

## Installation

To get a local copy up and running, follow these steps:

1.  **Clone the repository:**
    ```bash
    git clone [repository_url]
    cd schooluser_application
    ```

2.  **Install Flutter dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Firebase Setup:**
    *   Create a Firebase project on the [Firebase Console](https://console.firebase.google.com/).
    *   Add Android and iOS apps to your Firebase project.
    *   Download `google-services.json` for Android and place it in `android/app/`.
    *   Download `GoogleService-Info.plist` for iOS and place it in `ios/Runner/`.
    *   Ensure Firebase rules are configured correctly for Firestore.

4.  **Run the application:**
    ```bash
    flutter run
    ```

## Usage

*   **Admin:** Log in with administrator credentials to access student management, notice management, and video management features.
*   **Student/User:** Log in with user credentials to access the dashboard, view invoices, receive notifications, and watch videos.

## Contributing

Contributions are welcome! Please follow standard GitHub flow: fork the repository, create a new branch, make your changes, and submit a pull request.

## License
This project is proprietary software developed by DevTriSoft.
Unauthorized reproduction or distribution is prohibited.

## Contact

[DevTriSoft] - [furqanulazeem138@gmail.com]
