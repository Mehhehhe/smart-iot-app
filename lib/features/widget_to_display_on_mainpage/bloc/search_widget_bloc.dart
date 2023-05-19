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
    on<BaseListChanged>(
      (event, emit) {
        // searchDev.addDeviceList(event.dev);
        // List targetList = [];
        // for (var ser in event.dev) {
        //   targetList.add(ser["SerialNumber"]);
        // }
        searchDev = SearchDevice(SearchCache(), event.dev);

        // print("Filter serial: $targetList");
        // emit(SearchStateNewList(dev: targetList));
        // emit(SearchStateEmpty());
      },
    );
    on<TextChanged>(
      _onTextChanged,
      transformer: debounce(const Duration(microseconds: 300)),
    );
  }

  SearchDevice searchDev;

  void _onTextChanged(
    TextChanged event,
    Emitter<SearchWidgetState> emit,
  ) async {
    final searchTerm = event.text;
    if (searchTerm.isEmpty) return emit(SearchStateEmpty());
    emit(SearchStateLoading());
    try {
      final results = searchDev.search(searchTerm);
      print(
          "[SearchResult] ${results.items.map((e) => e.deviceName).toList()}");
      emit(SearchWidgetSuccess(items: results.items));
    } catch (e) {
      emit(e is SearchWidgetError
          ? SearchWidgetError(error: e.error)
          : SearchWidgetError(error: "something went wrong $e"));
    }
  }
}
