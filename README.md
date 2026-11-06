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
- iOS 18.0+
- Xcode with an iOS 18 or newer SDK
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

## Prototype scope

This is an educational BLE controller. The repository does not contain lock firmware, wiring instructions, or a verified authentication/security design for a physical lock. The UI state is not proof that a door is physically secured. No repository-wide license file is included.

The existing usage notice remains: "This project is for educational purposes. Commercial use requires proper licensing and security review."

## Development

Select your own signing team before running the **DoorLock** scheme on an iPhone. `DoorLock/BLEManager.swift` owns discovery and command writes; the other views expose controls, settings, and logs. Simulator builds can check compilation, but BLE command delivery needs a compatible peripheral and physical device. See [Contributing](CONTRIBUTING.md).
