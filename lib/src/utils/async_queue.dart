import 'dart:async';
import 'dart:collection';

typedef FutureFunc = Future<void> Function();

class AsyncActionQueue {
  final Queue<FutureFunc> _actions = Queue<FutureFunc>();
  bool _isProcessing = false;

  Future<void> enqueue(FutureFunc action) {
    _actions.add(action);
    return _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing) {
      return;
    }
    while (_actions.isNotEmpty) {
      _isProcessing = true;
      FutureFunc currentAction = _actions.removeFirst();
      await currentAction();
      _isProcessing = false;
    }
  }
}