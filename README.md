# Door Lock - BLE Control App

iOS application that allows you to remotely control a door lock mechanism using Bluetooth Low Energy (BLE).

## Features

### Core Features
- Scan and connect to HM-10 BLE modules
- Send simple string commands to control the door lock ("open\n" and "close\n")
- Modern, intuitive UI with:
  - Animated door visualization reflecting real-time state
  - Connection status indicators
  - Bluetooth signal strength meter
  - Intuitive door control buttons
  - Haptic feedback and smooth animations

### Advanced Features
- Custom command input for advanced users
- Device selection interface
- Message log to track device responses
- Settings panel to customize commands and connection behavior

## Technical Details

### Requirements
- iOS 16.0+
- Xcode 14+
- Physical iOS device with Bluetooth capability (simulator cannot test Bluetooth features)
- Arduino with HM-10 (or compatible) BLE module

### BLE Connectivity
The app connects to HM-10 BLE modules which operate as a transparent serial bridge. The app:
- Scans for nearby BLE devices
- Connects to the selected device
- Discovers services and characteristics
- Writes string commands to control the door mechanism
- Reads responses to update the UI

### Arduino Setup
The Arduino should be configured with:
- An HM-10 BLE module connected via software serial
- A motor driver to control the door lock mechanism
- Code that listens for "open\n" and "close\n" commands

## Getting Started

1. Clone this repository
2. Open DoorLock.xcodeproj in Xcode
3. Build and run on a physical iOS device
4. Scan for your HM-10 device
5. Connect and control your door lock

## License
This project is for educational purposes. Commercial use requires proper licensing and security review. 