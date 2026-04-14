import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../services/supabase_service.dart';
import '../main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = SupabaseService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await _authService.signIn(email, password);
      } else {
        await _authService.signUp(email, password);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro exitoso. Revisa tu correo si es necesario.')),
          );
        }
      }
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGuest() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInAnonymously();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF0F2FF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40),
            child: Column(
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_stories_rounded, size: 60, color: Color(0xFF6C63FF)),
                  ),
                ),
                const SizedBox(height: 32),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    _isLogin ? 'Bienvenido de nuevo' : 'Crea tu cuenta',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D2C3C)),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInDown(
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    _isLogin ? 'Inicia sesión para continuar' : 'Únete a la mejor gestión académica',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ),
                const SizedBox(height: 48),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Correo electrónico',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : Text(_isLogin ? 'Iniciar Sesión' : 'Registrarse', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_isLogin ? '¿No tienes cuenta?' : '¿Ya tienes cuenta?'),
                      TextButton(
                        onPressed: () => setState(() => _isLogin = !_isLogin),
                        child: Text(_isLogin ? 'Regístrate' : 'Inicia Sesión', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C63FF))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('O', style: TextStyle(color: Colors.grey))),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: _handleGuest,
                  icon: const Icon(Icons.person_outline_rounded, color: Colors.grey),
                  label: const Text('Continuar como invitado', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
