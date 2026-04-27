# HabitBet

**HabitBet** - социальное приложение для достижения целей через публичные обязательства, ставки и арбитраж.

Пользователь создаёт цель, автоматически подтверждая серьезность намерения ставкой на себя. Другие участники могут делать прогнозы "за" или "против". После выполнения автор загружает доказательства, а итоговая развязка проходит через арбитраж назначенных пользователей. Результат влияет на баланс и рейтинг участников.

## Что реализовано в проекте

- регистрация и вход по JWT;
- профиль пользователя с балансом и рейтингом;
- создание целей;
- обязательная автоставка автора при создании цели;
- лента собственных и чужих целей;
- ручные ставки за и против цели;
- загрузка доказательств с файлами;
- арбитражные кейсы и голосование арбитров;
- мобильный клиент на Flutter;
- REST API на FastAPI.

## Структура репозитория

```text
habitbet/
├── backend/   # FastAPI + SQLAlchemy + Alembic + PostgreSQL
├── mobile/    # Flutter-клиент
└── README.md
```

Подробности по каждой части:

- [backend/README.md](backend/README.md)
- [mobile/README.md](mobile/README.md)

## Технологии

### Backend

- Python
- FastAPI
- SQLAlchemy
- Alembic
- PostgreSQL
- Pydantic Settings
- JWT (`python-jose`)

### Mobile

- Flutter
- Dart
- Riverpod
- GoRouter
- Freezed / Json Serializable
- HTTP
- Shared Preferences
- Image Picker
- Video Player

## Как устроен пользовательский сценарий

1. Пользователь регистрируется и получает стартовый баланс и рейтинг.
2. Создаёт цель с названием, описанием и дедлайном.
3. Backend автоматически списывает обязательную автоставку автора `10.00` "за выполнение цели".
4. Другие пользователи находят цель в разделе `"Обзор"` и делают прогнозы.
5. После выполнения автор загружает доказательства.
6. Система создает арбитражный кейс и назначает арбитров, которые не участвовали в ставках по этой цели.
7. Цель подтверждается или отклоняется по большинству голосов.

## Быстрый старт

### 1. Backend

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
alembic upgrade head
uvicorn app.main:app --reload
```

По умолчанию API будет доступно по адресу `http://127.0.0.1:8000`, а Swagger UI - по адресу `http://127.0.0.1:8000/docs`.

### 2. Mobile

```bash
cd mobile
flutter pub get
flutter run
```

По умолчанию клиент ожидает API по адресу:

- `http://10.0.2.2:8000/api/v1` для Android-эмулятора;
- `http://127.0.0.1:8000/api/v1` для iOS.

Адрес backend можно переопределить:

```bash
flutter run --dart-define=HABITBET_API_BASE_URL=http://127.0.0.1:8000/api/v1
```

## Локальная разработка

Для полноценного запуска нужны:

- PostgreSQL;
- примененные Alembic-миграции;
- запущенный backend;
- Flutter SDK.

Если вы меняете модели Flutter с `freezed` и `json_serializable`, перегенерируйте код:

```bash
cd mobile
dart run build_runner build --delete-conflicting-outputs
```
