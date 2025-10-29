class Resource<T> {
  final bool isLoading;
  final dynamic error;
  final T? data;

  Resource._({
    this.isLoading = false,
    this.error,
    this.data,
  });

  factory Resource.success(T? data) => Resource._(
        data: data,
        isLoading: false,
        error: null,
      );

  factory Resource.loading() => Resource._(
        data: null,
        isLoading: true,
        error: null,
      );

  factory Resource.error(dynamic error) => Resource._(
        data: null,
        isLoading: false,
        error: error,
      );

  // bool get isLoadingState => isLoading;

  bool get isSuccess => !isLoading && error == null;

  bool get isError => error != null;
}
