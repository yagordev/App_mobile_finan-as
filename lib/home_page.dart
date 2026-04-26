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
    final focusedDate = finance.focusedMonth;
    
    final realBalance = finance.getRealBalance(focusedDate.month, focusedDate.year);
    final projectedBalance = finance.getProjectedBalance(focusedDate.month, focusedDate.year);
    
    final incomes = finance.getTotalIncomes(focusedDate.month, focusedDate.year);
    final expenses = finance.getTotalExpenses(focusedDate.month, focusedDate.year);
    
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final monthLabel = DateFormat('MMMM yyyy', 'pt_BR').format(focusedDate);

    final transactions = finance.getTransactionsByMonth(focusedDate.month, focusedDate.year);
    final hasPending = transactions.any((t) => !t.isConfirmed);

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
            // Seletor de Mês
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary),
                    onPressed: finance.previousMonth,
                  ),
                  Text(
                    monthLabel.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: 1,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                    onPressed: finance.nextMonth,
                  ),
                ],
              ),
            ),

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
                        'SALDO REAL (CONFIRMADO)',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const Icon(Icons.verified_user_outlined, color: Colors.white54, size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(realBalance),
                    style: GoogleFonts.inter(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Previsto: ',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                        ),
                        Text(
                          currencyFormat.format(projectedBalance),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
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
                  'Atividades do Mês',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                if (hasPending)
                  TextButton.icon(
                    onPressed: () => finance.confirmAllInPeriod(focusedDate.month, focusedDate.year),
                    icon: const Icon(Icons.done_all_rounded, size: 18),
                    label: const Text('Baixar tudo', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Lista de transações ou placeholder
            if (transactions.isEmpty)
              _buildEmptyState()
            else
              ...transactions.reversed.map((t) {
                final category = finance.categories.firstWhere((c) => c.id == t.categoryId);
                return _TransactionTile(
                  transaction: t, 
                  category: category,
                  onToggle: () => finance.toggleTransactionConfirmation(t.id),
                );
              }),
            const SizedBox(height: 80), // Espaço para o FAB
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
  final VoidCallback onToggle;

  const _TransactionTile({
    required this.transaction, 
    required this.category,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isIncome = transaction.type == TransactionType.income;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: transaction.isConfirmed ? null : Border.all(color: AppColors.primary.withOpacity(0.1)),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Botão de Confirmação (Checkmark)
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: transaction.isConfirmed ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: transaction.isConfirmed ? AppColors.primary : AppColors.textGrey.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: transaction.isConfirmed 
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
            ),
          ),
          const SizedBox(width: 12),
          
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(category.colorValue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(IconData(category.iconCode, fontFamily: 'MaterialIcons'), color: Color(category.colorValue), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description?.isNotEmpty == true ? transaction.description! : category.name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, 
                    fontSize: 14, 
                    color: transaction.isConfirmed ? AppColors.textDark : AppColors.textDark.withOpacity(0.5),
                  ),
                ),
                Text(
                  DateFormat('dd MMM').format(transaction.date),
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'} ${format.format(transaction.value)}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: isIncome ? AppColors.income : AppColors.expense,
                ),
              ),
              if (!transaction.isConfirmed)
                Text(
                  'PENDENTE',
                  style: GoogleFonts.inter(
                    fontSize: 9, 
                    fontWeight: FontWeight.bold, 
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
