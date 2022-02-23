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

# ElasticSearch
$ helm install elasticsearch elasticsearch-chart

# Logstash & Kibana
$ helm install logging logging-chart --set kibana.nameSuffix=$NAME_SUFFIX

# Jaeger Collector & Jaeger Query
$ helm install jaeger jaeger-chart --set nameSuffix=$NAME_SUFFIX

# Postgres & Services
$ helm install services services-chart \
    --set store.nameSuffix=$NAME_SUFFIX \
    --set order.nameSuffix=$NAME_SUFFIX \
    --set warehouse.nameSuffix=$NAME_SUFFIX \
    --set warranty.nameSuffix=$NAME_SUFFIX

# проверить что все сервисы запущены
$ oc get pods

# (optional) для запуска потребуется newman, его нужно установить
# https://support.postman.com/hc/en-us/articles/115003703325-How-to-install-Newman
$ npm install -g newman

# заменить name-suffix в файле postman/environment.json
$ cd ../scripts/
$ ./make-requests.sh
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