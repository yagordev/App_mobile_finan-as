import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController senhaCtrl = TextEditingController();
  bool esconderSenha = true;
  bool carregando = false;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _senhaFocus = FocusNode();

  @override
  void dispose() {
    emailCtrl.dispose();
    senhaCtrl.dispose();
    _senhaFocus.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => carregando = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => carregando = false);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => HomePage(email: emailCtrl.text.trim()),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Bem-vindo!',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gerencie suas finanças de forma simples.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _LoginCard(
                    formKey: _formKey,
                    emailCtrl: emailCtrl,
                    senhaCtrl: senhaCtrl,
                    senhaFocus: _senhaFocus,
                    esconderSenha: esconderSenha,
                    onToggleSenha: () =>
                        setState(() => esconderSenha = !esconderSenha),
                    carregando: carregando,
                    onEntrar: _entrar,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController senhaCtrl;
  final FocusNode senhaFocus;
  final bool esconderSenha;
  final VoidCallback onToggleSenha;
  final bool carregando;
  final VoidCallback onEntrar;

  const _LoginCard({
    required this.formKey,
    required this.emailCtrl,
    required this.senhaCtrl,
    required this.senhaFocus,
    required this.esconderSenha,
    required this.onToggleSenha,
    required this.carregando,
    required this.onEntrar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(senhaFocus),
              decoration: _inputDecoration('E-mail', Icons.email_outlined),
              validator: (v) {
                if ((v ?? '').isEmpty) return 'Informe seu e-mail';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: senhaCtrl,
              focusNode: senhaFocus,
              obscureText: esconderSenha,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => carregando ? null : onEntrar(),
              decoration: _inputDecoration(
                'Senha',
                Icons.lock_outline,
                suffix: IconButton(
                  onPressed: onToggleSenha,
                  icon: Icon(
                    esconderSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textGrey,
                    size: 20,
                  ),
                ),
              ),
              validator: (v) {
                if ((v ?? '').isEmpty) return 'Informe sua senha';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                child: const Text('Esqueci minha senha', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: carregando ? null : onEntrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: carregando
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                    : const Text('Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.background,
      labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }
}
