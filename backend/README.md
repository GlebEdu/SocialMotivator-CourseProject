# Backend

Серверная часть HabitBet реализована на **FastAPI** и предоставляет REST API для мобильного клиента.

## Что делает backend

Backend отвечает за:

- регистрацию, вход и выдачу JWT-токенов;
- хранение пользователей, их баланса и рейтинга;
- создание и чтение целей;
- размещение ставок;
- загрузку и хранение доказательств;
- создание арбитражных кейсов;
- голосование арбитров и финальное разрешение цели.

## Стек

- Python
- FastAPI
- SQLAlchemy
- Alembic
- PostgreSQL
- Pydantic Settings
- `python-jose` для JWT
- `passlib` и `bcrypt` для хеширования паролей

## Структура

```text
backend/
├── app/
│   ├── api/        # роуты и зависимости FastAPI
│   ├── core/       # конфигурация и security
│   ├── db/         # база и сессии
│   ├── models/     # SQLAlchemy-модели
│   ├── schemas/    # Pydantic DTO и входные модели
│   └── services/   # бизнес-логика
├── alembic/        # миграции БД
├── media/          # локальное хранилище файлов доказательств
├── requirements.txt
└── alembic.ini
```

## Локальный запуск

### 1. Подготовить окружение

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 2. Создать `.env`

В папке `backend` уже есть шаблон `.env.example`, поэтому можно просто скопировать его:

```bash
cp .env.example .env
```

### 3. Применить миграции

```bash
alembic upgrade head
```

### 4. Запустить сервер

```bash
uvicorn app.main:app --reload
```

После запуска:

- API: `http://127.0.0.1:8000/api/v1`
- Swagger UI: `http://127.0.0.1:8000/docs`
- Healthcheck: `http://127.0.0.1:8000/api/v1/health`

## Основные роуты

### Auth

- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `GET /api/v1/auth/me`
- `POST /api/v1/auth/logout`

### Profile / Users

- `GET /api/v1/profile/me`
- `GET /api/v1/users/me/bets`
- `GET /api/v1/users/{user_id}/profile-summary`

### Goals

- `POST /api/v1/goals`
- `GET /api/v1/goals/mine`
- `GET /api/v1/goals/discover`
- `GET /api/v1/goals/{goal_id}`
- `POST /api/v1/goals/{goal_id}/bets`
- `POST /api/v1/goals/{goal_id}/evidence`

### Evidence uploads

- `POST /api/v1/evidence/uploads`
- `PUT /api/v1/evidence/uploads/{upload_id}/content`

### Arbitration

- `GET /api/v1/arbitration/cases`
- `GET /api/v1/arbitration/cases/{case_id}`
- `POST /api/v1/arbitration/cases/{case_id}/votes`

## Бизнес-правила

- При создании цели пользователь автоматически делает обязательную ставку на себя размером `10.00`.
- Новая цель сразу получает статус `active`.
- Ставки разрешены только для активных целей.
- Доказательства может загружать только автор цели.
- После отправки доказательств цель переходит в статус `inReview`.
- Для арбитража назначаются 3 активных пользователя, которые не являются автором цели и не участвовали в ставках по ней.
- Решение принимается большинством: порог подтверждения или отклонения - `2` голоса.
- После верификации цели арбитрами обновляется рейтинг: автор получает `+15` за статус `completed` и `-10` за статус `failed`, выигравшие по ставкам получают `+5`, проигравшие - `-3`; рейтинг не опускается ниже `0`.

## Хранение файлов доказательств

Backend хранит данные локально в директории `media/`:

- `media/evidence/` - сами загруженные файлы;
- `media/evidence_uploads/` - JSON-метаданные upload слотов.


## Миграции

Полезные команды:

```bash
alembic upgrade head
alembic downgrade -1
alembic revision --autogenerate -m "describe change"
```

## Заметки по разработке

- Конфигурация читается из `.env` через `pydantic-settings`.
- Точка входа приложения: `app/main.py`.
- Все основные сценарии вынесены в `app/services/`.
- Роуты сгруппированы по доменным зонам в `app/api/routes/`.
