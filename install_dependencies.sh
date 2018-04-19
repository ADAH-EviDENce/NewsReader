#!/usr/bin/env bash
# 
# NewsReader Dutch pipeline
# http://www.newsreader-project.eu/results/software/
# Script to check for dependencies and install them if necessary
set -e

# List of prefix names of modules
DIR="$(pwd)/"
TOK="ixa-pipe-tok"
POS="morphosyntactic_parser_nl"
NER="ixa-pipe-nerc"
NED="ixa-pipe-ned"
WSD="svm_wsd"
TIM="ixa-heideltime"
ONT="OntoTagger"
SRL="vua-srl-nl"
NEV="vua-srl-dutch-nominal-events"
COR="EventCoreference"
OPI="opinion_miner_deluxePP"
DEP="central-dependencies"

# Check for central dependency folder
if [ ! -d $DEP ]; then
    mkdir $DEP
fi

# Central-dependency: KafNafParser
if [ ! -d $DEP/KafNafParserPy ]; then
    printf "KafNafParser not found. Installing KafNafParserPy..."
    cd $DEP
    git clone https://github.com/cltl/KafNafParserPy > /dev/null
    cd KafNafParserPy
    python setup.py install > /dev/null
    cd "$DIR"
    printf "Done\n"
else
    printf "KafNafParser found.\n"
fi

# Central-dependency: vua-resources
if [ ! -d $DEP/vua-resources ]; then
    printf "VUA-resources not found. Installing VUA-resources..."
    cd $DEP
    git clone https://github.com/cltl/vua-resources > /dev/null
    cd $DIR
    printf "Done\n"
else
    printf "VUA-resources found.\n"
fi

# Dependency of POS: Alpino
if [ ! -n $ALPINO_HOME ]; then
    printf "Alpino not found. Installing Alpino..."
    cd $POS
    sh ./install_alpino.sh > /dev/null
    python setup.py install > /dev/null
    cd $DIR
    printf "Done\n"
else
    printf "Alpino found.\n"
fi

# Dependency of NED: dbpedia-spotlight
if [ ! -d $DEP/dbpedia-spotlight/nl ]; then
    printf "DBpedia-spotlight not found. Downloading spotlight jar and models..."
    cd $DEP/dbpedia-spotlight
    apt-get install wget
    wget http://downloads.dbpedia-spotlight.org/spotlight/dbpedia-spotlight-0.7.1.jar
    wget http://downloads.dbpedia-spotlight.org/2016-10/nl/model/nl.tar.gz
    tar -xzvf nl.tar.gz
    cd "$DIR"
    printf "Done\n"
else
    printf "DBpedia-spotlight found.\n"
fi

# Dependency of WSD: libSVM
if [ ! -d $WSD/libsvm ]; then
    printf "libSVM not found. Installing libSVM..."
    cd $WSD
    git clone https://github.com/cjlin1/libsvm.git > /dev/null
    cd libsvm/python
    make > /dev/null
    cd ..
    mv libsvm.so.2 ..
    cd "$DIR"
    printf "Done\n"
else
    printf "libSVM found.\n"
fi

# Dependency of WSD: trained SVM models
if [ ! -d "$WSD/models" ]; then
    printf "WSD models not found. Downloading models..."
    cd $WSD
    wget --user=cltl --password='.cltl.' kyoto.let.vu.nl/~izquierdo/models_wsd_svm_dsc.tgz 2> /dev/null
    tar -xzf models_wsd_svm_dsc.tgz
    rm models_wsd_svm_dsc.tgz
    cd $DIR
    printf "Done\n"
else
    printf "WSD models found.\n"
fi

# Dependency of SRL: additional roles for semantic role-labeling
if [ ! -n "$(which timbl)" ]; then
    printf "TiMBL not found. Installing timbl..."
    apt-get -y install timbl > /dev/null
    printf "Done\n"
else
    printf "TiMBL found.\n"
fi

# Dependency of OPI: CRFlib
if [ ! -d $OPI/crf_lib/CRF++-0.58 ]; then
    printf "CRFlib not found. Installing CRFlib..."
    cd $OPI/crf_lib
    tar -xvzf CRF++-0.58.tar.gz
    rm CRF++-0.58.tar.gz
    cd CRF++-0.58
    ./configure
    make
    printf "Done\n"
    echo "PATH_TO_CRF_TEST='$(pwd)/crf_test'" > path_crf.py
    cd $DIR
else
    printf "CRFlib found.\n"
fi

# Dependency of OPI: SVMlight
if [ ! -d $OPI/svm_light ]; then
    printf "SVMlight not found. Installing SVMlight..."
    cd $OPI
    mkdir svm_light
    cd svm_light
    wget http://download.joachims.org/svm_light/current/svm_light.tar.gz
    tar -xzvf svm_light.tar.gz > /dev/null
    rm svm_light.tar.gz
    make > /dev/null
    cd $DIR
    printf "Done\n"
else
    printf "SVMlight found.\n"
fi

# Dependency of OPI: models opinion_miner_deluxe
if [ ! -d $OPI/models ]; then
    printf "Opinion-miner models not found. Downloading models..."
    cd $OPI
    wget --user=cltl --password='.cltl.' kyoto.let.vu.nl/~izquierdo/models_opinion_miner_deluxePP.tgz
    tar -xvzf models_opinion_miner_deluxePP.tgz > /dev/null
    rm models_opinion_miner_deluxePP.tgz
    cd models
    rm -Rf models_news_en/
    rm -Rf models_news_fr/
    rm -Rf models_news_de/
    rm -Rf models_news_it/
    rm -Rf models_hotel_en/
    rm -Rf models_hotel_fr/
    rm -Rf models_hotel_de/
    rm -Rf models_hotel_it/
    rm -Rf models_hotel_es/
    cd $DIR
    printf "Done\n"
else
    printf "Opinion models found.\n"
fi

# Dependency of OPI: polarity models
if [ ! -d $OPI/polarity_models ]; then
    printf "Polarity models not found. Downloading polarity models..."
    cd $OPI
    wget http://kyoto.let.vu.nl/~izquierdo/public/polarity_models.tgz
    tar -xvzf polarity_models.tgz > /dev/null
    rm polarity_models.tgz
    cd polarity_models
    rm -Rf en/
    cd $DIR
    printf "Done\n"
else
    printf "Polarity models found.\n"
fi
