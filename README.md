collectd-json-influxdb-proxy
============================

Translate collectd JSON HTTP request to Influx Data line protocol


Requirements:

* Perl >= 5.14
* Mojolicious (apt install libmojolicious-perl)


Configuration for collectd:

```
<Plugin "write_http">
    <Node "collectd-json-influxdb-proxy">
       URL "http://localhost:5826/"
       Format "JSON"
       BufferSize 129024
       Timeout 5000
    </Node>
</Plugin>
```


Start:

```sh
perl collectd_json_influxdb_proxy.pl daemon -m production -l http://*:5826
```
