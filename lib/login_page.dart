import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'home_page.dart';

/// Tela de Login
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

  // FocusNode para controlar o foco da senha
  final FocusNode _senhaFocus = FocusNode();

  @override
  void dispose() {
    emailCtrl.dispose();
    senhaCtrl.dispose();
    _senhaFocus.dispose();
    super.dispose();
  }

  /// Faz login e navega para Home com transição Fade
  Future<void> _entrar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => carregando = true);
    await Future.delayed(const Duration(seconds: 1)); // Substitua por API real
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
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _LoginCard(
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
            ),
          ),
        ),
      ),
    );
  }
}

/// Card de login extraído em widget separado
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
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.lock, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text('Entrar', style: t.headlineLarge),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Acesse sua conta usando seu e-mail e senha.',
              style: t.bodyLarge?.copyWith(color: AppColors.secondaryGreen),
            ),
            const SizedBox(height: 18),

            // Campo E-mail — ao pressionar Enter, move foco para senha
            TextFormField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(senhaFocus);
              },
              decoration: InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email, color: AppColors.secondaryGreen),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppColors.secondaryGreen.withOpacity(0.45)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.primaryGreen, width: 2),
                ),
              ),
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return 'Informe seu e-mail';

                // Regex completo para validar e-mail
                final emailRegex = RegExp(
                  r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
                );
                if (!emailRegex.hasMatch(value)) return 'E-mail inválido';

                return null;
              },
            ),
            const SizedBox(height: 12),

            // Campo Senha — ao pressionar Enter, tenta fazer login
            TextFormField(
              controller: senhaCtrl,
              focusNode: senhaFocus,
              obscureText: esconderSenha,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => carregando ? null : onEntrar(),
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon:
                Icon(Icons.password, color: AppColors.secondaryGreen),
                suffixIcon: IconButton(
                  onPressed: onToggleSenha,
                  icon: Icon(
                    esconderSenha ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.secondaryGreen,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppColors.secondaryGreen.withOpacity(0.45)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.primaryGreen, width: 2),
                ),
              ),
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return 'Informe sua senha';
                if (value.length < 4) return 'Senha muito curta';
                return null;
              },
            ),
            const SizedBox(height: 10),

            // Link "Esqueci a senha"
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Recuperação de senha (simulação)')),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondaryGreen,
                ),
                child: const Text('Esqueci minha senha'),
              ),
            ),
            const SizedBox(height: 6),

            // Botão Entrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: carregando ? null : onEntrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: carregando
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
                    : const Text(
                  'Entrar',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Rodapé: criar conta
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Não tem conta? ',
                  style: t.bodyLarge?.copyWith(color: AppColors.textDark),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cadastro (simulação)')),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondaryGreen,
                  ),
                  child: const Text(
                    'Criar conta',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
