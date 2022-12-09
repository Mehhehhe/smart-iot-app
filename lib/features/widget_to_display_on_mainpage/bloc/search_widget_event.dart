part of 'search_widget_bloc.dart';

abstract class SearchWidgetEvent extends Equatable {
  const SearchWidgetEvent();
}

class TextChanged extends SearchWidgetEvent {
  const TextChanged({required this.text});

  final String text;

  @override
  List<Object> get props => [text];
}

class BaseListChanged extends SearchWidgetEvent {
  List dev;
  BaseListChanged(this.dev);

  @override
  List<Object> get props => [dev];
}
