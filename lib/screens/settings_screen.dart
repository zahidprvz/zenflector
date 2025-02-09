import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:zenflector/providers/app_settings_provider.dart'; // Import provider
import 'package:zenflector/providers/auth_provider.dart';
import 'package:zenflector/utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isScanning = false;
  List<ScanResult> _scanResults = [];

  @override
  void dispose() {
    FlutterBluePlus.stopScan(); // Stop scanning when the screen is disposed
    super.dispose();
  }

  // Function to start/stop Bluetooth scanning
  Future<void> _toggleBluetoothScan() async {
    if (_isScanning) {
      FlutterBluePlus.stopScan();
    } else {
      setState(() {
        _isScanning = true;
        _scanResults = []; // Clear previous results
      });

      try {
        // Start scanning with a timeout
        await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

        // Listen to scan results (if you need to update the UI while scanning)
        FlutterBluePlus.scanResults.listen((results) {
          setState(() {
            _scanResults = results;
          });
        }, onDone: () {
          setState(() {
            _isScanning = false;
          });
        });
      } catch (e) {
        //Handle errors (e.g., Bluetooth is turned off)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Bluetooth error: $e'),
                backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appSettingsProvider = Provider.of<AppSettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // User Account
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Account'),
            subtitle: Text(authProvider.currentUser?.email ?? 'Not logged in'),
            onTap: () {
              // TODO: Navigate to account details screen
            },
          ),
          const Divider(),

          // Bluetooth Connection
          ListTile(
            leading: const Icon(Icons.bluetooth),
            title: const Text('Bluetooth Headband'),
            subtitle: Text(_isScanning ? 'Scanning...' : 'Tap to scan'),
            trailing: _isScanning
                ? const CircularProgressIndicator()
                : const Icon(Icons.arrow_forward_ios),
            onTap: _toggleBluetoothScan,
          ),

          // Display scanned devices (if any)
          if (_scanResults.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Found Devices:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ..._scanResults.map((result) => ListTile(
                  title: Text(result.device.localName.isNotEmpty
                      ? result.device.localName
                      : 'Unknown Device'),
                  subtitle: Text(result.device.remoteId.toString()),
                  onTap: () async {
                    // Connect to the device
                    try {
                      await result.device.connect();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Connected to device!'),
                              backgroundColor: Colors.green),
                        );
                      }
                      // TODO: Navigate to a device control screen or handle connection
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Connection failed: $e'),
                              backgroundColor: AppColors.error),
                        );
                      }
                    }
                  },
                )),
          ],
          const Divider(),

          // App Preferences
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: appSettingsProvider.isDarkMode,
            onChanged: (value) {
              appSettingsProvider.setDarkMode(value); // Update dark mode
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Manage notification settings'),
            onTap: () {
              // TODO: Navigate to notification settings
            },
          ),
          const Divider(),

          // Sign Out
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () async {
              await authProvider.signOut(); // Sign out
            },
          ),
          const Divider(),

          // About and Help
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About"),
            onTap: () {
              //TODO: Implement about section.
            },
          )
        ],
      ),
    );
  }
}
