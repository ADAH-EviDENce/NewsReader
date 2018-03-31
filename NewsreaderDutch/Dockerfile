# This Dockerfile is based on the newsreader-docker from vanatteveldt
# https://github.com/vanatteveldt/newsreader-docker

FROM rugcompling/alpino:latest
MAINTAINER Martine de Vos (mgdevos@gmail.com)
EXPOSE 5002

# Ubuntu dependencies
RUN apt-get -qq update && apt-get install -y \
    wget \ 
    git \
    maven \
    openjdk-8-jdk \
    python-flask \
    python-lxml \
    python-pip \
    timbl

# Python dependencies
RUN pip install KafNafParserPy

# Install and compile tokenizer; use specific version (not necessarily latest)
RUN git clone https://github.com/ixa-ehu/ixa-pipe-tok \
    && cd ixa-pipe-tok \
    && git checkout 739ff20 \
    && mvn -Dmaven.compiler.target=1.8 -Dmaven.compiler.source=1.8 clean package

# Install morphosyntactic parser
RUN git clone https://github.com/cltl/morphosyntactic_parser_nl \
    && cd morphosyntactic_parser_nl \
    && git checkout 6f789bd \
    && python setup.py install

# Download ixa-pipes package to get matching ixa-pipe-nerc jar and model versions
RUN wget http://ixa2.si.ehu.es/ixa-pipes/models/ixa-pipes-1.1.1.tar.gz \
    && mkdir ixa-pipe-nerc \
    && tar -zxvf ixa-pipes-1.1.1.tar.gz ixa-pipes-1.1.1/ixa-pipe-nerc-1.6.1-exec.jar \
    && tar -xzvf ixa-pipes-1.1.1.tar.gz ixa-pipes-1.1.1/nerc-models-1.6.1/nl/nl-6-class-clusters-sonar.bin \
    && mv ixa-pipes-1.1.1/ixa-pipe-nerc-1.6.1-exec.jar ixa-pipe-nerc/ \
    && mv ixa-pipes-1.1.1/nerc-models-1.6.1/nl/nl-6-class-clusters-sonar.bin ixa-pipe-nerc/ \
    && rm ixa-pipes-1.1.1.tar.gz \
    && rm -Rf ixa-pipes-1.1.1

# Download dbpedia-spotlight servers
RUN wget http://downloads.dbpedia-spotlight.org/spotlight/dbpedia-spotlight-0.7.1.jar \
    && wget http://downloads.dbpedia-spotlight.org/2016-10/nl/model/nl.tar.gz 

RUN mkdir central-dependencies \
    && cd central-dependencies \ 
    && mkdir dbpedia-spotlight \
    && cd dbpedia-spotlight \
    && mv ../../dbpedia-spotlight-0.7.1.jar . \
    && tar -xzvf ../../nl.tar.gz -C . \
    && mvn install:install-file -Dfile=dbpedia-spotlight-0.7.jar -DgroupId=ixa -DartifactId=dbpedia-spotlight -Dversion=0.7 -Dpackaging=jar -DgeneratePom=true \
    && cd ../.. \
    && rm nl.tar.gz 

# Download and install ixa-pipe-ned
RUN git clone https://github.com/ixa-ehu/ixa-pipe-ned \
    && cd ixa-pipe-ned \
    && git checkout 062a983 \
    && mvn -Dmaven.compiler.target=1.8 -Dmaven.compiler.source=1.8 clean package
