part of 'back_of_card_cubit.dart';

abstract class BackOfCardState extends Equatable {
  int widgetIndex;
  BackOfCardState({required this.widgetIndex});

  @override
  List<Object> get props => [widgetIndex];
}

class BackOfCardInitial extends BackOfCardState {
  BackOfCardInitial({required int widgetIndex})
      : super(widgetIndex: widgetIndex);
}
