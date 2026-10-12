import 'dart:math';

class ClosedLoopFinder {
  static List<Point<int>> find(
    List<List<bool>> isBasic,
    int startR,
    int startC,
    int rows,
    int cols,
  ) {
    List<Point<int>> path = [];
    Set<String> visited = {};

    bool dfs(int r, int c, bool isHorizontal, bool isFirst) {
      // Base case: si regresamos al origen
      if (!isFirst && r == startR && c == startC) return true;

      String key = "$r,$c,$isHorizontal";
      if (visited.contains(key)) return false;
      visited.add(key);

      if (isHorizontal) {
        for (int nextC = 0; nextC < cols; nextC++) {
          if (nextC != c &&
              (isBasic[r][nextC] || (r == startR && nextC == startC))) {
            path.add(Point(r, nextC));
            if (dfs(r, nextC, !isHorizontal, false)) return true;
            path.removeLast();
          }
        }
      } else {
        for (int nextR = 0; nextR < rows; nextR++) {
          if (nextR != r &&
              (isBasic[nextR][c] || (nextR == startR && c == startC))) {
            path.add(Point(nextR, c));
            if (dfs(nextR, c, !isHorizontal, false)) return true;
            path.removeLast();
          }
        }
      }
      return false;
    }

    path.add(Point(startR, startC));
    if (dfs(startR, startC, true, true)) {
      path.removeLast(); // elimina el punto duplicado al cerrar el polígono
      return path;
    }

    path.clear();
    path.add(Point(startR, startC));
    if (dfs(startR, startC, false, true)) {
      path.removeLast();
      return path;
    }

    return [];
  }
}
