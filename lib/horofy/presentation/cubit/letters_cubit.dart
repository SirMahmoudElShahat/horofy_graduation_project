import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/horofy/domain/usecases/letters_usecase.dart';
import 'letters_state.dart';

class LettersCubit extends Cubit<LettersState> {

  final GetLettersUseCase getLettersUseCase;

  LettersCubit(this.getLettersUseCase) : super(LettersInitial());

  void loadLetters() {

    final letters = getLettersUseCase();

    emit(LettersLoaded(letters));

  }

}