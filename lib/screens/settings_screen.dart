import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
    WidgetsBinding.instance.addObserver(this);
    _loadConnectedDevice();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadConnectedDevice();
    }
  }

  Future<void> _loadConnectedDevice() async {
    bool isAvailable = await FlutterBluePlus.isAvailable;
    bool isOn = await FlutterBluePlus.isOn;

    if (!isAvailable || !isOn) {
      if (mounted) {
        setState(() {
          _connectedDevice = null;
        });
      }
      return;
    }

    try {
      List<BluetoothDevice> devices =
          await FlutterBluePlus.connectedSystemDevices;
      if (mounted) {
        setState(() {
          _connectedDevice = devices.isNotEmpty ? devices.first : null;
        });
      }
    } catch (e) {
      print("Error getting connected devices: $e");
      if (mounted) {
        setState(() {
          _connectedDevice = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appSettingsProvider = Provider.of<AppSettingsProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final headingTextStyle = TextStyle(
      color: isDarkMode ? Colors.white : Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text('Account', style: headingTextStyle),
            subtitle: Text(authProvider.currentUser?.email ?? 'Not logged in'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bluetooth),
            title: Text('Bluetooth Headband', style: headingTextStyle),
            subtitle: Text(_connectedDevice != null
                ? 'Connected: ${_connectedDevice!.platformName.isNotEmpty ? _connectedDevice!.platformName : "Unknown Device"}'
                : 'No device connected'),
          ),
          const Divider(),
          SwitchListTile(
            title: Text('Dark Mode', style: headingTextStyle),
            value: appSettingsProvider.isDarkMode,
            onChanged: (value) {
              appSettingsProvider.setDarkMode(value);
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text('Notifications', style: headingTextStyle),
            subtitle: const Text('Manage notification settings'),
            onTap: () {
              // TODO: Implement notification settings
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text('Sign Out', style: headingTextStyle),
            onTap: () async {
              await authProvider.signOut();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('About', style: headingTextStyle),
            onTap: () {
              _showAboutDialog(context, isDarkMode);
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isDarkMode) {
    PackageInfo.fromPlatform().then((packageInfo) {
      String appName = packageInfo.appName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;

      showAboutDialog(
        context: context,
        applicationIcon: Image.asset(
          'assets/appstore.png',
          width: 64,
          height: 64,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        ),
        applicationName: appName,
        applicationVersion: "$version ($buildNumber)",
        applicationLegalese: '© 2024 Zenflector',
        children: <Widget>[
          const SizedBox(height: 24),
          Text(
            "ZenFlector is designed to help you improve your sleep quality, "
            "reduce stress, and enhance your overall well-being through a curated "
            "collection of soothing sounds, guided meditations, and hypnotic stories.",
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () async {
              final url = Uri.parse('https://your-privacy-policy.com');
              if (!await launchUrl(url)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch URL')),
                  );
                }
              }
            },
            child: Text(
              'Privacy Policy',
              style: TextStyle(
                  color: isDarkMode ? Colors.lightBlueAccent : Colors.blue),
            ),
          ),
          TextButton(
            onPressed: () async {
              final url = Uri.parse('https://your-termsofservice.com');
              if (!await launchUrl(url)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch URL')),
                  );
                }
              }
            },
            child: Text(
              'Terms of Service',
              style: TextStyle(
                  color: isDarkMode ? Colors.lightBlueAccent : Colors.blue),
            ),
          ),
        ],
      );
    });
  }
}
