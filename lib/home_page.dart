import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'app_colors.dart';
import 'login_page.dart';
import 'providers/finance_provider.dart';

class HomePage extends StatelessWidget {
  final String email;

  const HomePage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final now = DateTime.now();
    final balance = finance.getTotalBalance(now.month, now.year);
    final incomes = finance.getTotalIncomes(now.month, now.year);
    final expenses = finance.getTotalExpenses(now.month, now.year);
    
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final monthName = DateFormat('MMMM', 'pt_BR').format(now);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Financeiro',
              style: GoogleFonts.darkerGrotesque(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const LoginPage(),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 500),
                ),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navegar para tela de cadastro
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Em breve: Cadastro de Transação')),
          );
        },
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card de Saldo Total
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo Total (${monthName.toUpperCase()})',
                      style: GoogleFonts.darkerGrotesque(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(balance),
                      style: GoogleFonts.darkerGrotesque(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Título da seção
              Text(
                'Resumo do Mês',
                style: GoogleFonts.darkerGrotesque(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 14),

              // Cards de Receitas e Despesas
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.arrow_upward,
                      iconColor: Colors.green,
                      label: 'Receitas',
                      value: currencyFormat.format(incomes),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.arrow_downward,
                      iconColor: Colors.red,
                      label: 'Despesas',
                      value: currencyFormat.format(expenses),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _MetricCard(
                icon: Icons.receipt_long,
                iconColor: AppColors.primaryGreen,
                label: 'Transações no período',
                value: finance.getTransactionsByMonth(now.month, now.year).length.toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card de métrica reutilizável
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.darkerGrotesque(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    height: 1.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: GoogleFonts.darkerGrotesque(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

