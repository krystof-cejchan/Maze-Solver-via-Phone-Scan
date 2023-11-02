enum PxResult {
  foundWall(false),
  notYetWall(true),
  foundCrossroad(false),
  foundRoute(true),
  err(false),
  foundMismatch(false);

  final bool carryOnLooping;
  const PxResult(this.carryOnLooping);
}
