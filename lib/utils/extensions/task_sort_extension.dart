import '../../data/model/task_model.dart';

extension TaskModelSorting on List<TaskModel> {
  //  i used merge sort here
  void sortByCreated({bool descending = true}) {
    if (length < 2) return;
    final buffer = List<TaskModel>.from(this);
    _mergeSort(buffer, this, 0, length, descending);
  }

  void _mergeSort(List<TaskModel> src, List<TaskModel> dest, int start,
      int end, bool descending) {
    if (end - start <= 1) return;
    final mid = (start + end) >> 1;
    _mergeSort(dest, src, start, mid, descending);
    _mergeSort(dest, src, mid, end, descending);
    _merge(src, dest, start, mid, end, descending);
  }

  void _merge(List<TaskModel> src, List<TaskModel> dest, int start, int mid,
      int end, bool descending) {
    var i = start, j = mid;
    for (var k = start; k < end; k++) {
      if (i < mid &&
          (j >= end ||
              _compare(src[i], src[j], descending) <= 0)) {
        dest[k] = src[i++];
      } else {
        dest[k] = src[j++];
      }
    }
  }

  int _compare(TaskModel a, TaskModel b, bool descending) {
    final cmp = a.createdAt.compareTo(b.createdAt);
    return descending ? -cmp : cmp;
  }
}
