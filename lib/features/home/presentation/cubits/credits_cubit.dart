import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';
import 'package:skillswap/core/constants/app_constants.dart';

abstract class CreditsState extends Equatable {
  const CreditsState();
  @override
  List<Object?> get props => [];
}

class CreditsInitial extends CreditsState {}

class CreditsLoading extends CreditsState {}

class CreditsLoaded extends CreditsState {
  /// Stored in centi-credits (1 credit = 100 minor units).
  final int balanceMinor;
  final double balance;
  final int escrowBalanceMinor;
  final double escrowBalance;
  final List<dynamic> transactions;

  const CreditsLoaded({
    required this.balanceMinor,
    required this.balance,
    required this.escrowBalanceMinor,
    required this.escrowBalance,
    required this.transactions,
  });

  @override
  List<Object?> get props => [
        balanceMinor,
        balance,
        escrowBalanceMinor,
        escrowBalance,
        transactions,
      ];
}

class CreditsError extends CreditsState {
  final String message;
  const CreditsError(this.message);
  @override
  List<Object?> get props => [message];
}

class CreditsCubit extends Cubit<CreditsState> {
  final HomeRepository _homeRepository;

  CreditsCubit(this._homeRepository) : super(CreditsInitial());

  Future<void> fetchCredits() async {
    emit(CreditsLoading());
    final result = await _homeRepository.getCredits();
    result.fold((failure) => emit(CreditsError(failure.message)), (data) {
      final balanceMinor = (data['balance_minor'] as num?)?.toInt() ?? 0;
      final balance = (data['balance'] as num?)?.toDouble() ??
          (balanceMinor / AppConstants.minorScale.toDouble());
      final escrowBalanceMinor = (data['escrow_balance_minor'] as num?)?.toInt() ?? 0;
      final escrowBalance = (data['escrow_balance'] as num?)?.toDouble() ??
          (escrowBalanceMinor / AppConstants.minorScale.toDouble());

      emit(
        CreditsLoaded(
          balanceMinor: balanceMinor,
          balance: balance,
          escrowBalanceMinor: escrowBalanceMinor,
          escrowBalance: escrowBalance,
          transactions: List<dynamic>.from(data['transactions'] ?? []),
        ),
      );
    });
  }
}
