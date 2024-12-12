# Pictora

Pictora is a Flutter-based mobile application designed for event organization and photo sharing. Users can create and join event rooms, arrange photos, and share memories seamlessly. The app integrates Firebase for authentication, storage, and real-time database functionalities, ensuring a secure and efficient user experience.

---

## Features
- **Event Management**: Create and join event rooms for photo sharing and collaboration.
- **Photo Management**: Organize and share photos with event participants.
- **QR Code Integration**: Use QR codes to simplify event room access.
- **Firebase Integration**:
  - Authentication (Google Sign-In)
  - Cloud Storage
  - Real-time Database
- **Email Support**: Integrated email sender for communication.
- **Multi-Platform**: Supports both Android and iOS.

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.5.3 or later)
- Android Studio or Visual Studio Code
- Firebase account and project setup

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/MuhammadTahmidurRahman/CSE-299-FACE-RECPGNITION-APP

2.  Navigate to the project directory:
    cd pictora
3.  Install dependencies:
    flutter pub get

4.  Set up Firebase:
    Place the google-services.json file in the android/app directory.
    Place the Info.plist file in the ios/Runner directory.

5.  Run the application:
    flutter run

6.  Directory Structure
    lib/
     ├── splash.dart
     ├── main.dart
     ├── welcome.dart
     ├── profile.dart
     ├── login.dart
     ├── signup.dart
     ├── forgot_password.dart
     ├── create_event.dart
     ├── join_event.dart
     ├── eventroom.dart
     ├── arrangedphoto.dart
     └── createorjoinroom.dart
7.  Dependencies

    The project uses the following dependencies:

     archive: ^3.3.0
     firebase_auth: ^5.3.1
     firebase_storage: ^12.3.3
     firebase_database: ^11.2.0
     firebase_core: ^3.6.0
     qr_flutter: ^4.0.0
     cached_network_image: ^3.2.3
     flutter_email_sender: ^6.0.3
     permission_handler: ^11.3.1
     image_picker: ^1.1.2

8.  Contributors

    Muhammad Tahmidur Rahman
    Mohosina Islam Disha
    Anika Tabassum


For the web version go to this git repository: "https://github.com/MuhammadTahmidurRahman/pictora.git"
For the backend go to this git repository: "https://github.com/MuhammadTahmidurRahman/Face_Recognition_UsingOPENCV_HARCASCADE_FACE_RECOGNITION-pictorabackend-"