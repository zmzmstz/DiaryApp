import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/api_repository.dart';
import 'search_event_state.dart';

export 'search_event_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ApiRepository _apiRepository;

  SearchBloc(this._apiRepository) : super(SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchCleared>(_onSearchCleared);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      final results = await _apiRepository.searchAll(query);
      emit(SearchLoaded(results, query));
    } catch (e) {
      emit(SearchError('Arama sırasında bir hata oluştu: $e'));
    }
  }

  void _onSearchCleared(SearchCleared event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }
}
