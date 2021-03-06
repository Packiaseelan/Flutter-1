import 'package:bloc/bloc.dart';
import 'package:flutter_boilerplate/feature/home/bloc/index.dart';
import 'package:flutter_boilerplate/feature/home/model/book.dart';
import 'package:flutter_boilerplate/feature/home/resource/home_repository.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class BooksBloc extends Bloc<BookEvent, BookState> {
  final HomeRepository homeRepository;

  BooksBloc({@required this.homeRepository}) : assert(homeRepository != null);

  @override
  BookState get initialState => BookEmpty();

  @override
  Stream<BookState> transformEvents(
    Stream<BookEvent> events,
    Stream<BookState> Function(BookEvent event) next,
  ) {
    return super.transformEvents(
      events.debounceTime(
        const Duration(milliseconds: 500),
      ),
      next,
    );
  }

  @override
  Stream<BookState> mapEventToState(BookEvent event) async* {
    final BookState currentState = state;

    if (event is Fetch) {
      try {
        if (currentState is BookEmpty) {
          yield BookLoading();
          final List<Book> books = await _fetchBooks();
          yield BookLoaded(books: books);
          return;
        }
        if (currentState is BookLoaded) {
          final List<Book> posts = await _fetchBooks();
          yield posts.isEmpty
              ? currentState.copyWith()
              : BookLoaded(books: currentState.books + posts);
        }
      } catch (_) {
        yield BookError();
      }
    }
  }

  Future<List<Book>> _fetchBooks() async {
    final Map response = await homeRepository.fetchBooks();
    print(response);
    if (!response['error']) {
      final List<Book> _books = (response['data'] as List)?.map((dynamic e) {
        return e == null ? null : Book.fromJson(e as Map<String, dynamic>);
      })?.toList();
      return _books;
    } else {
      throw Exception('error fetching posts');
    }
  }
}
