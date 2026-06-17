import 'package:hive_flutter/hive_flutter.dart';
import 'quote_api_service.dart';
import 'quote_model.dart';

class QuoteRepository {
  final QuoteApiService _apiService;
  final String _boxName = 'quote_box';
  final String _quoteKey = 'daily_quote';

  QuoteRepository(this._apiService);

  Future<QuoteModel> getQuote()async{
    final box = Hive.box<QuoteModel>(_boxName);
    try{
      final quoteFromApi = await _apiService.getDailyQuote();
      await box.put(_quoteKey, quoteFromApi);
      return quoteFromApi;
    } catch(e)
    {
      final cachedQuote = await box.get(_quoteKey);
      if(cachedQuote != null){
        return cachedQuote;
      }
      else{
        throw Exception("No internet connection and no cached data loaded before");
      }
    }
  }
}