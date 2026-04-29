class FirestorePaths {
  FirestorePaths._();

  static String areas() => 'areas';

  static String area(String areaId) => 'areas/$areaId';

  static String tsiwaMahbers(String areaId) =>
      'areas/$areaId/tsiwaMahbers';

  static String tsiwaMahber(String areaId, String tsiwaId) =>
      'areas/$areaId/tsiwaMahbers/$tsiwaId';

  static String members(String areaId, String tsiwaId) =>
      'areas/$areaId/tsiwaMahbers/$tsiwaId/members';

  static String member(String areaId, String tsiwaId, String memberId) =>
      'areas/$areaId/tsiwaMahbers/$tsiwaId/members/$memberId';

  static String events(String areaId, String tsiwaId) =>
      'areas/$areaId/tsiwaMahbers/$tsiwaId/events';

  static String event(String areaId, String tsiwaId, String eventId) =>
      'areas/$areaId/tsiwaMahbers/$tsiwaId/events/$eventId';

  static String leaders(String areaId) => 'areas/$areaId/leaders';

  static String leader(String areaId, String leaderId) =>
      'areas/$areaId/leaders/$leaderId';

  static String edirs(String areaId) => 'areas/$areaId/edirs';

  static String edir(String areaId, String edirId) =>
      'areas/$areaId/edirs/$edirId';

  static String edirMembers(String areaId, String edirId) =>
      'areas/$areaId/edirs/$edirId/members';

  static String edirMember(String areaId, String edirId, String memberId) =>
      'areas/$areaId/edirs/$edirId/members/$memberId';

  static String edirPayments(String areaId, String edirId) =>
      'areas/$areaId/edirs/$edirId/payments';

  static String announcements(String areaId) =>
      'areas/$areaId/announcements';

  static String announcement(String areaId, String announcementId) =>
      'areas/$areaId/announcements/$announcementId';

  static String readReceipts(String areaId, String announcementId) =>
      'areas/$areaId/announcements/$announcementId/readReceipts';

  static String readReceipt(
          String areaId, String announcementId, String userId) =>
      'areas/$areaId/announcements/$announcementId/readReceipts/$userId';
}
