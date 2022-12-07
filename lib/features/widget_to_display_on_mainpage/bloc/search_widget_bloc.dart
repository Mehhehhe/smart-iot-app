import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_iot_app/model/SearchResult.dart';
import 'package:stream_transform/stream_transform.dart';

part 'search_widget_event.dart';
part 'search_widget_state.dart';

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class SearchWidgetBloc extends Bloc<SearchWidgetEvent, SearchWidgetState> {
  SearchWidgetBloc({required this.searchDev}) : super(SearchStateEmpty()) {
    on<TextChanged>((event, emit) {
      // TODO: implement event handler
    });
  }

  final SearchDevice searchDev;

  void _onTextChanged(
      TextChanged event, Emitter<SearchWidgetState> emit) async {
    final searchTerm = event.text;
    if (searchTerm.isEmpty) return emit(SearchStateEmpty());
    emit(SearchStateLoading());
    try {
      final results = searchDev.search(searchTerm);
      emit(SearchWidgetSuccess(items: results.items));
    } catch (e) {
      emit(e is SearchWidgetError
          ? SearchWidgetError(error: e.error)
          : SearchWidgetError(error: "something went wrong"));
    }
  }
}
