part of 'search_widget_bloc.dart';

abstract class SearchWidgetState extends Equatable {
  const SearchWidgetState();

  @override
  List<Object> get props => [];
}

class SearchStateEmpty extends SearchWidgetState {}

class SearchStateNewList extends SearchWidgetState {
  const SearchStateNewList({required this.dev});
  final List dev;

  @override
  List<Object> get props => [dev];
}

class SearchStateLoading extends SearchWidgetState {}

class SearchWidgetSuccess extends SearchWidgetState {
  const SearchWidgetSuccess({required this.items});
  final List<ResultItem> items;

  @override
  List<Object> get props => [items];
}

class SearchWidgetError extends SearchWidgetState {
  final String error;
  const SearchWidgetError({required this.error});

  @override
  List<Object> get props => [error];
}
