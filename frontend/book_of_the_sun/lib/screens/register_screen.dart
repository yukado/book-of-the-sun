import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final AuthService authService;

  const RegisterScreen({
    super.key,
    required this.authService,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool loading = false;
  String? error;

  Future<void> _register() async {
    if (passwordController.text != confirmController.text) {
      setState(() => error = "Passwörter stimmen nicht überein");
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    final ok = await widget.authService.register(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => loading = false);

    if (ok) {
      if (!mounted) return;
      Navigator.pop(context); // zurück zum Login
    } else {
      setState(() => error = "Registrierung fehlgeschlagen");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Registrieren",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: "Email",
                  filled: true,
                  fillColor: Colors.white10,
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Passwort",
                  filled: true,
                  fillColor: Colors.white10,
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Passwort bestätigen",
                  filled: true,
                  fillColor: Colors.white10,
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 20),

              if (error != null)
                Text(
                  error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: loading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("Registrieren"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
