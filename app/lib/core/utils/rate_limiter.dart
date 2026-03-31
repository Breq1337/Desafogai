/// Rate limiter simples com sliding window
class RateLimiter {
  final int maxRequests;
  final Duration window;
  final List<DateTime> _requestTimes = [];

  RateLimiter({
    required this.maxRequests,
    required this.window,
  });

  /// Verifica se pode fazer a requisição
  bool canMakeRequest() {
    final now = DateTime.now();
    final cutoffTime = now.subtract(window);

    // Remove requisições fora da janela
    _requestTimes.removeWhere((time) => time.isBefore(cutoffTime));

    // Se não atingiu o limite, permite
    if (_requestTimes.length < maxRequests) {
      _requestTimes.add(now);
      return true;
    }

    return false;
  }

  /// Obtém o tempo de espera até a próxima requisição (0 se pode fazer já)
  Duration getWaitTime() {
    if (_requestTimes.length < maxRequests) {
      return Duration.zero;
    }

    if (_requestTimes.isEmpty) {
      return Duration.zero;
    }

    final oldest = _requestTimes.first;
    final cutoffTime = oldest.add(window);
    final now = DateTime.now();

    if (now.isAfter(cutoffTime)) {
      return Duration.zero;
    }

    return cutoffTime.difference(now);
  }

  /// Reseta o rate limiter
  void reset() {
    _requestTimes.clear();
  }

  /// Obtém o número de requisições feitas na janela atual
  int get requestCount => _requestTimes.length;
}
