class TourRoute {
  final String id;
  final String name;
  final List<String> destinationIds;
  final DateTime createdAt;

  const TourRoute({
    required this.id,
    required this.name,
    required this.destinationIds,
    required this.createdAt,
  });
}
