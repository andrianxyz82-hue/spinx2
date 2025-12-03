import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'config/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await EnvConfig.initialize();
  
  // Validate environment configuration
  EnvConfig.validate();

  // Initialize Supabase with environment variables
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  runApp(const WebControllerApp());
}

class WebControllerApp extends StatelessWidget {
  const WebControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remote Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: const ControllerPage(),
    );
  }
}

class ControllerPage extends StatefulWidget {
  const ControllerPage({super.key});

  @override
  State<ControllerPage> createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> {
  final TextEditingController _deviceIdController = TextEditingController();
  String _status = 'Disconnected';
  RealtimeChannel? _channel;
  bool _isConnected = false;
  
  // Feedback state
  String? _lastAction;

  void _connectToDevice() {
    final deviceId = _deviceIdController.text.trim();
    if (deviceId.isEmpty) return;

    if (_channel != null) {
      _channel!.unsubscribe();
    }

    final supabase = Supabase.instance.client;
    final channelName = 'device_$deviceId';

    setState(() {
      _status = 'Connecting to $deviceId...';
    });

    _channel = supabase.channel(channelName);

    _channel!.onBroadcast(event: 'response', callback: (payload) {
      final status = payload['status'];
      final command = payload['command'];
      setState(() {
        _lastAction = 'Device: $command ($status)';
      });
      
      // Clear feedback after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _lastAction = null;
          });
        }
      });
    }).subscribe((status, error) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        setState(() {
          _status = 'Connected to $deviceId';
          _isConnected = true;
        });
      } else if (status == RealtimeSubscribeStatus.closed) {
        setState(() {
          _status = 'Disconnected';
          _isConnected = false;
        });
      } else if (status == RealtimeSubscribeStatus.channelError) {
        setState(() {
          _status = 'Channel Error - Check Supabase Realtime settings';
          _isConnected = false;
        });
        print('Channel error: $error');
      } else {
        setState(() {
          _status = 'Status: ${status.name}';
        });
      }
    });
  }

  void _sendCommand(String command) {
    if (!_isConnected || _channel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not connected to any device')),
      );
      return;
    }

    _channel!.sendBroadcastMessage(
      event: 'command',
      payload: {'command': command},
    );
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _deviceIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Remote Controller',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                      ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                const SizedBox(height: 32),
                
                // Connection Panel
                Card(
                  color: Colors.white.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _deviceIdController,
                          decoration: InputDecoration(
                            labelText: 'Target Device ID',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.black26,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.link),
                              onPressed: _connectToDevice,
                              tooltip: 'Connect',
                            ),
                          ),
                          onSubmitted: (_) => _connectToDevice(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _status,
                          style: TextStyle(
                            color: _isConnected ? Colors.greenAccent : Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate(target: _isConnected ? 1 : 0).shimmer(),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 32),

                // Control Panel
                if (_isConnected) ...[
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _ControlBtn(
                        label: 'Flash ON',
                        icon: Icons.flash_on,
                        color: Colors.yellow,
                        onTap: () => _sendCommand('flash_on'),
                      ),
                      _ControlBtn(
                        label: 'Flash OFF',
                        icon: Icons.flash_off,
                        color: Colors.grey,
                        onTap: () => _sendCommand('flash_off'),
                      ),
                      _ControlBtn(
                        label: 'Vibrate',
                        icon: Icons.vibration,
                        color: Colors.purpleAccent,
                        onTap: () => _sendCommand('vibrate'),
                      ),
                      _ControlBtn(
                        label: 'Play Sound',
                        icon: Icons.volume_up,
                        color: Colors.blueAccent,
                        onTap: () => _sendCommand('play_sound'),
                      ),
                      _ControlBtn(
                        label: 'Change Wallpaper',
                        icon: Icons.wallpaper,
                        color: Colors.pinkAccent,
                        onTap: () => _sendCommand('change_wallpaper'),
                      ),
                    ],
                  ).animate().scale(delay: 300.ms),
                  
                  const SizedBox(height: 24),
                  
                  if (_lastAction != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        _lastAction!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ).animate().fadeIn().slideY(begin: 0.5, end: 0),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ControlBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: color.withOpacity(0.3),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5), width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
