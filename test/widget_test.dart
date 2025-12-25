import 'dart:io';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remind_me/blocs/event/event_bloc.dart';
import 'package:remind_me/core/app.dart';
import 'package:remind_me/core/di.dart';
import 'package:remind_me/models/category.dart';
import 'package:remind_me/models/event.dart';
import 'package:remind_me/repositories/event_repository.dart';
import 'package:remind_me/services/reminder_service.dart';
import 'package:remind_me/views/pages/date/date_page.dart';

class FakeEventRepository implements EventRepository {
  final List<Event> _events = [];
  final List<Category> _categories = [];

  @override
  Future<List<Event>> getAllEvents() async => List<Event>.from(_events);

  @override
  Future<void> saveEvent(Event event) async {
    _events.add(event);
  }

  @override
  Future<void> updateEvent(Event event) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
  }

  @override
  Future<void> pinEvent(String id) async {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      _events[index] = _events[index].copyWith(
        isPinned: true,
        pinnedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> unpinEvent(String id) async {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      _events[index] = _events[index].copyWith(
        isPinned: false,
        pinnedAt: null,
      );
    }
  }

  @override
  Future<void> reorderEvents(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _events.length) return;
    if (newIndex < 0 || newIndex >= _events.length) return;
    final event = _events.removeAt(oldIndex);
    _events.insert(newIndex, event);
  }

  @override
  Future<void> updateEvents(List<Event> events) async {
    for (final event in events) {
      await updateEvent(event);
    }
  }

  @override
  Future<List<Category>> getCategories() async => List<Category>.from(_categories);

  @override
  Future<void> addCategory(Category category) async {
    _categories.add(category);
  }

  @override
  Future<void> updateCategory(Category category, {String? oldName}) async {
    final index = _categories.indexWhere((c) => c.name == oldName);
    if (index != -1) {
      _categories[index] = category;
    }
  }

  @override
  Future<void> deleteCategory(String name) async {
    _categories.removeWhere((c) => c.name == name);
  }
}

class FakeReminderService implements ReminderService {
  @override
  Future<void> init() async {}

  @override
  Future<void> setReminder(Event event) async {}

  @override
  Future<void> updateReminder(Event event) async {}

  @override
  Future<void> cancelReminder(String eventId) async {}

  @override
  Future<void> cancelAllReminders() async {}

  @override
  Future<void> resetAllReminders(List<Event> events) async {}

  @override
  Future<void> testNotification({bool isDelayed = false}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp('hydrated_bloc_test');
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(tempDir.path),
    );

    await getIt.reset();
    final repository = FakeEventRepository();
    final reminderService = FakeReminderService();
    getIt.registerFactory<EventBloc>(() => EventBloc(
      repository: repository,
      reminderService: reminderService,
    ));
  });

  testWidgets('App should render HomePage with DatePage initially', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const RemindMeApp());

    // Verify that DatePage is shown initially (index 0 in bottom nav)
    expect(find.byType(DatePage), findsOneWidget);
  });
}
