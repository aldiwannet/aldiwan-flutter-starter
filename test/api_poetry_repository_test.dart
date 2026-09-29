import 'dart:convert';

import 'package:aldiwan/aldiwan.dart' as sdk;
import 'package:aldiwan_flutter_starter/src/data/api_poetry_repository.dart';
import 'package:aldiwan_flutter_starter/src/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('uses official v1 path and bearer authentication', () async {
    late http.Request request;
    final client = MockClient((incoming) async {
      request = incoming;
      return http.Response.bytes(
        utf8.encode(
          '{"data":[{"id":1,"title":"عنوان","slug":"poem",'
          '"poet":{"id":2,"name":"شاعر","slug":"poet"},'
          '"era":{"id":3,"name":"العصر"},"meter":"الطويل",'
          '"poem_style":"vertical","display_layout":"hemistichs",'
          '"text":"صدر|عجز","canonical_url":"https://www.aldiwan.net/poem",'
          '"attribution":{"required":true,"text":"الديوان","url":"https://www.aldiwan.net"}}]}',
        ),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final repository = ApiPoetryRepository(
      sdk.AldiwanClient(
        baseUri: Uri.parse('https://api.aldiwan.net/v1'),
        apiKey: 'test-key',
        httpClient: client,
        maxRetries: 0,
      ),
    );

    final poems = await repository.explore(
      const ExploreQuery(style: PoemStyle.vertical),
    );

    expect(request.url.path, '/v1/poems');
    expect(request.headers['Authorization'], 'Bearer test-key');
    expect(request.url.queryParameters['poem_style'], 'vertical');
    expect(poems.single.title, 'عنوان');
  });

  test('official client rejects a missing key', () {
    expect(
      () => sdk.AldiwanClient(
        baseUri: Uri.parse('https://api.aldiwan.net/v1'),
        apiKey: '',
      ),
      throwsArgumentError,
    );
  });
}
