# This Dockerfile is based on the newsreader-docker from vanatteveldt on https://github.com/vanatteveldt/newsreader-docker

FROM rugcompling/alpino:latest
MAINTAINER Martine de Vos (mgdevos@gmail.com)
EXPOSE 5002

# Get and unpack NERC models
RUN mkdir models 
    && curl http://i.amcat.nl/nerc-models-1.5.4-nl.tgz | tar xz -C models

# Install required packages
RUN apt-get -qq update && apt-get install -y \
    git \
    maven \
    openjdk-7-jdk \
    python-flask \
    python-lxml \
    python-pip \

# Install Apino naf-wrapper
RUN pip install KafNafParserPy

# Install and compile tokenizer; use specific version (not necessarily latest)
RUN git clone https://github.com/ixa-ehu/ixa-pipe-tok 
    && git checkout [commitnr]
    && cd ixa-pipe-tok 
    && mvn -Dmaven.compiler.target=1.7 -Dmaven.compiler.source=1.7 clean package

# Remove redundant data and models


# Install morphosyntactic parser
RUN git clone https://github.com/cltl/morphosyntactic_parser_nl
    && git checkout 6f789bd

# Install NERC 
RUN git clone https://github.com/ixa-ehu/ixa-pipe-nerc 
    && git checkout 698fc89
    && cd ixa-pipe-tok 
    && mvn -Dmaven.compiler.target=1.7 -Dmaven.compiler.source=1.7 clean package

