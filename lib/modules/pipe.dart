extension IterablePipe<T> on Iterable<T> {
  /// ## `pipe`(`Iterable<Function>`, [`enableDebugging`])(`value`)
  ///
  /// Run a set of functions from `Iterable<Function>` with input `value`
  /// which may return `Null` if function did not return any such as void.
  ///
  ///
  /// **Optional**: `enableDebugging` for printing value of each function output
  ///
  /// Example:
  /// ```
  /// add2(x) => x + 2;
  /// sub2(x) => x - 2;
  /// mul2(x) => x * 2;
  /// div2(x) => x / 2;
  /// void main() {
  ///   Iterable a = Iterable.empty();
  ///   var aPiped = a.pipe([add2, mul2, mul2, sub2], true)(5);
  ///   print(aPiped.runtimeType);
  /// }
  /// ```
  ///
  /// Output:
  /// ```
  /// [PIPE{5}@ Closure 'add2'] foldN'get:=7
  /// [PIPE{5}@ Closure 'mul2'] foldN'get:=14
  /// [PIPE{5}@ Closure 'mul2'] foldN'get:=28
  /// [PIPE{5}@ Closure 'sub2'] foldN'get:=26
  /// int
  /// ```
  pipe(Iterable<Function> funs, [bool enableDebugging = false]) => (value) {
        return funs.fold(value, (previousValue, element) {
          if (enableDebugging) {
            print(
                "[PIPE{$value}@ $element] foldN'get:=${element(previousValue)}");
          }
          return element(previousValue);
        });
      };
}
