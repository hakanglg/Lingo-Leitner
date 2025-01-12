# Lingo Leitner

<div align="center">
  <img src="Screenshots/app_icon.png" alt="Lingo Leitner Icon" width="120"/>
  
  Lingo Leitner is an iOS application that facilitates foreign language learning using the Leitner system. The app enables users to learn words and phrases through flashcards.
</div>

## 📱 Screenshots

<div align="center">
  <table>
    <tr>
      <td><img src="Screenshots/auth.png" alt="Auth" width="200"/></td>
      <td><img src="Screenshots/signup.png" alt="Sign Up" width="200"/></td>
      <td><img src="Screenshots/signin.png" alt="Sign In" width="200"/></td>
    </tr>
    <tr>
      <td align="center">Auth</td>
      <td align="center">Sign Up</td>
      <td align="center">Sign In</td>
    </tr>
    <tr>
      <td><img src="Screenshots/boxes.png" alt="Boxes" width="200"/></td>
      <td><img src="Screenshots/add_word.png" alt="Add Word" width="200"/></td>
      <td><img src="Screenshots/notifications.png" alt="Notifications" width="200"/></td>
      <td><img src="Screenshots/profile.png" alt="Profile" width="200"/></td>
      <td><img src="Screenshots/purchase.png" alt="Purchase" width="200"/></td>
      <td><img src="Screenshots/flashcard.png" alt="Flashcard" width="200"/></td>
    </tr>
    <tr>
      <td align="center">Boxes</td>
      <td align="center">Add Word</td>
      <td align="center">Notifications</td>
      <td align="center">Profile</td>
      <td align="center">Purchase</td>
      <td align="center">Flashcard</td>
    </tr>
  </table>
</div>

## 🚀 Features

- 📱 Modern and user-friendly interface
- 🔄 Smart repetition with Leitner system
- 🎯 Daily word goals
- 📊 Progress statistics
- 🔐 Secure login with Apple and Google
- ☁️ Cloud synchronization with Firebase
- 🌙 Dark mode support
- 🌍 Multiple language support (English & Turkish)

## 🌍 Localization

The app supports multiple languages:
- 🇬🇧 English
- 🇹🇷 Turkish

All text content, including:
- User interface elements
- Error messages
- Notifications
- App content

is available in both languages and automatically adapts to the user's device language.

## 📄 License

This project is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International (CC BY-NC-ND 4.0).

Under this license:

✅ **You can:**
- Share the project
- Quote with attribution

❌ **You cannot:**
- Use for commercial purposes
- Make modifications
- Create derivative works

For more information: [Creative Commons BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## 📋 Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+
- CocoaPods

## 🛠 Installation

1. Clone the project:
```bash
git clone https://github.com/yourusername/Lingo-Leitner.git
cd Lingo-Leitner
```

2. Install CocoaPods dependencies:
```bash
pod install
```

3. Firebase setup:
   - Create a new project from [Firebase Console](https://console.firebase.google.com)
   - Add iOS app and download `GoogleService-Info.plist`
   - Add the downloaded `GoogleService-Info.plist` to the `Lingo Leitner` folder

4. Open `Lingo Leitner.xcworkspace` in Xcode

5. Add required certificates and provisioning profiles

## 👩‍💻 Technologies Used

### Core Technologies
- Swift 5
- UIKit
- SwiftUI (In some components)
- Combine Framework

### Database and Backend
- Firebase Authentication
- Cloud Firestore
- Firebase Storage

### Third-Party Libraries
- Alamofire: For network requests
- SwiftyJSON: JSON parsing
- GoogleSignIn: Google sign-in integration
- SnapKit: Programmatic UI constraints

## 📱 App Architecture

- MVVM (Model-View-ViewModel) architectural pattern
- Protocol-Oriented Programming
- Dependency Injection
- Repository Pattern (For data layer)

## 🔐 Security and Configuration

The following files are not included in the repository for security reasons:

- `GoogleService-Info.plist`: Firebase configuration
- `Info.plist`: App configuration and sensitive information
- Firebase Configuration Files:
  - `firestore.rules`: Firestore security rules
  - `firestore.indexes.json`: Firestore index configuration
  - `.firebaserc`: Firebase project configuration
  - `firebase.json`: Firebase general configuration
  - `database.rules.json`: Realtime Database rules
- Certificates and provisioning profiles
- Environment configuration files

You can obtain these files securely from the project manager.

## 🤝 Contact

Hakan Gölge - [@hakangolge](https://twitter.com/hakangolge)

Project Link: [https://github.com/yourusername/Lingo-Leitner](https://github.com/yourusername/Lingo-Leitner) 
