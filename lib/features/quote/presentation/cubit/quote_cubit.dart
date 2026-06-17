import 'package:mappka/features/quote/data/quote_repository.dart';

import 'quote_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuoteCubit extends Cubit<QuoteState>{
  final QuoteRepository _repository;
  QuoteCubit(this._repository) : super(QuoteInitial());

  Future<void> fetchQuote() async {
    emit(QuoteLoading());
    try{
      final quote = await _repository.getQuote();
      emit(QuoteLoaded(quote));
    }
    catch(e){
      emit(QuoteError(e.toString()));
    }
  }
}