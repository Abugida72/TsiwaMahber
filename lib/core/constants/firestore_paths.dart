class FirestorePaths {
  FirestorePaths._();

  static String areas() => 'areas';

  static String area(String areaId) => 'areas/$areaId';

  static String tsiwaMahbers(String areaId) =>
      'areas/$areaId/tsiwaMahbers';

  static String tsiwaMahber(String areaId, String tsiwaId) =>
      'areas/$areaId/tsiwaMahbers/$tsiwaId';
}
