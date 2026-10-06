# Reccly ♻️

### Smart Recycling & Waste Management Flutter Application

Reccly is a modern Flutter-based recycling and waste-management application designed to help users identify waste, understand proper disposal methods, discover recycling centers, and learn better recycling practices.

The application also includes an Admin module for managing users, waste categories, scan records, recycling centers, analytics, and notifications.

---

## 📱 Project Overview

Reccly provides two major user roles:

### 👤 User

Users can:

- View their recycling dashboard
- Scan waste using the camera
- Upload waste images from the gallery
- Analyze waste using mock AI inference
- View waste classification results
- Check AI confidence
- View disposal instructions
- Maintain scan history
- Search and filter previous scans
- Find nearby recycling centers
- Learn about different waste categories
- Track eco-points
- View achievements
- Receive notifications
- Manage their profile and settings

### 🛠️ Admin

Admins can:

- View application dashboard
- Monitor registered users
- View user details
- Manage waste categories
- Add and edit waste categories
- View scan records
- View scan details
- Manage recycling centers
- View analytics
- Manage notifications
- Manage admin profile
- Configure admin settings

---

## ✨ Main Features

### Waste Scanning

Users can capture an image using the device camera or select an image from the gallery.

The application then sends the image to a demo inference service and displays:

- Waste category
- Confidence percentage
- Description
- Recyclability status
- Disposal instructions

### Waste Categories

The application supports:

- Plastic
- Paper
- Glass
- Metal
- E-Waste
- Organic

### Scan History

Every analyzed waste item can be stored in the application's local demo history.

Users can:

- Search scans
- Filter scans
- View confidence
- View date and time
- Open scan details
- Clear history

### Recycling Centers

Users can explore recycling centers with:

- Center name
- Address
- Distance
- Opening hours
- Open/closed status
- Accepted materials
- Contact information

### Learning Section

The Learn module contains educational content about:

- Plastic recycling
- Paper recycling
- Glass recycling
- Metal recycling
- E-Waste
- Organic waste

### Achievements

Users can unlock achievements based on their recycling activity.

Examples:

- First Scan
- Eco Starter
- Recycling Rookie
- Green Guardian
- Eco Hero
- Recycling Champion
- Plastic Saver
- E-Waste Expert

---

## 🛠️ Technology Stack

| Technology | Purpose |
|------------|---------|
| Flutter | Application development |
| Dart | Programming language |
| Material 3 | UI design system |
| Camera | Waste image capture |
| Image Picker | Gallery image selection |
| Flutter Navigation | Screen navigation |
| Mock Data | Demo application data |
| Mock Inference Service | Demo waste classification |

---

## 📂 Project Structure

```text
recycle_app/
│
├── assets/
│   ├── images/
│   └── icons/
│
├── lib/
│   ├── app/
│   ├── constants/
│   ├── theme/
│   ├── models/
│   ├── services/
│   ├── data/
│   ├── widgets/
│   └── screens/
│
├── test/
│
├── android/
├── pubspec.yaml
├── analysis_options.yaml
├── .gitignore
└── README.md