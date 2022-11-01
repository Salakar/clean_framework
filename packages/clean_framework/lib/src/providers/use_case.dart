import 'dart:async';

import 'package:clean_framework/clean_framework_providers.dart';
import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

typedef OutputBuilder<T extends Entity> = Output Function(T);

abstract class UseCase<E extends Entity> extends StateNotifier<E> {
  UseCase({
    required E entity,
    Map<Type, OutputBuilder<E>>? outputFilters,
    Map<Type, Function>? inputFilters,
  })  : _outputFilters = outputFilters ?? const {},
        _inputFilters = inputFilters ?? const {},
        super(entity);

  final Map<Type, OutputBuilder<E>> _outputFilters;
  final Map<Type, Function> _inputFilters;

  final Map<Type, Function> _requestSubscriptions = {};
  final Map<String, Timer> _debounceTimers = {};

  @override
  void dispose() {
    for (final debounceTimer in _debounceTimers.values) {
      debounceTimer.cancel();
    }
    _debounceTimers.clear();
    super.dispose();
  }

  @visibleForTesting
  @protected
  E get entity => super.state;

  @protected
  set entity(E newEntity) => super.state = newEntity;

  /// Executes the [action] so that it will only be executed
  /// when there is no further repeated actions with same [tag]
  /// in a given frame of [duration].
  ///
  /// If [immediate] is false, then then first action will also be debounced.
  @protected
  void debounce({
    required void Function() action,
    required String tag,
    Duration duration = const Duration(milliseconds: 300),
    bool immediate = true,
  }) {
    final timer = _debounceTimers[tag];

    final timerPending = timer?.isActive ?? false;
    final canExecute = immediate && !timerPending;

    timer?.cancel();
    _debounceTimers[tag] = Timer(
      duration,
      () {
        _debounceTimers.remove(tag);
        if (!immediate) action();
      },
    );

    if (canExecute) action();
  }

  O getOutput<O extends Output>() {
    final filter = _outputFilters[O];
    if (filter == null) {
      throw StateError('Output filter not defined for $O');
    }
    return filter(entity) as O;
  }

  void setInput<I extends Input>(I input) {
    if (_inputFilters[I] == null) {
      throw StateError('Input processor not defined for $I');
    }
    final processor = _inputFilters[I]! as InputProcessor<I, E>;
    entity = processor(input, entity);
  }

  void subscribe(Type outputType, Function callback) {
    if (_requestSubscriptions[outputType] != null) {
      throw StateError('A subscription for $outputType already exists');
    }
    _requestSubscriptions[outputType] = callback;
  }

  @protected
  Future<void> request<O extends Output, S extends SuccessInput>(
    O output, {
    required E Function(S successInput) onSuccess,
    required E Function(FailureInput failureInput) onFailure,
  }) async {
    final callback = _requestSubscriptions[O] ??
        (_) => Left<NoSubscriptionFailureInput, S>(
              NoSubscriptionFailureInput(O),
            );

    // ignore: avoid_dynamic_calls
    final either = await callback(output) as Either<FailureInput, S>;
    entity = either.fold(onFailure, onSuccess);
  }
}

typedef InputCallback = void Function<I extends Input>(I input);

typedef InputProcessor<I extends Input, E extends Entity> = E Function(
  I input,
  E entity,
);

typedef SubscriptionFilter<E extends Entity, V extends ViewModel> = V Function(
  E entity,
);

@immutable
abstract class Output extends Equatable {
  @override
  bool get stringify => true;
}

@immutable
abstract class Input {}

class SuccessInput extends Input {}

class FailureInput extends Input {
  FailureInput({this.message = ''});
  final String message;
}

class NoSubscriptionFailureInput extends FailureInput {
  NoSubscriptionFailureInput(Type t)
      : super(message: 'No subscription exists for this request of $t');
}