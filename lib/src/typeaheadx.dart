import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'typeaheadx_style.dart';

/// TypeAheadX - a powerful, dependency-free search widget with:
/// - Async fetching
/// - Pagination
/// - Keyboard navigation
/// - Custom styling
///
/// Created for reusable packages: zero GetX, zero app-specific dependencies.
class TypeAheadX extends StatefulWidget {
  /// List of local items to filter.
  final List<String> itemList;

  /// Hint text for the search bar.
  final String hintText;

  /// Called whenever a suggestion is selected.
  final ValueChanged<String> onValueChanged;

  /// Called on every text change.
  final ValueChanged<String>? onChanged;

  /// Called when search is submitted (Enter key or search action).
  final ValueChanged<String>? onSubmitted;

  /// Async callback for fetching results (no pagination).
  final Future<List<String>> Function(String)? fetchSuggestions;

  /// Async callback for fetching paginated results.
  final Future<List<String>> Function(String, int, int)? fetchPaginated;

  /// Enable/disable search field.
  final bool enabled;

  /// Enable pagination support.
  final bool pagination;

  /// Items per page for pagination.
  final int pageSize;

  /// Custom style.
  final TypeAheadXStyle style;

  const TypeAheadX({
    super.key,
    required this.itemList,
    required this.hintText,
    required this.onValueChanged,
    this.onChanged,
    this.onSubmitted,
    this.fetchSuggestions,
    this.fetchPaginated,
    this.enabled = true,
    this.pagination = true,
    this.pageSize = 10,
    this.style = const TypeAheadXStyle(),
  });

  @override
  State<TypeAheadX> createState() => _TypeAheadXState();
}

class _TypeAheadXState extends State<TypeAheadX> {
  final SearchController _searchController = SearchController();
  final ScrollController _scrollController = ScrollController();

  final StreamController<List<String>> _resultsStream = StreamController.broadcast();
  final StreamController<bool> _loadingStream = StreamController.broadcast();

  final List<GlobalKey> _itemKeys = [];
  Timer? _debounce;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreResults = false;
  int _selectedIndex = -1;
  List<String> _currentResults = [];

  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener(_handleKeyboard);
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyboard);
    _scrollController.dispose();
    _resultsStream.close();
    _loadingStream.close();
    _debounce?.cancel();
    super.dispose();
  }

  /// Handles up/down/enter key navigation.
  void _handleKeyboard(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.arrowDown) {
        if (_selectedIndex < _currentResults.length - 1) {
          _selectedIndex++;
          _scrollToSelected();
          _resultsStream.add(_currentResults);
        }
      } else if (key == LogicalKeyboardKey.arrowUp) {
        if (_selectedIndex > 0) {
          _selectedIndex--;
          _scrollToSelected();
          _resultsStream.add(_currentResults);
        }
      } else if (key == LogicalKeyboardKey.enter) {
        if (_selectedIndex >= 0 && _selectedIndex < _currentResults.length) {
          final selected = _currentResults[_selectedIndex];
          _onItemSelected(selected);
        }
      }
    }
  }

  /// Scrolls list to keep the selected item visible.
  Future<void> _scrollToSelected() async {
    if (_selectedIndex < 0 || _selectedIndex >= _itemKeys.length) return;
    final context = _itemKeys[_selectedIndex].currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Pagination trigger when user scrolls near bottom.
  void _handleScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      if (widget.pagination && _hasMoreResults && !_isLoadingMore) {
        _loadMore();
      }
    }
  }

  /// Handles user tapping on a suggestion.
  void _onItemSelected(String item) {
    _selectedIndex = -1;
    widget.onValueChanged(item);
    _searchController.closeView(item);
  }

  /// Debounced async fetch.
  void _onQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchResults(query);
    });
  }

  /// Fetch suggestions from API or local list.
  Future<void> _fetchResults(String query) async {
    if (query.isEmpty) {
      _resultsStream.add([]);
      return;
    }

    _loadingStream.add(true);

    try {
      List<String> results = [];

      if (widget.fetchPaginated != null) {
        results = await widget.fetchPaginated!(query, 1, widget.pageSize);
        _currentPage = 1;
        _hasMoreResults = results.length >= widget.pageSize;
      } else if (widget.fetchSuggestions != null) {
        results = await widget.fetchSuggestions!(query);
      } else {
        results = widget.itemList
            .where((e) => e.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }

      _currentResults = results;
      _resultsStream.add(results);
    } catch (e) {
      _resultsStream.add([]);
      debugPrint("TypeAheadX: Error fetching results: $e");
    } finally {
      _loadingStream.add(false);
    }
  }

  /// Loads next page for pagination.
  Future<void> _loadMore() async {
    if (widget.fetchPaginated == null) return;
    _isLoadingMore = true;

    try {
      final nextPage = _currentPage + 1;
      final newItems = await widget.fetchPaginated!(
        _searchController.text,
        nextPage,
        widget.pageSize,
      );
      _currentResults.addAll(newItems);
      _hasMoreResults = newItems.length >= widget.pageSize;
      _currentPage = nextPage;
      _resultsStream.add(_currentResults);
    } catch (e) {
      debugPrint("Pagination error: $e");
    } finally {
      _isLoadingMore = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return TextField(
        enabled: false,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: OutlineInputBorder(
            borderRadius: widget.style.borderRadius,
            borderSide: BorderSide(
              color: widget.style.borderColor,
              width: widget.style.borderWidth,
            ),
          ),
        ),
      );
    }

    return SearchAnchor.bar(
      searchController: _searchController,
      barHintText: widget.hintText,
      barSide: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return const BorderSide(color: Colors.blue, width: 1);
        }
        return  BorderSide(
          color: widget.style.borderColor,
          width: 1,
        );
      }),
      barShape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        _onQueryChanged(value);
        widget.onChanged?.call(value);
      },
      onSubmitted: widget.onSubmitted,
      suggestionsBuilder: _suggestionsBuilder,
      barHintStyle: WidgetStatePropertyAll(widget.style.hintStyle),
      barTextStyle: WidgetStatePropertyAll(widget.style.textStyle),
      barBackgroundColor: WidgetStatePropertyAll(widget.style.backgroundColor),
      viewBackgroundColor: widget.style.backgroundColor,
      viewShape: RoundedRectangleBorder(
        borderRadius: widget.style.borderRadius,
        side: BorderSide(color: widget.style.borderColor),
      ),
    );
  }

  /// Stream-driven suggestions builder.
  Future<List<Widget>> _suggestionsBuilder(
      BuildContext context,
      SearchController controller,
      ) async {
    return [
      StreamBuilder<bool>(
        stream: _loadingStream.stream,
        builder: (context, snapshotLoading) {
          final isLoading = snapshotLoading.data ?? false;
          return StreamBuilder<List<String>>(
            stream: _resultsStream.stream,
            builder: (context, snapshotResults) {
              final results = snapshotResults.data ?? [];
              _itemKeys.clear();
              _itemKeys.addAll(List.generate(results.length, (_) => GlobalKey()));

              if (isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (results.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      "No data available",
                      style: TextStyle(color: AppColors.greyText),
                    ),
                  ),
                );
              }

              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    final bool isSelected = index == _selectedIndex;

                    return KeyedSubtree(
                      key: _itemKeys[index],
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 80),
                        color: isSelected
                            ? widget.style.highlightColor
                            : Colors.transparent,
                        child: ListTile(
                          title: Text(item, style: widget.style.textStyle),
                          onTap: () => _onItemSelected(item),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    ];
  }
}