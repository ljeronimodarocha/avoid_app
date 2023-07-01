abstract class HttpClient {
  Future<Map<dynamic, dynamic>?> request(
      {required String url, required String method, Map? body});
}
