#!/usr/bin/env bash
# 
# NewsReader Dutch pipeline
# http://www.newsreader-project.eu/results/software/
# Script to run individual Dutch modules of NewsReader

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
cat "$1" | java -jar $TOK/target/ixa-pipe-tok-2.0.0-exec.jar tok -l nl > "$fn-tok.naf" 2> "$fn-tok.log"
if [ $? -ne 0 ]; then
    printf "error:\n"
    cat "$fn-tok.log"
    printf "\nError message was written to %s-tok.log\n" "$fn"
    exit 1
else
    mv "$fn-tok.naf" "$fn.naf"
    rm "$fn-tok.log"
    printf "complete.\n"  
fi

# Part-of-speech-tagging (morphosyntactic parser + Alpino)
printf "Starting part-of-speech tagging... "
cat "$fn.naf" | python -m alpinonaf > "$fn-pos.naf" 2> "$fn-pos.log"
if [ $? -ne 0 ]; then
    printf "error:\n."
    cat "$fn-pos.log"
    printf "\nError message was written to %s-pos.log\n" "$fn"
    exit 2
else
    mv "$fn-pos.naf" "$fn.naf"
    rm "$fn-pos.log"
    printf "complete.\n"  
fi

# Named Entity Recognition (ixa-pipe-ner)
printf "Starting named-entity-recognition... "
cat "$fn.naf" | java -jar $NER/ixa-pipe-nerc-1.6.1-exec.jar tag -m $NER/nl-6-class-clusters-sonar.bin -l nl > "$fn-ner.naf" 2> "$fn-ner.log"
if [ $? -ne 0 ]; then
    printf "error:\n"
    cat "$fn-ner.log"
    printf "\nError message was written to %s-ner.log\n" "$fn"
    exit 3
else
    mv "$fn-ner.naf" "$fn.naf"
    rm "$fn-ner.log"
    printf "complete.\n"  
fi

# Named Entity Disambiguation (ixa-pipe-ned)
printf "Starting named-entity-disambiguation... "
cat "$fn.naf" | java -jar $NED/target/ixa-pipe-ned-1.1.6.jar -p 2060 > "$fn-ned.naf" 2> "$fn-ned.log"
if [ $? -ne 0 ]; then
    printf "error:\n"
    cat "$fn-ned.log"
    printf "\nError message was written to %s-ned.log\n" "$fn"
    exit 4
else
    mv "$fn-ned.naf" "$fn.naf"
    rm "$fn-ned.log"
    printf "complete.\n"  
fi

# Word Sense Disambiguation (svm_wsd)
printf "Starting word-sense-disambiguation... "
cat "$fn.naf" | python2 $WSD/dsc_wsd_tagger.py --naf -ref odwnSY > "$fn-wsd.naf" 2> "$fn-wsd.log"
if [ $? -ne 0 ]; then
    printf "error:\n"
    cat "$fn-wsd.log"
    printf "\nError message was written to %s-wsd.log\n" "$fn"
    exit 5
else
    mv "$fn-wsd.naf" "$fn.naf"
    rm "$fn-wsd.log"
    printf "complete.\n"  
fi

# Time expression recognition (ixa-heideltime)
printf "Starting time-expression-recognition... "
cat "$fn.naf" | java -jar $TIM/target/ixa.pipe.time.jar -m $TIM/lib/alpino-to-treetagger.csv -c $TIM/config.props> "$fn-tim.naf" 2> "$fn-tim.log"
if [ $? -ne 0 ]; then
    printf "error:\n"
    cat "$fn-tim.log"
    printf "\nError message was written to %s-tim.log\n" "$fn"
    exit 6
else
    mv "$fn-tim.naf" "$fn.naf"
    rm "$fn-tim.log"
    printf "complete.\n"  
fi

# Ontological tagging - predicates (PredicateMatrix tagger)
printf "Starting predicate-tagging... "
cat "$fn.naf" | java -Xmx1812m -cp "$ONT/target/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.KafPredicateMatrixTagger --mappings "fn;mcr;ili;eso" --key odwn-eq --version 1.2 --predicate-matrix "$DEP/vua-resources/PredicateMatrix.v1.3.txt.role.odwn.gz" --grammatical-words "$DEP/vua-resources/Grammatical-words.nl" > "$fn-prd.naf" 2> "$fn-prd.log"
if [ $? -ne 0 ]; then
    printf "error:\n"
    cat "$fn-prd.log"
    printf "\nError message was written to %s-prd.log\n" "$fn"
    exit 7
else
    mv "$fn-prd.naf" "$fn.naf"
    rm "$fn-prd.log"
    printf "complete.\n"  
fi

