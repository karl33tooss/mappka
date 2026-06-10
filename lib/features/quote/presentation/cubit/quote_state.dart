import 'package:equatable/equatable.dart';
import '../../data/quote_model.dart';

abstract class QuoteState extends Equatable {
  const QuoteState();

  @override
  List<Object?> get props => [];
}

class QuoteInitial extends QuoteState {}

class QuoteLoading extends QuoteState {}

class QuoteLoaded extends QuoteState {
  final QuoteModel quote;
  const QuoteLoaded(this.quote);
  @override
  List<Object?> get props => [quote];
}

class QuoteError extends QuoteState {
  final String message;
  const QuoteError(this.message);
  @override
  List<Object?> get props => [message];
}
