import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/providers.dart';
import '../../core/network/api_paths.dart';

/// Timer teknisi yang robust:
/// - start/pause/finish via server (WorkshopFlowService, lockForUpdate).
/// - Status aktif dipersist lokal (taskId + startedAt) agar survive
///   background/sleep/kill/restart; durasi otoritatif = timeEntries server.
/// - Cegah duplikat: satu aktif per device; start saat in_progress = no-op server.
/// - Clock-change tolerant: tidak memakai jam device untuk billing.
class TimerState {
  const TimerState({this.activeTaskId, this.startedAtIso});
  final int? activeTaskId;
  final String? startedAtIso;
  bool get running => activeTaskId != null;
}

final timerProvider = StateNotifierProvider<TimerVM, TimerState>(
  (ref) => TimerVM(ref),
);

class TimerVM extends StateNotifier<TimerState> {
  TimerVM(this._ref) : super(const TimerState()) {
    _restore();
  }
  final Ref _ref;
  static const _kTask = 'timer_task_id';
  static const _kAt = 'timer_started_at';

  Future<void> _restore() async {
    final p = await SharedPreferences.getInstance();
    final id = p.getInt(_kTask);
    final at = p.getString(_kAt);
    if (id != null) state = TimerState(activeTaskId: id, startedAtIso: at);
  }

  /// Sinkron dari server setelah reconnect/resume: GET detail task,
  /// bila status bukan in_progress/paused → clear lokal.
  Future<void> syncFromServer() async {
    final id = state.activeTaskId;
    if (id == null) return;
    try {
      final d = await _ref
          .read(genericRemoteProvider)
          .detail('${ApiPaths.workTasks}/$id');
      final st = '${d['status'] ?? ''}';
      if (st != 'in_progress' && st != 'paused') {
        await clear();
      }
    } catch (_) {
      // offline: pertahankan lokal, sinkron lagi saat online
    }
  }

  Future<void> start(int taskId) async {
    final cur = state.activeTaskId;
    if (cur != null && cur != taskId) {
      throw StateError('Ada timer aktif (task $cur). Selesaikan dulu.');
    }
    await _ref.read(apiProvider).dio.post(ApiPaths.taskStart(taskId));
    final p = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    await p.setInt(_kTask, taskId);
    await p.setString(_kAt, now);
    state = TimerState(activeTaskId: taskId, startedAtIso: now);
  }

  Future<void> pause() async {
    final id = state.activeTaskId;
    if (id == null) return;
    await _ref.read(apiProvider).dio.post(ApiPaths.taskPause(id));
    await clear();
  }

  Future<void> finish() async {
    final id = state.activeTaskId;
    if (id == null) return;
    await _ref.read(apiProvider).dio.post(ApiPaths.taskFinish(id));
    await clear();
  }

  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kTask);
    await p.remove(_kAt);
    state = const TimerState();
  }
}
