enum PxResult {
  foundWall(false),
  notYetWall(true),
  foundCrossroad(false),
  foundRoute(true),
  na(null);

  final bool? shouldContinue;
  const PxResult(this.shouldContinue);
}
