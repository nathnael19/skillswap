import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';
import 'package:skillswap/init_dependencies.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/constants/app_constants.dart';
import 'package:skillswap/core/constants/payment_methods.dart';
import 'package:skillswap/features/home/presentation/cubits/credits_cubit.dart';
import 'package:skillswap/core/theme/theme.dart';

class WithdrawPage extends StatefulWidget {
  final double currentBalance;
  const WithdrawPage({super.key, required this.currentBalance});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  String _selectedMethod = 'cbe';
  bool _isLoading = false;

  final Map<String, String> _methods = PaymentMethods.withdrawal;

  @override
  void dispose() {
    _amountController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  Future<void> _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final amountMinor = (double.parse(_amountController.text) * AppConstants.minorScale).toInt();
    final repo = serviceLocator<HomeRepository>();

    final result = await repo.requestWithdrawal(
      amountMinor: amountMinor,
      method: _selectedMethod,
      accountNumber: _accountNumberController.text.trim(),
      accountName: _accountNameController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
        );
      },
      (data) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Withdrawal request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh wallet and pop
        context.read<CreditsCubit>().fetchCredits();
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBgColor = AppColors.background;
    const accentColor = AppColors.primary;
    const cardColor = AppColors.surface;

    return Scaffold(
      backgroundColor: primaryBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Withdraw',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Available Balance',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.currentBalance.toStringAsFixed(2)} ${AppConstants.currencyLabel}',
                      style: GoogleFonts.dmSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Payment Method',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.overlay50,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              ..._methods.entries.map((entry) {
                final isSelected = _selectedMethod == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => setState(() => _selectedMethod = entry.key),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accentColor.withValues(alpha: 0.1)
                            : cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? accentColor : AppColors.overlay05,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            entry.key == 'cbe'
                                ? Icons.account_balance_rounded
                                : Icons.phone_android_rounded,
                            color: isSelected
                                ? accentColor
                                : AppColors.overlay40,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            entry.value,
                            style: GoogleFonts.dmSans(
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.overlay60,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: accentColor,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),
              _buildTextField(
                label: 'Amount',
                controller: _amountController,
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter amount';
                  final amount = double.tryParse(val);
                  if (amount == null || amount <= 0) {
                    return 'Enter valid amount';
                  }
                  if (amount > widget.currentBalance) {
                    return 'Insufficient balance';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Account Number',
                controller: _accountNumberController,
                hint: 'Enter your account or phone number',
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Enter account number'
                    : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Account Name',
                controller: _accountNameController,
                hint: 'Enter full name on account',
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Enter account name' : null,
              ),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitWithdrawal,
                  style:
                      ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: AppColors.textPrimary,
                        shape: RoundedRectanglePlatform.borderRadiusCircular(
                          22,
                        ),
                        elevation: 0,
                      ).copyWith(
                        backgroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.disabled)) {
                            return accentColor.withValues(alpha: 0.5);
                          }
                          return accentColor;
                        }),
                      ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.textPrimary,
                        )
                      : Text(
                          'Withdraw',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    const cardColor = AppColors.surface;
    const accentColor = AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppColors.overlay40,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: GoogleFonts.dmSans(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: cardColor,
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(
              color: AppColors.textPrimary.withValues(alpha: 0.15),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.overlay05),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: accentColor),
            ),
            errorStyle: GoogleFonts.dmSans(
              color: Colors.redAccent,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

// Helper to handle both platforms' border radius if needed, but since it's just a shape:
class RoundedRectanglePlatform {
  static OutlinedBorder borderRadiusCircular(double radius) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
}
