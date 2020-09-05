#!/bin/bash
"${SPARK_HOME}/sbin/start-master.sh" --host 0.0.0.0 --port 7077 --webui-port 8088 && \
"${SPARK_HOME}/sbin/start-slave.sh" spark://127.0.0.1:7077 --host 0.0.0.0
jupyter lab --ip=0.0.0.0 --no-browser