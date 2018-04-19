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
WSD="svm_wsd"
TIM="ixa-heideltime"
ONT="OntoTagger"
SRL="vua-srl-nl"
NEV="vua-srl-dutch-nominal-events"
COR="EventCoreference"
OPI="opinion_miner_deluxePP"
DEP="central-dependencies"

# Check for file given
if [ $# == 0 ]; then
    echo "No file given as argument."
    exit 1
else
    fn=$(echo "$1" | cut -d'.' -f 1)    
fi

# Start dbpedia-spotlight server
if lsof -Pi :2060 -sTCP:LISTEN -t > /dev/null ; then
    echo "DBpedia-spotlight server already running."
else
    echo "Starting dbpedia-spotlight server.."
    java -jar $DEP/dbpedia-spotlight/dbpedia-spotlight-0.7.1.jar $DEP/dbpedia-spotlight/nl http://localhost:2060/rest > dbpedia-spotlight.log 2>&1 &
fi

# Tokenization (ixa-pipe-tok)
cat "$1" | java -jar $TOK/target/ixa-pipe-tok-2.0.0-exec.jar tok -l nl > "$fn-tok.naf"
echo "Tokenization complete."

# Part-of-speech-tagging (morphosyntactic parser + Alpino)
cat "$fn-tok.naf" | python -m alpinonaf -t 0.1 > "$fn-pos.naf"
echo "Part-of-speech tagging complete."

# Named Entity Recognition (ixa-pipe-ner)
cat "$fn-pos.naf" | java -jar $NER/ixa-pipe-nerc-1.6.1-exec.jar tag -m $NER/nl-6-class-clusters-sonar.bin -l nl > "$fn-ner.naf"
echo "Named entity recognition complete."

# Named Entity Disambiguation (ixa-pipe-ned)
cat "$fn-ner.naf" | java -jar $NED/target/ixa-pipe-ned-1.1.6.jar -p 2060 > "$fn-ned.naf"
echo "Named entity disambiguation complete."

# Word Sense Disambiguation (svm_wsd)
cat "$fn-ned.naf" | python2 $WSD/dsc_wsd_tagger.py --naf -ref odwnSY > "$fn-wsd.naf"
echo "Word sense disambiguation complete."

# Time expression recognition (ixa-heideltime + Heideltime)
cat "$fn-wsd.naf" | java -jar $TIM/target/ixa.pipe.time.jar -m $TIM/lib/alpino-to-treetagger.csv -c $TIM/config.props> "$fn-time.naf"
echo "Time expression recognition complete."

# Ontological tagging - predicates (PredicateMatrix tagger)
cat "$fn-time.naf" | java -Xmx1812m -cp "$ONT/target/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.KafPredicateMatrixTagger --mappings "fn;mcr;ili;eso" --key odwn-eq --version 1.2 --predicate-matrix "$DEP/vua-resources/PredicateMatrix.v1.3.txt.role.odwn.gz" --grammatical-words "$DEP/vua-resources/Grammatical-words.nl" > "$fn-pmat.naf"
echo "Predicate tagging complete."

# Semantic Role Labeling (SONAR + TiMBL)
cat "$fn-pmat.naf" | $SRL/run.sh > "$fn-srl.naf" 
echo "Semantic role labeling complete."

# Ontological tagging - FrameNets (FrameNetClassifier)
cat "$fn-srl.naf" | java -Xmx1812m -cp "$ONT/target/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.SrlFrameNetTagger --frame-ns "fn:" --role-ns "fn-role:;pb-role:;fn-pb-role:;eso-role:" --ili-ns "mcr:ili" --sense-conf 0.05 --frame-conf 30 > "$fn-frm.naf"
echo "FrameNet classification complete."

# Ontological tagging - Nominal Events (NominalEventCoreference)
cat "$fn-frm.naf" | java -Xmx812m -cp "$ONT/target/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.NominalEventCoreference --framenet-lu "$DEP/vua-resources/nl-luIndex.xml" > "$fn-events.naf"
echo "Nominal event tagging complete."

# Nominal events (additional-dutch-roles)
cat "$fn-events.naf" | python2 $NEV/vua-srl-dutch-additional-roles.py > "$fn-evadd.naf" 
echo "Additional role tagging complete."

# Event Coreference
cat "$fn-evadd.naf" | java -Xmx812m -cp "$COR/lib/EventCoreference-v3.1.2-jar-with-dependencies.jar" eu.newsreader.eventcoreference.naf.EventCorefWordnetSim --method leacock-chodorow --wn-lmf "$DEP/vua-resources/odwn_orbn_gwg-LMF_1.3.xml.gz" --sim 2.0 --sim-ont 0.6 --wsd 0.8 --relations "XPOS_NEAR_SYNONYM#HAS_HYPERONYM#HAS_XPOS_HYPERONYM#event" --source-frames "$DEP/vua-resources/source.txt" --grammatical-frames "$DEP/vua-resources/grammatical.txt" --contextual-frames "$DEP/vua-resources/contextual.txt" > "$fn-coref.naf"
echo "Event coreference recognition complete."

# Opinion miner (opinion_miner_deluxePP)
cat "$fn-coref.naf" | python2 $OPI/tag_file.py -f $OPI/models/models_news_nl/ > "$fn.naf"
echo "Opinion mining complete."

# Close dbpedia-spotlight server
if lsof -Pi :2060 -sTCP:LISTEN -t > /dev/null ; then
    echo "Closing dbpedia-spotlight server."
    kill "$(lsof -Pi :2060 -sTCP:LISTEN -t)"
fi

# Report
echo "Done."
