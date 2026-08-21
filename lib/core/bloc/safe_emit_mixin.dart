import 'package:flutter/foundation.dart' show protected;
import 'package:flutter_bloc/flutter_bloc.dart';

/// Emit-after-close guard for cubits whose owner can outlive their requests.
///
/// A sheet-owned cubit can be closed while a long-running request (e.g. an
/// up-to-90s AI analysis) is still in flight — drag/back/close dismisses the
/// sheet and closes the cubit; emitting then would throw a [StateError].
/// [safeEmit] silently drops the state instead: nobody is listening anymore.
mixin SafeEmitMixin<S> on Cubit<S> {
  /// Emits [state] unless the cubit is already closed.
  @protected
  void safeEmit(S state) {
    if (!isClosed) emit(state);
  }
}
