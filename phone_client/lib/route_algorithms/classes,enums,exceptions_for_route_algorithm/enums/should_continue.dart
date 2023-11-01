enum PxResult {
  foundWall(false),
  notYetWall(true),
  foundCrossroad(false),
  foundRoute(true),
  mismatch(false),
  na(null);

  final bool? shouldContinue;
  const PxResult(this.shouldContinue);
}