# Semantic Role Labeling (SONAR + TiMBL)
printf "Starting semantic-role-labeling... "
cat "$fn.naf" | $SRL/run.sh > "$fn-srl.naf" 2> "$fn-srl.log"
if [ $? -ne 0 ]; then
    printf "error:\n"
    cat "$fn-srl.log"
    printf "\nError message was written to %s-srl.log\n" "$fn"
    exit 8
else
    mv "$fn-srl.naf" "$fn.naf"
    rm "$fn-srl.log"
    printf "complete.\n"  
fi

# Ontological tagging - FrameNets (FrameNetClassifier)
printf "Starting FrameNet-classification... "
cat "$fn.naf" | java -Xmx1812m -cp "$ONT/target/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.SrlFrameNetTagger --frame-ns "fn:" --role-ns "fn-role:;pb-role:;fn-pb-role:;eso-role:" --ili-ns "mcr:ili" --sense-conf 0.05 --frame-conf 30 > "$fn-frm.naf" 2> "$fn-frm.log"
if [ $? -ne 0 ]; then
    printf "error:\n"
    cat "$fn-frm.log"
    printf "\nError message was written to %s-frm.log\n" "$fn"
    exit 9
else
    mv "$fn-frm.naf" "$fn.naf"
    rm "$fn-frm.log"
    printf "complete.\n"  
fi

# Ontological tagging - Nominal Events (NominalEventCoreference)
printf "Starting nominal-event-tagging... "
cat "$fn.naf" | java -Xmx812m -cp "$ONT/target/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.NominalEventCoreference --framenet-lu "$DEP/vua-resources/nl-luIndex.xml" > "$fn-eve.naf" 2> "$fn-eve.log"
if [ $? -ne 0 ]; then
    printf "error:\n"
    cat "$fn-eve.log"
    printf "\nError message was written to %s-eve.log\n" "$fn"
    exit 10
else
    mv "$fn-eve.naf" "$fn.naf"
    rm "$fn-eve.log"
    printf "complete.\n"  
fi

# Nominal events (additional-dutch-roles)
printf "Starting additional-dutch-role-tagging... "
cat "$fn.naf" | python2 $NEV/vua-srl-dutch-additional-roles.py > "$fn-adr.naf" 2> "$fn-adr.log"
if [ $? -ne 0 ]; then
    printf "error:\n"
    cat "$fn-adr.log"
    printf "\nError message was written to %s-adr.log\n" "$fn"
    exit 11
else
    mv "$fn-adr.naf" "$fn.naf"
    rm "$fn-adr.log"
    printf "complete.\n"  
fi

# Event Coreference
printf "Starting event-coreferencing... "
cat "$fn.naf" | java -Xmx812m -cp "$COR/lib/EventCoreference-v3.1.2-jar-with-dependencies.jar" eu.newsreader.eventcoreference.naf.EventCorefWordnetSim --method leacock-chodorow --wn-lmf "$DEP/vua-resources/odwn_orbn_gwg-LMF_1.3.xml.gz" --sim 2.0 --sim-ont 0.6 --wsd 0.8 --relations "XPOS_NEAR_SYNONYM#HAS_HYPERONYM#HAS_XPOS_HYPERONYM#event" --source-frames "$DEP/vua-resources/source.txt" --grammatical-frames "$DEP/vua-resources/grammatical.txt" --contextual-frames "$DEP/vua-resources/contextual.txt" > "$fn-cor.naf" 2> "$fn-cor.log"
if [ $? -ne 0 ]; then
    printf "error:\n"
    cat "$fn-cor.log"
    printf "\nError message was written to %s-cor.log\n" "$fn"
    exit 12
else
    mv "$fn-cor.naf" "$fn.naf"
    rm "$fn-cor.log"
    printf "complete.\n"  
fi

# Opinion miner (opinion_miner_deluxePP)
printf "Starting opinion mining... "
cat "$fn.naf" | python2 $OPI/tag_file.py -f $OPI/models/models_news_nl/ > "$fn-opi.naf" 2> "$fn-opi.log"
if [ $? -ne 0 ]; then
    printf "error:\n"
    cat "$fn-opi.log"
    printf "\nError message was written to %s-opi.log\n" "$fn"
    exit 13
else
    mv "$fn-opi.naf" "$fn.naf"
    rm "$fn-opi.log"
    printf "complete.\n"  
fi

# Close dbpedia-spotlight server
if lsof -Pi :2060 -sTCP:LISTEN -t > /dev/null ; then
    echo "Closing dbpedia-spotlight server."
    kill "$(lsof -Pi :2060 -sTCP:LISTEN -t)"
fi

# Final steps
echo "Done. Elapsed time: $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
