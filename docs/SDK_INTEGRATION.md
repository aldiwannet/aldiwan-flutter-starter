# SDK integration

`PoetryRepository` keeps UI code independent from transport details. The included `ApiPoetryRepository` is a thin domain adapter over the official `aldiwan` package. `AldiwanClient` owns Bearer authentication, transport, retries, JSON decoding, and API models; the adapter only maps those models into UI-facing domain objects.

1. Receive an initialized `AldiwanClient` (dependency injection).
2. Map SDK DTOs into the small domain models in `lib/src/domain/models.dart`.
3. Translate network/auth/rate-limit failures into localized app failures.
4. Support cancellation and pagination when the SDK exposes them.
5. Never log access tokens, full request headers, or sensitive responses.

The implemented pattern is:

```dart
class ApiPoetryRepository implements PoetryRepository {
  ApiPoetryRepository(this.client);
  final AldiwanClient client;

  @override
  Future<List<Poem>> explore(ExploreQuery query) async {
    final response = await client.poems.list(
      filters: PoemFilters(style: query.style),
    );
    return response.items.map(mapPoem).toList(growable: false);
  }
}
```

For mobile/web, route authenticated requests through a backend-for-frontend. Do not ship a privileged API key in the client.
