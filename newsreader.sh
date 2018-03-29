#!/usr/bin/env bash
# 
# Script to run individual Dutch modules of NewsReader
# http://www.newsreader-project.eu/results/software/
set -e

# List of prefix names of modules
DIR="$(pwd)/"
TOK="01_tokenization"
POS="02_part-of-speech-tagging"
NER="03_named-entity-recognition"
NED="04_named-entity-disambiguation"
WSD="05_word-sense-disambiguation"
TIM="06_time-expression-recognition"
ONT="07_ontological-tagging"
SRL="08_semantic-role-labeling"
NEV="09_nominal-events"
COR="10_event-coreference"
OPI="11_opinion-miner"
DEP="central-dependencies"

# First argument is a text file
if [ $# == 0 ]; then
    echo "No file given as argument."
    exit 1
else
    fn=$(echo $1 | cut -d'.' -f 1)    
fi

### Check for dependencies and install/download if necessary

# Central-dependency: KafNafParser
if [ ! -d $DEP/KafNafParser ]; then
    echo "KafNafParser not found. Installing KafNafParserPy.."
    cd $DEP
    git clone https://github.com/cltl/KafNafParserPy
    cd KafNafParserPy
    python setup.py install
    cd $DIR
else
    echo "KafNafParser found."
fi

# Central-dependency: vua-resources
if [ ! -d $DEP/vua-resources ]; then
    echo "VUA-resources not found. Installing VUA-resources.."
    cd $DEP
    git clone https://github.com/cltl/vua-resources
    cd $DIR
else
    echo "VUA-resources found."
fi

# Dependency of POS: Alpino
if [ ! -n $ALPINO_HOME ]; then
    echo "Alpino not found. Installing Alpino.."
    cd $POS/morphosyntactic_parser_nl
    sh ./install_alpino.sh
    python setup.py install
    cd ..
else
    echo "Alpino found."
fi

# Dependency of NED: dbpedia-spotlight server
if lsof -Pi :2060 -sTCP:LISTEN -t > /dev/null ; then
    echo "DBpedia-spotlight server already running."
else
    echo "Starting dbpedia-spotlight server.."
    sh $DEP/dbpedia-spotlight/start-dbpedia-spotlight.sh > dbpedia-spotlight.log 2>&1 &
fi

# Dependency of WSD: trained SVM models
if [ ! -d "$WSD/models" ]; then
    echo "WSD models not found. Downloading models..."
    wget --user=cltl --password='.cltl.' kyoto.let.vu.nl/~izquierdo/models_wsd_svm_dsc.tgz $WSD/models 2> /dev/null
    tar -xzf $WSD/models_wsd_svm_dsc.tgz $WSD/models
    rm $WSD/models_wsd_svm_dsc.tgz
    echo "Models downloaded and unpacked."
else
    echo "WSD models found."
fi

# Dependency of SRL: additional roles for semantic role-labeling
if [ ! -n $(which timbl) ]; then
    echo "TiMBL not found. Installing timbl.."
    apt-get -y install timbl
else
    echo "TiMBL found."
fi

# Dependency of OPI: CRFlib
if [ ! -d $DEP/CRF++-0.58 ]; then
    echo "CRFlib not found. Installing CRFlib.."
    cd $DEP
    tar -xvzf CRF++-0.58.tar.gz
    rm CRF++-0.58.tar.gz
    cd CRF++-0.58
    ./configure
    make
    cd $DIR
    echo "PATH_TO_CRF_TEST='$DIR/$DEP/CRF++-0.58/crf_test'" > path_crf.py
else
    echo "CRFlib found."
fi

# Dependency of OPI: SVMlight
if [ ! -d $DEP/svm_light ]; then
    echo "SVMlight not found. Installing SVMlight.."
    mkdir $DEP/svm_light
    cd $DEP/svm_light
    wget http://download.joachims.org/svm_light/current/svm_light.tar.gz
    gunzip -c svm_light.tar.gz | tar xvf -
    make
    rm svm_light.tar.gz
    cd $DIR
else
    echo "SVMlight found."
fi

# Dependency of OPI: models opinion_miner_deluxe
if [ ! -d $OPI/models ]; then
    echo "Opinion-miner models not found. Downloading models.."
    cd $OPI
    wget --user=cltl --password='.cltl.' kyoto.let.vu.nl/~izquierdo/models_opinion_miner_deluxePP.tgz
    tar -xvzf models_opinion_miner_deluxePP.tgz
    rm models_opinion_miner_deluxePP.tgz
    cd $DIR
else
    echo "Opinion-miner models found."
fi

# Dependency of OPI: polarity models
if [ ! -d $OPI/polarity_models ]; then
    echo "Polarity models not found. Downloading polarity models.."
    cd $OPI
    wget http://kyoto.let.vu.nl/~izquierdo/public/polarity_models.tgz
    tar -xvzf polarity_models.tgz
    rm polarity_models.tgz
    cd $DIR
else
    echo "Polarity models found."
fi

### Start pipeline

# 01) Tokenization (ixa-pipe-tok)
cat $1 | java -jar $TOK/ixa-pipe-tok-2.0.0-exec.jar tok -l nl > "$fn-tok.naf"

# 02) Part-of-speech-tagging (morphosyntactic parser + Alpino)
cat "$fn-tok.naf" | $POS/morphosyntactic_parser_nl/run_parser.sh > "$fn-pos.naf"

# 03) Named Entity Recognition (ixa-pipe-ner)
cat "$fn-pos.naf" | java -jar $NER/ixa-pipe-nerc-1.6.1-exec.jar tag -m $NER/nl-6-class-clusters-sonar.bin -l nl > "$fn-ner.naf"

# 04) Named Entity Disambiguation (ixa-pipe-ned)
cat "$fn-ner.naf" | java -jar $NED/ixa-pipe-ned-1.1.6.jar -p 2060 > "$fn-ned.naf"

# 05) Word Sense Disambiguation (svm_wsd)
cat "$fn-ned.naf" | python2 $WSD/dsc_wsd_tagger.py --naf -ref odwnSY > "$fn-wsd.naf"

# 06) Time expression recognition (ixa-heideltime + Heideltime)
# cat "$fn-wsd.naf" | > "$fn-time.naf"

# 07) Ontological tagging - predicates (PredicateMatrix tagger)
cat "$fn-wsd.naf" | java -Xmx1812m -cp "$ONT/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.KafPredicateMatrixTagger --mappings "fn;mcr;ili;eso" --key odwn-eq --version 1.2 --predicate-matrix "./dependencies/vua-resources/PredicateMatrix.v1.3.txt.role.odwn.gz" --grammatical-words "$DEP/vua-resources/Grammatical-words.nl" > "$fn-pmat.naf"

# 08) Semantic Role Labeling (SONAR + TiMBL)
cat "$fn-pmat.naf" | bash $SRL/run.sh  

# 09) Ontological tagging - FrameNets (FrameNetClassifier)
cat "$fn-pmat.naf" | java -Xmx1812m -cp "$ONT/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.SrlFrameNetTagger --frame-ns "fn:" --role-ns "fn-role:;pb-role:;fn-pb-role:;eso-role:" --ili-ns "mcr:ili" --sense-conf 0.05 --frame-conf 30 > "$fn-frm.naf"

# 10) Ontological tagging - Nominal Events (NominalEventCoreference)
cat "$fn-frm.naf" | java -Xmx812m -cp "$ONT/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.NominalEventCoreference --framenet-lu "$DEP/vua-resources/nl-luIndex.xml" > "$fn-events.naf"

# 11) Nominal events (additional-dutch-roles)
cat "$fn-events.naf" | python2 $NEV/vua-srl-dutch-additional-roles.py > "$fn-evadd.naf" 

# 12) Event Coreference
# cat "$fn-evtad.naf" | > "$fn-coref.naf"

# 13) Opinion miner (opinion_miner_deluxePP)
cat "$fn-evadd.naf" | python2 $OPI/tag_file.py -f $DEP/models/ > "$fn-opin.naf"

# Close dbpedia-spotlight server
if lsof -Pi :2060 -sTCP:LISTEN -t > /dev/null ; then
    echo "Closing dbpedia-spotlight server."
    kill $(lsof -Pi :2060 -sTCP:LISTEN -t)
fi

# Report complete
echo "Done."
