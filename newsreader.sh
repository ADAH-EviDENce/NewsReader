#!/usr/bin/env bash
# 
# NewsReader Dutch pipeline
# http://www.newsreader-project.eu/results/software/
# Script to run individual Dutch modules of NewsReader
set -e

# List of prefix names of modules
DIR="$(pwd)/"
TOK="ixa-pipe-tok"
POS="morphosyntactic_parser_nl"
NER="ixa-pipe-nerc"
NED="ixa-pipe-ned"
WSD="vua-svm-wsd"
TIM="ixa-heideltime"
ONT="OntoTagger"
SRL="vua-srl-nl"
NEV="vua-srl-dutch-nominal-events"
COR="EventCoreference"
OPI="opinion_miner_deluxePP"
DEP="central-dependencies"

# Check for file given
if [ $# == 0 ]; then
    printf "No file given as argument.\n"
    exit 1
else
    fn=$(printf $1 | cut -d'.' -f 1)    
fi

# Start dbpedia-spotlight server
if lsof -Pi :2060 -sTCP:LISTEN -t > /dev/null ; then
    printf "DBpedia-spotlight server already running.\n"
else
    printf "Starting dbpedia-spotlight server..\n"
    sh $DEP/dbpedia-spotlight/start-dbpedia-spotlight.sh > dbpedia-spotlight.log 2>&1 &
    sleep 5
fi

# Tokenization (ixa-pipe-tok)
cat $1 | java -jar $TOK/ixa-pipe-tok-2.0.0-exec.jar tok -l nl > "$fn-tok.naf"

# Part-of-speech-tagging (morphosyntactic parser + Alpino)
cat "$fn-tok.naf" | $POS/run_parser.sh > "$fn-pos.naf"

# Named Entity Recognition (ixa-pipe-ner)
cat "$fn-pos.naf" | java -jar $NER/ixa-pipe-nerc-1.6.1-exec.jar tag -m $NER/nl-6-class-clusters-sonar.bin -l nl > "$fn-ner.naf"

# Named Entity Disambiguation (ixa-pipe-ned)
cat "$fn-ner.naf" | java -jar $NED/ixa-pipe-ned-1.1.6.jar -p 2060 > "$fn-ned.naf"

# Word Sense Disambiguation (svm_wsd)
cat "$fn-ned.naf" | python2 $WSD/dsc_wsd_tagger.py --naf -ref odwnSY > "$fn-wsd.naf"

# Time expression recognition (ixa-heideltime + Heideltime)
# cat "$fn-wsd.naf" | > "$fn-time.naf"

# Ontological tagging - predicates (PredicateMatrix tagger)
cat "$fn-wsd.naf" | java -Xmx1812m -cp "$ONT/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.KafPredicateMatrixTagger --mappings "fn;mcr;ili;eso" --key odwn-eq --version 1.2 --predicate-matrix "$DEP/vua-resources/PredicateMatrix.v1.3.txt.role.odwn.gz" --grammatical-words "$DEP/vua-resources/Grammatical-words.nl" > "$fn-pmat.naf"

# Semantic Role Labeling (SONAR + TiMBL)
#TODO
cat "$fn-pmat.naf" | ./$SRL/run.sh 

# Ontological tagging - FrameNets (FrameNetClassifier)
cat "$fn-pmat.naf" | java -Xmx1812m -cp "$ONT/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.SrlFrameNetTagger --frame-ns "fn:" --role-ns "fn-role:;pb-role:;fn-pb-role:;eso-role:" --ili-ns "mcr:ili" --sense-conf 0.05 --frame-conf 30 > "$fn-frm.naf"

# Ontological tagging - Nominal Events (NominalEventCoreference)
cat "$fn-frm.naf" | java -Xmx812m -cp "$ONT/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.NominalEventCoreference --framenet-lu "$DEP/vua-resources/nl-luIndex.xml" > "$fn-events.naf"

# Nominal events (additional-dutch-roles)
cat "$fn-events.naf" | python2 $NEV/vua-srl-dutch-additional-roles.py > "$fn-evadd.naf" 

# Event Coreference
# cat "$fn-evtad.naf" | > "$fn-coref.naf"

# Opinion miner (opinion_miner_deluxePP)
cat "$fn-evadd.naf" | python2 $OPI/tag_file.py -f $OPI/models/models_news_nl/ > "$fn-opin.naf"

# Close dbpedia-spotlight server
if lsof -Pi :2060 -sTCP:LISTEN -t > /dev/null ; then
    printf "Closing dbpedia-spotlight server.\n"
    kill $(lsof -Pi :2060 -sTCP:LISTEN -t)
fi

# Report
printf "Done.\n"
