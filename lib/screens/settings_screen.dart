import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:zenflector/providers/app_settings_provider.dart';
import 'package:zenflector/providers/auth_provider.dart';
import 'package:zenflector/screens/profile_screen.dart';
import 'package:zenflector/utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  BluetoothDevice? _connectedDevice;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer
    _loadConnectedDevice(); // Load on startup
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer. ESSENTIAL.
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // When the app returns to the foreground, refresh.
      _loadConnectedDevice();
    }
  }

  Future<void> _loadConnectedDevice() async {
    // Check if Bluetooth is available and on *before* trying to get connected devices.
    bool isAvailable = await FlutterBluePlus.isAvailable;
    bool isOn = await FlutterBluePlus.isOn;

    if (!isAvailable || !isOn) {
      if (mounted) {
        setState(() {
          _connectedDevice =
              null; // Clear device if Bluetooth is off/unavailable
        });
      }
      return; // Exit early if Bluetooth is not ready
    }

    try {
      List<BluetoothDevice> devices =
          await FlutterBluePlus.connectedSystemDevices;
      if (devices.isNotEmpty) {
        if (mounted) {
          setState(() {
            _connectedDevice = devices.first; // Simplification: take the first.
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _connectedDevice = null; // Explicitly set to null if no devices
          });
        }
      }
    } catch (e) {
      print("Error getting connected devices: $e"); // Log the error
      if (mounted) {
        setState(() {
          _connectedDevice =
              null; // Set to null on error to update the UI correctly.
        });
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
          // User Account Section
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Account'),
            subtitle: Text(authProvider.currentUser?.email ?? 'Not logged in'),
            onTap: () {
              // Navigate to Profile Screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const Divider(),

          // Bluetooth Connection Section
          ListTile(
            leading: const Icon(Icons.bluetooth),
            title: const Text('Bluetooth Headband'),
            subtitle: Text(_connectedDevice != null
                ? 'Connected: ${_connectedDevice!.platformName.isNotEmpty ? _connectedDevice!.platformName : "Unknown Device"}'
                : 'No device connected'),
          ),
          const Divider(),

          // App Preferences
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: appSettingsProvider.isDarkMode,
            onChanged: (value) {
              appSettingsProvider.setDarkMode(value);
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Manage notification settings'),
            onTap: () {
              // TODO: Implement notification settings
            },
          ),
          const Divider(),

          // Sign Out
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () async {
              await authProvider.signOut();
            },
          ),
          const Divider(),

          // About and Help
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              _showAboutDialog(context); // Use the helper function
            },
          ),
        ],
      ),
    );
  }

// Helper function for the About dialog.  This avoids FutureBuilder issues.
  void _showAboutDialog(BuildContext context) {
    PackageInfo.fromPlatform().then((packageInfo) {
      // Use package_info_plus
      String appName = packageInfo.appName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;

      showAboutDialog(
        context: context,
        applicationIcon: Image.asset(
          'assets/appstore.png', //  Replace with your app icon path
          width: 64,
          height: 64,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        ),
        applicationName: appName, // Use dynamic name
        applicationVersion: "$version ($buildNumber)", // Use dynamic version
        applicationLegalese: '© 2024 Zenflector', //  Your copyright
        children: <Widget>[
          const SizedBox(height: 24),
          const Text(
            "ZenFlector is designed to help you improve your sleep quality, "
            "reduce stress, and enhance your overall well-being through a curated "
            "collection of soothing sounds, guided meditations, and hypnotic stories.  "
            "Whether you're struggling with insomnia, seeking relaxation, or aiming to "
            "achieve a more positive mindset, ZenFlector provides the tools you need "
            "to achieve your goals.",
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () async {
              final url =
                  Uri.parse('https://your-privacy-policy.com'); // Replace
              if (!await launchUrl(url)) {
                // Use await here
                if (context.mounted) {
                  //Check if context is mounted
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch URL')),
                  );
                }
              }
            },
            child: const Text('Privacy Policy'),
          ),
          TextButton(
            onPressed: () async {
              final url = Uri.parse('https://your-termsofservice.com');
              if (!await launchUrl(url)) {
                if (context.mounted) {
                  //Check if context is mounted
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch URL')),
                  );
                }
              }
            },
            child: const Text('Terms of Service'),
          ),
        ],
      );
    });
  }
}
