import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'app_colors.dart';
import 'login_page.dart';
import 'providers/finance_provider.dart';
import 'transaction_form_page.dart';
import 'models/transaction_model.dart';
import 'models/category_model.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              radius: 18,
              child: const Icon(Icons.person, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Olá,', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey)),
                Text(email.split('@')[0], style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textDark),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TransactionFormPage()),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de Saldo Moderno
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SALDO ATUAL',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const Icon(Icons.account_balance_wallet_outlined, color: Colors.white54, size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(balance),
                    style: GoogleFonts.inter(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    monthName.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Resumo Rápido
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Receitas',
                    value: currencyFormat.format(incomes),
                    icon: Icons.arrow_upward_rounded,
                    color: AppColors.income,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryCard(
                    label: 'Despesas',
                    value: currencyFormat.format(expenses),
                    icon: Icons.arrow_downward_rounded,
                    color: AppColors.expense,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Seção de Transações
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Últimas Atividades',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Ver tudo', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Lista de transações ou placeholder
            if (finance.getTransactionsByMonth(now.month, now.year).isEmpty)
              _buildEmptyState()
            else
              ...finance.getTransactionsByMonth(now.month, now.year).reversed.take(5).map((t) {
                final category = finance.categories.firstWhere((c) => c.id == t.categoryId);
                return _TransactionTile(transaction: t, category: category);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.history_rounded, size: 48, color: AppColors.textGrey.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(
            'Nenhuma transação este mês',
            style: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 15, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 12),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final CategoryModel category;

  const _TransactionTile({required this.transaction, required this.category});

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isIncome = transaction.type == TransactionType.income;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Color(category.colorValue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(IconData(category.iconCode, fontFamily: 'MaterialIcons'), color: Color(category.colorValue), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description?.isNotEmpty == true ? transaction.description! : category.name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark),
                ),
                Text(
                  DateFormat('dd MMM').format(transaction.date),
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'} ${format.format(transaction.value)}',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: isIncome ? AppColors.income : AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }
}
