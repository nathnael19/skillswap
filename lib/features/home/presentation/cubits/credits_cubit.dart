import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';

abstract class CreditsState extends Equatable {
  const CreditsState();
  @override
  List<Object?> get props => [];
}

class CreditsInitial extends CreditsState {}
class CreditsLoading extends CreditsState {}
class CreditsLoaded extends CreditsState {
  final int balance;
  final List<dynamic> transactions;
  const CreditsLoaded(this.balance, this.transactions);
  @override
  List<Object?> get props => [balance, transactions];
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
    result.fold(
      (failure) => emit(CreditsError(failure.message)),
      (data) => emit(CreditsLoaded(data['balance'] ?? 0, data['transactions'] ?? [])),
    );
  }
}
