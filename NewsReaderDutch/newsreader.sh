#!/usr/bin/env bash
# 
# NewsReader Dutch pipeline
# http://www.newsreader-project.eu/results/software/
# Script to run individual Dutch modules of NewsReader
set -e

# List of prefix names of modules       
TOK="/ixa-pipe-tok"
POS="/morphosyntactic_parser_nl"
NER="/ixa-pipe-nerc"
NED="/ixa-pipe-ned"
WSD="/svm_wsd"
TIM="/ixa-heideltime"
ONT="/OntoTagger"
SRL="/vua-srl-nl"
NEV="/vua-srl-dutch-nominal-events"
COR="/EventCoreference"
OPI="/opinion_miner_deluxePP"
DEP="/central-dependencies"

# Check for file given
if [ $# == 0 ]; then
    echo "No file given as argument."
    exit 1
else
    fn=$(echo "$1" | cut -d'.' -f 1)    
fi

# Start timer
SECONDS=0

# Start dbpedia-spotlight server
if lsof -Pi :2060 -sTCP:LISTEN -t > /dev/null ; then
    echo "DBpedia-spotlight server already running."
else
    echo "Starting dbpedia-spotlight server.."
    java -jar $DEP/dbpedia-spotlight/dbpedia-spotlight-0.7.1.jar $DEP/dbpedia-spotlight/nl http://localhost:2060/rest > dbpedia-spotlight.log 2>&1 &
fi

# Tokenization (ixa-pipe-tok)
printf "Starting tokenization... "
(cat "$1" | java -jar $TOK/target/ixa-pipe-tok-2.0.0-exec.jar tok -l nl > "$fn-tok.naf" 2> "$fn-tok.log") 2> "$fn-tok.err"; [ -s "$fn-tok.err" ] || rm -f "$fn-tok.err"
if [ -e "$fn-tok.err" ]; then
    printf "error. Check $fn-tok.err for details.\n"
    exit 1
else
    printf "complete.\n"  
fi

# Part-of-speech-tagging (morphosyntactic parser + Alpino)
printf "Starting part-of-speech tagging... "
(cat "$fn-tok.naf" | python -m alpinonaf -t 0.05 > "$fn-pos.naf" 2> "$fn-pos.log") 2> "$fn-pos.err"; [ -s "$fn-pos.err" ] || rm -f "$fn-pos.err"
if [ -e "$fn-pos.err" ]; then
    printf "error. Check $fn-pos.err for details.\n"
    exit 1
else
    printf "complete.\n"  
fi

# Named Entity Recognition (ixa-pipe-ner)
printf "Starting named-entity-recognition... "
(cat "$fn-pos.naf" | java -jar $NER/ixa-pipe-nerc-1.6.1-exec.jar tag -m $NER/nl-6-class-clusters-sonar.bin -l nl > "$fn-ner.naf" 2> "$fn-ner.log") 2> "$fn-ner.err"; [ -s "$fn-ner.err" ] || rm -f "$fn-ner.err"
if [ -e "$fn-ner.err" ]; then
    printf "error. Check $fn-ner.err for details.\n"
    exit 1
else
    printf "complete.\n"  
fi

# Named Entity Disambiguation (ixa-pipe-ned)
printf "Starting named-entity-disambiguation... "
(cat "$fn-ner.naf" | java -jar $NED/target/ixa-pipe-ned-1.1.6.jar -p 2060 > "$fn-ned.naf" 2> "$fn-ned.log") 2> "$fn-ned.err"; [ -s "$fn-ned.err" ] || rm -f "$fn-ned.err"
if [ -e "$fn-ned.err" ]; then
    printf "error. Check $fn-ned.err for details.\n"
    exit 1
else
    printf "complete.\n"  
fi

# Word Sense Disambiguation (svm_wsd)
printf "Starting word-sense-disambiguation... "
(cat "$fn-ned.naf" | python2 $WSD/dsc_wsd_tagger.py --naf -ref odwnSY > "$fn-wsd.naf" 2> "$fn-wsd.log") 2> "$fn-wsd.err"; [ -s "$fn-wsd.err" ] || rm -f "$fn-wsd.err"
if [ -e "$fn-wsd.err" ]; then
    printf "error. Check $fn-wsd.err for details.\n"
    exit 1
else
    printf "complete.\n"  
fi

# Time expression recognition (ixa-heideltime + Heideltime)
printf "Starting time-expression-recognition... "
(cat "$fn-wsd.naf" | java -jar $TIM/target/ixa.pipe.time.jar -m $TIM/lib/alpino-to-treetagger.csv -c $TIM/config.props> "$fn-tim.naf" 2> "$fn-tim.log") 2> "$fn-tim.err"; [ -s "$fn-tim.err" ] || rm -f "$fn-tim.err"
if [ -e "$fn-tim.err" ]; then
    printf "error. Check $fn-tim.err for details.\n"
    exit 1
else
    printf "complete.\n"  
fi

# Ontological tagging - predicates (PredicateMatrix tagger)
printf "Starting predicate-tagging... "
(cat "$fn-tim.naf" | java -Xmx1812m -cp "$ONT/target/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.KafPredicateMatrixTagger --mappings "fn;mcr;ili;eso" --key odwn-eq --version 1.2 --predicate-matrix "$DEP/vua-resources/PredicateMatrix.v1.3.txt.role.odwn.gz" --grammatical-words "$DEP/vua-resources/Grammatical-words.nl" > "$fn-prd.naf" 2> "$fn-prd.log") 2> "$fn-prd.err"; [ -s "$fn-prd.err" ] || rm -f "$fn-prd.err"
if [ -e "$fn-prd.err" ]; then
    printf "error. Check $fn-prd.err for details.\n"
    exit 1
else
    printf "complete.\n"  
fi

# Semantic Role Labeling (SONAR + TiMBL)
printf "Starting semantic-role-labeling... "
(cat "$fn-prd.naf" | $SRL/run.sh > "$fn-srl.naf" 2> "$fn-srl.log") 2> "$fn-srl.err"; [ -s "$fn-srl.err" ] || rm -f "$fn-srl.err"
if [ -e "$fn-srl.err" ]; then
    printf "error. Check $fn-srl.err for details.\n"
    exit 1
else
    printf "complete.\n"  
fi

# Ontological tagging - FrameNets (FrameNetClassifier)
printf "Starting FrameNet-classification... "
(cat "$fn-srl.naf" | java -Xmx1812m -cp "$ONT/target/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.SrlFrameNetTagger --frame-ns "fn:" --role-ns "fn-role:;pb-role:;fn-pb-role:;eso-role:" --ili-ns "mcr:ili" --sense-conf 0.05 --frame-conf 30 > "$fn-frm.naf" 2> "$fn-frm.log") 2> "$fn-frm.err"; [ -s "$fn-frm.err" ] || rm -f "$fn-frm.err"
if [ -e "$fn-frm.err" ]; then
    printf "error. Check $fn-frm.err for details.\n"
    exit 1
else
    printf "complete.\n"  
fi

# Ontological tagging - Nominal Events (NominalEventCoreference)
printf "Starting nominal-event-tagging... "
(cat "$fn-frm.naf" | java -Xmx812m -cp "$ONT/target/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.NominalEventCoreference --framenet-lu "$DEP/vua-resources/nl-luIndex.xml" > "$fn-eve.naf" 2> "$fn-eve.log") 2> "$fn-eve.err"; [ -s "$fn-eve.err" ] || rm -f "$fn-eve.err"
if [ -e "$fn-eve.err" ]; then
    printf "error. Check $fn-eve.err for details.\n"
    exit 1
else
    printf "complete.\n"  
fi

# Nominal events (additional-dutch-roles)
printf "Starting additional-dutch-role-tagging... "
(cat "$fn-eve.naf" | python2 $NEV/vua-srl-dutch-additional-roles.py > "$fn-adr.naf" 2> "$fn-adr.log") 2> "$fn-adr.err"; [ -s "$fn-adr.err" ] || rm -f "$fn-adr.err"
if [ -e "$fn-adr.err" ]; then
    printf "error. Check $fn-adr.err for details.\n"
    exit 1
else
    printf "complete.\n"  
fi

# Event Coreference
printf "Starting event-coreferencing... "
(cat "$fn-adr.naf" | java -Xmx812m -cp "$COR/lib/EventCoreference-v3.1.2-jar-with-dependencies.jar" eu.newsreader.eventcoreference.naf.EventCorefWordnetSim --method leacock-chodorow --wn-lmf "$DEP/vua-resources/odwn_orbn_gwg-LMF_1.3.xml.gz" --sim 2.0 --sim-ont 0.6 --wsd 0.8 --relations "XPOS_NEAR_SYNONYM#HAS_HYPERONYM#HAS_XPOS_HYPERONYM#event" --source-frames "$DEP/vua-resources/source.txt" --grammatical-frames "$DEP/vua-resources/grammatical.txt" --contextual-frames "$DEP/vua-resources/contextual.txt" > "$fn-cor.naf" 2> "$fn-cor.log") 2> "$fn-cor.err"; [ -s "$fn-cor.err" ] || rm -f "$fn-cor.err"
if [ -e "$fn-cor.err" ]; then
    printf "error. Check $fn-cor.err for details.\n"
    exit 1
else
    printf "complete.\n"  
fi

# Opinion miner (opinion_miner_deluxePP)
printf "Starting opinion mining... "
(cat "$fn-cor.naf" | python2 $OPI/tag_file.py -f $OPI/models/models_news_nl/ > "$fn-opi.naf" 2> "$fn-opi.log") 2> "$fn-opi.err"; [ -s "$fn-opi.err" ] || rm -f "$fn-opi.err"
if [ -e "$fn-opi.err" ]; then
    printf "error. Check $fn-opi.err for details.\n"
    exit 1
else
    printf "complete.\n"  
fi

# Close dbpedia-spotlight server
if lsof -Pi :2060 -sTCP:LISTEN -t > /dev/null ; then
    echo "Closing dbpedia-spotlight server."
    kill "$(lsof -Pi :2060 -sTCP:LISTEN -t)"
fi

# Final steps
cp "$fn-opi.naf" "$fn.naf"
echo "Done. Elapsed time: $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
