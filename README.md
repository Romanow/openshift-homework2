# Домашнее задание #2: Monitoring

## Формулировка

1. Grafana + Prometheus:
    1. создать Dashboard с графиком суммарного потребления памяти java приложениями (Heap + Metaspace);
    2. настроить Alerting в Telegram / Slack если потребление памяти больше некоторого порога (выбираете сами по
       графику).
2. ELK Stack:
    1. в Kibana построить график количества сообщений в логах за минуту в разрезе Log Level (debug, info, warn, error);
    2. в Kibana построить график количества уникальных запросов за минуту (уникальные TraceId).

## Пояснения

Для запуска кластера будем использовать Helm:

```shell
$ cd helm/
$ export NAME_SUFFIX=<your-name>

# Grafana & Prometheus
$ helm install monitoring monitoring-chart --set grafana.nameSuffix=$NAME_SUFFIX

# ElasticSearch & Logstash & Kibana
$ helm install logging logging-chart --set kibana.nameSuffix=$NAME_SUFFIX

# Postgres & Services
$ helm install services services-chart \
    --set store.nameSuffix=$NAME_SUFFIX \
    --set order.nameSuffix=$NAME_SUFFIX \
    --set warehouse.nameSuffix=$NAME_SUFFIX \
    --set warranty.nameSuffix=$NAME_SUFFIX

# проверить что все сервисы запущены
$ oc get pods
NAME                                           READY   STATUS    RESTARTS   AGE
elasticsearch-58bfdcf6ff-xh27r                 1/1     Running   0          67m
grafana-55bd99f8db-p7wdl                       1/1     Running   0          23m
kibana-68459f9f86-hrdxv                        1/1     Running   0          67m
logstash-77c4df78d8-hh9l5                      1/1     Running   0          67m
order-deployment-86f497fcf4-jsb4n              3/3     Running   0          6m19s
postgres-order-deployment-5c5c8894d7-hrcnz     1/1     Running   0          6m19s
postgres-store-deployment-c67d56bc6-wj55c      1/1     Running   0          6m19s
postgres-warehouse-deployment-dddc4c86-fkc87   1/1     Running   0          6m19s
postgres-warranty-deployment-f5757b75c-9pm2c   1/1     Running   0          6m19s
prometheus-dc7cc886c-wbxrp                     1/1     Running   0          23m
store-deployment-68b4d874c-5hwmv               3/3     Running   0          6m19s
warehouse-deployment-64579b8869-4s9mw          3/3     Running   0          6m19s
warranty-deployment-7cd8d95874-nvlk4           3/3     Running   0          6m19s

# (optional) для запуска потребуется newman, его нужно установить
# https://support.postman.com/hc/en-us/articles/115003703325-How-to-install-Newman
$ npm install -g newman

# заменить name-suffix в файле postman/environment.json
$ cd ../scripts/
$ ./make-requests.sh
Services

❏ Store service
↳ [store] Health Check
  GET http://store-romanow.apps.edu.inno.tech/manage/health [200 OK, 355B, 95ms]
  ✓  Health check

↳ [store] Purchase item
  POST http://store-romanow.apps.edu.inno.tech/api/v1/store/6D2CB5A0-943C-4B96-9AA6-89EAC7BDFD2B/purchase [201 Created, 316B, 115ms]
  ✓  Purchase item

↳ [store] User order info
  GET http://store-romanow.apps.edu.inno.tech/api/v1/store/6D2CB5A0-943C-4B96-9AA6-89EAC7BDFD2B/161bb6b0-d425-4505-9e76-5cc1c4d06593 [200 OK, 398B, 98ms]
  ✓  User order info

↳ [store] User orders
  GET http://store-romanow.apps.edu.inno.tech/api/v1/store/6D2CB5A0-943C-4B96-9AA6-89EAC7BDFD2B/orders [200 OK, 594B, 94ms]
  ✓  User orders

↳ [store] Warranty request
  POST http://store-romanow.apps.edu.inno.tech/api/v1/store/6D2CB5A0-943C-4B96-9AA6-89EAC7BDFD2B/161bb6b0-d425-4505-9e76-5cc1c4d06593/warranty [200 OK, 320B, 766ms]
  ✓  Warranty request

↳ [store] Return order
  DELETE http://store-romanow.apps.edu.inno.tech/api/v1/store/6D2CB5A0-943C-4B96-9AA6-89EAC7BDFD2B/161bb6b0-d425-4505-9e76-5cc1c4d06593/refund [204 No Content, 153B, 125ms]
  ✓  Return order

┌─────────────────────────┬────────────────────┬────────────────────┐
│                         │           executed │             failed │
├─────────────────────────┼────────────────────┼────────────────────┤
│              iterations │                  1 │                  0 │
├─────────────────────────┼────────────────────┼────────────────────┤
│                requests │                  6 │                  0 │
├─────────────────────────┼────────────────────┼────────────────────┤
│            test-scripts │                  6 │                  0 │
├─────────────────────────┼────────────────────┼────────────────────┤
│      prerequest-scripts │                  5 │                  0 │
├─────────────────────────┼────────────────────┼────────────────────┤
│              assertions │                  6 │                  0 │
├─────────────────────────┴────────────────────┴────────────────────┤
│ total run duration: 1446ms                                        │
├───────────────────────────────────────────────────────────────────┤
│ total data received: 936B (approx)                                │
├───────────────────────────────────────────────────────────────────┤
│ average response time: 215ms [min: 94ms, max: 766ms, s.d.: 246ms] │
└───────────────────────────────────────────────────────────────────┘
```

### Конфигурация Kibana

Логин и пароль: `logging`/`qwerty`.

Создание индекса для логгирования: `Management` -> `Stack Management` -> `Kibana` -> `Index Pattern` -> Create index
pattern -> Name: `logstash-*`, Timestamp field: `@timestamp`.

### Конфигурация Grafana

Логин и пароль: `admin`/`admin`.

Grafana Dashboard: 10280.

Метрики Prometheus:
```shell
curl "http://store-$NAME_SUFFIX.apps.edu.inno.tech/manage/prometheus --user management:passwd" | jq
```

## Сдача домашней работы

1. Создаете fork этого репозитория.
2. Создаете Pull Request и прикладываете screenshot полученных графиков и нотификаций.