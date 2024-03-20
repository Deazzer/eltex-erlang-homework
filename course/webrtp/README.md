# WebRtp
    Проект реализует систему обзвона абонентов, подключенных к виртуальной
АТС(Eltex Soft Switch) с возможностью передачи голосового сообщения (формата .wav), а также с хранением всей базы
абонентов в БД (на основе таблиц DETS/ETS).

###  REST API
    Реализована обработка запросов соответствующая подходу REST API (RESTful Application Programming Interface).
Эта обработка была разделена 4 модуля (Handler-а), а отправка запросов была осуществлена с помощью Postman, в роли второго абонента используется, зарегестрированный абонент в Zoiper.

*__Handlers:__*
* *abonent_h.erl* - Обработка запросов для отдельного абонента.
* *abonents_h.erl* -  Обработка запросов GET для всех абонентов.
* *call_abonent_h.erl* - Обработка GET запроса на звонок конкретному абоненту по номеру.
* *broadcast_h.erl* - Обработка GET запроса для "broadcast call" всем абонентам из базы данных.

Для удобства используются разные маршруты элементов.

*__Routes:__*
```erlang
{"/abonent/[:number]"},
{"/abonents"}, 
{"/call/abonent/[:number]"]}, 
{"/call/broadcast"}
```

*__Возможные запросы от клиента:__*
```
GET /abonent/[:number] - Возвращает Num и Name конкретного Абонента по номеру из БД.
DELETE /abonent/[:number] - Удаляет Абонента по номеру из БД.
POST /abonent - Добавляет запись об абоненте в БД используя Body из Requst`a.
GET /abonents - Возвращает список всех добавленных абонентов.
GET /call/abonent/[:number] - Производит звонок определенного абонента по номеру.
GET /call/broadcast - Совершает обзвон всех абонентов находящихся в БД по очереди и возвращает результат обзвона
```

### База Данных
    С помощью Erlang-инструмента "Mnesia" реализованы стандартные функции над БД, в роли которой выступают таблицы DETS и ETS
В модуле *__"webRtp_mnesia.erl"__* реализованы такие функции как ***чтение, запись, удаление, обновление данных***, используя "чистые операции" и транзакции. 
Для отладки предусмотрен вывод логов уровня NOTICE/WARNING в главную консоль запущенного приложения.

*__Реализованные функции:__*

* start/0 - Начало работы модуля.
* stop/0 - Остановка работы модуля.
* insert_abonent/2 - Добавление абонента в базу данных, используя в аргументах Num(номер) и Name(имя).
* delete_abonent/1 - Удаляение абонента из базы данных по Num.
* get_abonent/1, - Получение записи об абоненте из таблицы ({Num, Name}).
* get_all_abonents/0 - Получение списока абонентов добавленных в базу данных.

### Сигнализация 
    Сигнализация протокола SIP(Session Initiation Protocol) реализована с использованием прикладных 
протоколов SDP(Session Description Protocol - для обмена данными) 
и RTP(Real-time Transport Protocol для обеспечения голосовой связи)
Это реализовано в модуле *__"webRtp_nksip.erl"__* с помощью библиотеки "nksip", для обработки некоторых SIP запросов.

Реализованы следующие функции:

* start/0 - Запуск библиотеки nksip при старте приложения.
* register/1 - Регистрация абонента по номеру.
* call_abonent/1 - Звонок абоненту по номеру.

*Используемые API функции из библиотеки nksip: 

* nksip:start_link/2 - Старт SIP-server;
* nksip_uac:register/3 - Регистрация пользователя на SIP-server;
* nksip_uac:invite/3 - Отправка запроса на установление диалога другому абоненту;
* nksip_dialog:get_meta/2 - Получение мета-данных о SIP диалоге;
* nksip_uac:bye/2 - Завершение диалога  .

### Docker
    В проекте используется программное обеспечение Docker. С помощью которй у нас собран образ приложения 
с необходимыми инструкциями.

Для того, чтобы проект запустился, необходимо реализовать команду:
```erlang
docker build -t webrtp .
docker run -p 8080:8080 webrtp
```
### Ссылки на источники

* Postman: https://www.postman.com/
* Docker: https://www.docker.com/
* Erlang: https://www.erlang.org/
* Библиотека nksip: https://github.com/NetComposer/nksip/tree/master
* Zoiper: https://www.zoiper.com/

Реализовано при поддержке Академии Eltex
    https://academy.eltex-co.ru