FROM ubuntu:18.04 as build
#from alpine:latest

ENV INFLUXDB_DB="speedtest" \
    INFLUXDB_URL="http://influxdb:8086" \
    SPEEDTEST_HOST="local" \
    SPEEDTEST_INTERVAL=3600 \
    LINE_TYPE="auto"

WORKDIR /app

RUN apt-get update \
    && apt-get install build-essential libcurl4-openssl-dev libxml2-dev libssl-dev cmake git jq curl -y \
    && rm -rf /var/lib/apt/lists/* 
RUN git clone https://github.com/JMacalinao/speedtestplusplus \
    && cd speedtestplusplus \
    && cmake -DCMAKE_BUILD_TYPE=Release . \
    && make install

COPY run.sh .

CMD ["./run.sh"]
    
