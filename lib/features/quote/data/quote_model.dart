import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'quote_model.g.dart';

@HiveType(typeId: 0)
class QuoteModel extends Equatable{
  @HiveField(0)
  final String quote;
  @HiveField(1)
  final String author;

  QuoteModel({
    required this.quote,
    required this.author});

  factory QuoteModel.fromJson(Map<String, dynamic> json){
    return QuoteModel(
      quote: json['q'] as String, 
      author: json['a'] as String);
  }

  @override
  List<Object?> get props => [quote,author];
}