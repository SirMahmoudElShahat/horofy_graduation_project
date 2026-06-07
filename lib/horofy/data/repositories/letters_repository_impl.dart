import '../../domain/entities/letter.dart';
import '../../domain/repositories/letters_repository.dart';
import '../datasources/letters_local_data_source.dart';

class LettersRepositoryImpl implements LettersRepository {

  final LettersLocalDataSource localDataSource;

  LettersRepositoryImpl(this.localDataSource);

  @override
  List<Letter> getLetters() {

    return localDataSource.getLetters();

  }

}