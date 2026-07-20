# BaseBloc Pattern & Lifecycle Contract

## What this skill covers
The custom BLoC pattern used in `chat_matthew`. This is NOT `flutter_bloc` -- it is a thin rxdart wrapper defined in `lib/common/base_bloc.dart`. Use this reference for every bloc and screen modification.

## BaseBloc: How it works

```dart
// lib/common/base_bloc.dart (thin rxdart wrapper)
abstract class BaseBloc {
  BuildContext? context;          // WARNING: stores BuildContext in bloc (anti-pattern)

  // Guarded setter -- emits to BehaviorSubject only if not closed
  void set<T>(BehaviorSubject<T> subject, T value) {
    if (!subject.isClosed) subject.add(value);
  }

  void dispose();  // subclasses MUST override and close all BehaviorSubjects
}
```

## Bloc Declaration Pattern

```dart
class MyBloc extends BaseBloc {
  final BehaviorSubject<MyModel> _data = BehaviorSubject<MyModel>();
  final BehaviorSubject<bool> _loading = BehaviorSubject<bool>.seeded(false);

  // Expose as streams
  Stream<MyModel> get outputData => _data.stream;
  Stream<bool> get outputLoading => _loading.stream;

  // API call
  Future<void> fetchData() async {
    set(_loading, true);
    try {
      final result = await ChatConnection.someApiMethod();
      set(_data, result);
    } catch (e) {
      // NEVER swallow silently -- at minimum rethrow or set an error stream
    } finally {
      set(_loading, false);
    }
  }

  @override
  void dispose() {
    _data.close();      // MUST close every BehaviorSubject
    _loading.close();   // MUST close every BehaviorSubject
  }
}
```

## Screen Lifecycle Contract

```dart
class _MyScreenState extends State<MyScreen> {
  late MyBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = MyBloc();
    _bloc.context = context;  // set context if bloc needs it for dialogs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Defer API calls until after first frame (pattern used everywhere)
      _bloc.fetchData();
    });
  }

  @override
  void dispose() {
    _bloc.dispose();  // MANDATORY -- prevents BehaviorSubject stream leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MyModel>(
      stream: _bloc.outputData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        return Text(snapshot.data!.name);
      },
    );
  }
}
```

## The Dispose Contract (Enforced by check_bloc_lifecycle.sh hook)

1. Every `BehaviorSubject<T>` field declared in a bloc MUST appear in `dispose()` as `fieldName.close()`.
2. Every `State` class that assigns a bloc in `initState` MUST call `_bloc.dispose()` in its own `dispose()`.
3. The `set(subject, value)` helper already guards against closed-subject errors -- always use `set()` instead of `subject.add()` directly.

## Known Leak: ConversationBloc

`lib/presentation/conversation_modules/src/bloc/conversation_bloc.dart`:
- `_session` is closed in `dispose()` ✓
- `notes` (BehaviorSubject<NotesResponseModel>) -- NOT closed ✗
- `_summary` (BehaviorSubject<ConversationSummaryModel>) -- NOT closed ✗

`lib/presentation/conversation_modules/src/ui/conversation_information_screen.dart`:
- Has a `void dispose()` method but does NOT call `_bloc.dispose()` ✗

Fix: add `notes.close(); _summary.close();` to ConversationBloc.dispose(), and add `_bloc.dispose();` to ConversationInformationScreen.dispose().

## Mixing setState() and StreamBuilder

The codebase mixes `setState()` (20+ calls in `chat_screen.dart`) with `StreamBuilder` on BehaviorSubjects. The rule:
- Use `StreamBuilder` for any state that comes from async data (API, socket)
- Use `setState()` only for purely local UI state (e.g., keyboard visibility, animation flags)
- Do NOT duplicate state: if a value is in a BehaviorSubject, do not also hold it in a local variable updated with `setState()`

## Folder Structure (Ongoing Migration)

| Folder | Status | Pattern |
|---|---|---|
| `lib/chat_screen/` | Older -- calls `ChatConnection` directly from UI | Direct coupling, no bloc |
| `lib/presentation/` | Newer -- BLoC separated from UI | Correct pattern |

When adding screens: always use `lib/presentation/` and the BaseBloc pattern. Never call `ChatConnection` methods directly from a Widget's `build()` or event handler.

## Localization in Blocs

Blocs must NOT call `AppLocalizations.text(LangKey.xxx)` directly -- they don't own a BuildContext reliably. Pass localized strings from the screen into the bloc method, or emit a raw key and let the screen resolve it.

Exception: `_bloc.context` is set by screens and used for showing dialogs -- only acceptable for dialog-presenting methods, not for string resolution.
