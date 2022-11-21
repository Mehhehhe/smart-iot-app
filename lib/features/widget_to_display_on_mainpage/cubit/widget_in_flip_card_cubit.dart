import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'widget_in_flip_card_state.dart';

class BackOfCardCubit extends Cubit<BackOfCardInitial> {
  BackOfCardCubit() : super(BackOfCardInitial(widgetIndex: 0));

  int currentIndex() => state.widgetIndex;
  void chooseIndex(int index) => emit(BackOfCardInitial(widgetIndex: index));
}

class FrontOfCardCubit extends Cubit<FrontOfCardInitial> {
  FrontOfCardCubit() : super(FrontOfCardInitial(widgetIndex: 0));

  int currentIndex() => state.widgetIndex;
  void chooseIndex(int index) => emit(FrontOfCardInitial(widgetIndex: index));
}
