part of 'widget_in_flip_card_cubit.dart';

abstract class CardState extends Equatable {
  int widgetIndex;
  CardState({required this.widgetIndex});

  @override
  List<Object> get props => [widgetIndex];
}

class BackOfCardInitial extends CardState {
  BackOfCardInitial({required int widgetIndex})
      : super(widgetIndex: widgetIndex);
}

class FrontOfCardInitial extends CardState {
  FrontOfCardInitial({required int widgetIndex})
      : super(widgetIndex: widgetIndex);
}
