import 'quote_model.dart';
import '../../../core/network/dio_client.dart';

class QuoteApiService {
  final DioClient _dioClient;
  final String _baseUrl = 'https://zenquotes.io/api/today';

  QuoteApiService(this._dioClient);

  Future<QuoteModel> getDailyQuote () async{
    final responseData = await _dioClient.get(_baseUrl);
    return QuoteModel.fromJson(responseData[0] as Map<String, dynamic>);
  }
}
