abstract final class AppRouteNames {
  static const root = 'root';
  static const splash = 'splash';
  static const opening = 'opening';
  static const error = 'error';

  static const home = 'home';
  static const homeMemory = 'homeMemory';
  static const homeLetter = 'homeLetter';
  static const homeRecap = 'homeRecap';

  static const timeline = 'timeline';
  static const timelineMemory = 'timelineMemory';
  static const timelineAddMemory = 'timelineAddMemory';
  static const timelineEditMemory = 'timelineEditMemory';
  static const timelineAddMemoryLocation = 'timelineAddMemoryLocation';
  static const timelineEditMemoryLocation = 'timelineEditMemoryLocation';

  static const map = 'map';
  static const mapMemory = 'mapMemory';

  static const letters = 'letters';
  static const letterDetail = 'letterDetail';
}

abstract final class AppRoutePaths {
  static const root = '/';
  static const splash = '/splash';
  static const opening = '/opening';
  static const error = '/error';

  static const home = '/home';
  static const timeline = '/timeline';
  static const map = '/map';
  static const letters = '/letters';

  static const memoryDetailSegment = 'memories/:memoryId';
  static const addMemorySegment = 'new-memory';
  static const editMemorySegment = 'edit-memory/:memoryId';
  static const locationSegment = 'location';
  static const letterDetailSegment = 'letters/:letterId';
  static const branchLetterDetailSegment = ':letterId';
  static const recapSegment = 'recap';
}

abstract final class AppRouteParams {
  static const memoryId = 'memoryId';
  static const letterId = 'letterId';
}
