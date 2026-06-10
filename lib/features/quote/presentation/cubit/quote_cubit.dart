import 'quote_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/quote_api_service.dart';

class QuoteCubit extends Cubit<QuoteState>{
  final QuoteApiService _quoteApiService;
  QuoteCubit(this._quoteApiService) : super(QuoteInitial());

  Future<void> fetchQuote() async {
    emit(QuoteLoading());
    try{
      final quote = await _quoteApiService.getDailyQuote();
      emit(QuoteLoaded(quote));
    }
    catch(e){
      emit(QuoteError(e.toString()));
    }
  }
}