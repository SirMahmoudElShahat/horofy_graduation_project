import 'package:horofy/horofy/data/datasources/mad_letters_datasource.dart';
import 'package:horofy/horofy/domain/entities/mad_letter.dart';
import 'package:horofy/horofy/domain/repositories/mad_letters_repository.dart';

class MadLettersRepositoryImpl implements MadLettersRepository {
  final MadLettersDataSource dataSource;

  MadLettersRepositoryImpl(this.dataSource);

  @override
  List<MadLetter> getMadLetters() => dataSource.getMadLetters();
}