![img](https://cdn-ak.f.st-hatena.com/images/fotolife/k/kenzo0107/20190228/20190228163439.png)

## Setup

```
docker-compose up
```

## To follow log files of databases, open other window and execute the bellow commands:

* logging db-primary
```bash
docker-compose exec db-primary sh -c 'tail -f /var/log/mysql/*.log'
```

* logging db-secondary
```bash
docker-compose exec db-secondary sh -c 'tail -f /var/log/mysql/*.log'
```

## execute "SELECT" query through ProxySQL.

```bash
$ mysql -h 127.0.0.1 -u proxysql -p -P 6033 hoge -e"SELECT * FROM users;"
Enter password:

+----+-----------------------+
| id | name                  |
+----+-----------------------+
|  1 | kenzo0107             |
|  2 | 有酸素運動マン        |
+----+-----------------------+
```

* db-secondary logs:
```bash
2019-02-28T01:59:39.848947Z         6 Query     select * from users
```

## executep "INSERT" query through ProxySQL

```bash
$ mysql -h 127.0.0.1 -u proxysql -p -P 6033 hoge -e"INSERT INTO users VALUES (3, 'なかやまきんに君');"
```

* db-primary logs:
```bash
2019-02-28T02:00:22.770045Z        15 Query     INSERT INTO users VALUES (3, 'なかやまきんに君')
```

## connect to ProxySQL

```
$ mysql -h 127.0.0.1 -u proxysql -p -P 6032 --prompt='ProxySQL> '
Enter password: (default: pass)
```

* Tables

```
ProxySQL> show tables;
+--------------------------------------------+
| tables                                     |
+--------------------------------------------+
| global_variables                           |
| mysql_collations                           |
| mysql_group_replication_hostgroups         |
| mysql_query_rules                          |
| mysql_query_rules_fast_routing             |
| mysql_replication_hostgroups               |
| mysql_servers                              |
| mysql_users                                |
| proxysql_servers                           |
| runtime_checksums_values                   |
| runtime_global_variables                   |
| runtime_mysql_group_replication_hostgroups |
| runtime_mysql_query_rules                  |
| runtime_mysql_query_rules_fast_routing     |
| runtime_mysql_replication_hostgroups       |
| runtime_mysql_servers                      |
| runtime_mysql_users                        |
| runtime_proxysql_servers                   |
| runtime_scheduler                          |
| scheduler                                  |
+--------------------------------------------+
20 rows in set (0.00 sec)
```

* mysql_servers

```
ProxySQL> SELECT * FROM mysql_servers;
+--------------+--------------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
| hostgroup_id | hostname     | port | status | weight | compression | max_connections | max_replication_lag | use_ssl | max_latency_ms | comment |
+--------------+--------------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
| 0            | db-primary   | 3306 | ONLINE | 1      | 0           | 1000            | 5                   | 0       | 0              |         |
| 1            | db-secondary | 3306 | ONLINE | 1      | 0           | 1000            | 5                   | 0       | 0              |         |
+--------------+--------------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
2 rows in set (0.00 sec)
```


* monitroing backend databases connection.

```
ProxySQL> SELECT * FROM monitor.mysql_server_connect_log ORDER BY time_start_us DESC LIMIT 10;
+--------------+------+------------------+-------------------------+---------------+
| hostname     | port | time_start_us    | connect_success_time_us | connect_error |
+--------------+------+------------------+-------------------------+---------------+
| db-secondary | 3306 | 1551160996705311 | 5530                    | NULL          |
| db-primary   | 3306 | 1551160996685018 | 2937                    | NULL          |
| db-primary   | 3306 | 1551160796938518 | 3350                    | NULL          |
| db-secondary | 3306 | 1551160796927358 | 4774                    | NULL          |
| db-secondary | 3306 | 1551160597155957 | 2985                    | NULL          |
| db-primary   | 3306 | 1551160597138091 | 4829                    | NULL          |
| db-primary   | 3306 | 1551160397395270 | 5515                    | NULL          |
| db-secondary | 3306 | 1551160397375977 | 6619                    | NULL          |
| db-secondary | 3306 | 1551160197634361 | 3601                    | NULL          |
| db-primary   | 3306 | 1551160197615986 | 7808                    | NULL          |
+--------------+------+------------------+-------------------------+---------------+
10 rows in set (0.00 sec)
```

* mysql_replication_hostgroups

```
ProxySQL> SELECT * FROM mysql_replication_hostgroups;
+------------------+------------------+-------------+
| writer_hostgroup | reader_hostgroup | comment     |
+------------------+------------------+-------------+
| 0                | 1                | host groups |
+------------------+------------------+-------------+
1 row in set (0.00 sec)
```

## Reference

https://proxysql.com/

https://github.com/sysown/proxysql/wiki/Global-variables
