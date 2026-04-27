# Mobile

Мобильный клиент HabitBet написан на **Flutter** и работает поверх REST API из backend.

## Что есть в приложении

- экран входа;
- экран регистрации;
- вкладка моих целей;
- экран создания цели;
- лента чужих целей;
- карточка цели с деталями, ставками и статусом;
- загрузка доказательств с вложениями;
- список арбитражных кейсов;
- экран голосования арбитра;
- профиль пользователя и профиль автора цели.

## Технологии

- Flutter
- Dart
- Riverpod
- GoRouter
- Freezed
- Json Serializable
- HTTP
- Shared Preferences
- Image Picker
- Video Player
- Google Fonts

## Структура

```text
mobile/
├── lib/
│   ├── app/        # приложение, тема, роутинг
│   ├── features/   # auth, goals, bets, arbitration, profile
│   └── shared/     # API-клиент, общие провайдеры
├── android/
├── ios/
├── macos/
├── linux/
├── windows/
├── web/
└── pubspec.yaml
```

## Запуск

### 1. Установить зависимости

```bash
cd mobile
flutter pub get
```

### 2. Запустить приложение

```bash
flutter run
```

## Подключение к backend

По умолчанию `ApiClient` использует такие адреса:

- Android emulator: `http://10.0.2.2:8000/api/v1`
- iOS: `http://127.0.0.1:8000/api/v1`

При необходимости URL можно переопределить через `dart-define`:

```bash
flutter run --dart-define=HABITBET_API_BASE_URL=http://127.0.0.1:8000/api/v1
```


## Архитектура клиента

Код организован по feature-first структуре:

- `features/auth` - вход и регистрация;
- `features/goals` - цели, детали, создание и доказательства;
- `features/bets` - размещение ставок;
- `features/arbitration` - список кейсов и голосование;
- `features/profile` - профиль текущего пользователя и автора цели.

Внутри feature используются слои:

- `data` - модели и API-репозитории;
- `domain` - сущности, интерфейсы и сервисы;
- `presentation` - экраны, виджеты и провайдеры.

## Навигация

В приложении настроен `GoRouter` со следующими основными маршрутами:

- `/login`
- `/register`
- `/my-goals`
- `/discover`
- `/arbitration`
- `/profile`
- `/my-goals/create`
- `/goals/:id`
- `/goals/:id/evidence`
- `/users/:id`
- `/arbitration/:id`


## Генерация кода

В проекте используются `freezed` и `json_serializable`, поэтому после изменения моделей нужно перегенерировать файлы:

```bash
dart run build_runner build --delete-conflicting-outputs
```
