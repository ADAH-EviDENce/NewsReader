#!/usr/bin/env bash
# 
# Script to run individual Dutch modules of NewsReader
# http://www.newsreader-project.eu/results/software/

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
DEP="dependencies"

# First argument is a text file
if [ $# == 0 ]; then
    echo "No file given as argument."
    exit 1
else
    fn=$(echo $1 | cut -d'.' -f 1)    
fi

### Check for dependencies

# Check for Alpino
if [ -n $ALPINO_HOME ]; then
    echo "Alpino found."
else
    echo "Alpino not found. Installing Alpino.."
    cd $POS/morphosyntactic_parser_nl
    sh ./install_alpino.sh
    python setup.py install
    cd ..
fi

# Check if Word Sense Disambiguation models are present
if [ ! -d "./05_word-sense-disambiguation/models" ]; then
    echo 'Downloading models...(could take a while)'
    wget --user=cltl --password='.cltl.' kyoto.let.vu.nl/~izquierdo/models_wsd_svm_dsc.tgz $WSD/models 2> /dev/null
    echo 'Unzipping models...'
    tar xzf $WSD/models_wsd_svm_dsc.tgz $WSD/models
    rm $WSD/models_wsd_svm_dsc.tgz
    echo 'Models installed in folder models'
fi

if [ ! -n $(which timbl) ]; then
    echo "TiMBL not found. Please installed through 'apt-get install timbl'."
fi

# Start dbpedia-spotlight server
if lsof -Pi :2060 -sTCP:LISTEN -t > /dev/null ; then
    echo "DBpedia-spotlight server already running."
else
    echo "Starting dbpedia-spotlight server.."
    sh $DEP/dbpedia-spotlight/start-dbpedia-spotlight.sh > dbpedia-spotlight.log 2>&1 &
    sleep 10
fi

### Start pipeline

# Run IXA Tokenizer
cat $1 | java -jar $TOK/ixa-pipe-tok-2.0.0-exec.jar tok -l nl > "$fn-tok.naf"

# # Run IXA Part-Of-Speech tagger
# cat "$fn-tok.naf" | java -jar $POS/ixa-pipe-pos-1.5.3-exec.jar tag -m $POS/nl-pos-perceptron-autodict01-alpino.bin -lm $POS/nl-lemma-perceptron-alpino.bin > "$fn-pos.naf"

# Morphosyntactic parser
cat "$fn-tok.naf" | $POS/morphosyntactic_parser_nl/run_parser.sh > "$fn-pos.naf"

# Run IXA Named Entity Recognition
cat "$fn-pos.naf" | java -jar $NER/ixa-pipe-nerc-1.6.1-exec.jar tag -m $NER/nl-6-class-clusters-sonar.bin -l nl > "$fn-ner.naf"

# Run IXA Named Entity Disambiguation
cat "$fn-ner.naf" | java -jar $NED/ixa-pipe-ned-1.1.6.jar -p 2060 > "$fn-ned.naf"

# Run Word Sense Disambiguation
cat "$fn-ned.naf" | python2 $WSD/dsc_wsd_tagger.py --naf -ref odwnSY > "$fn-wsd.naf"

# Run Heideltime 
# cat "$fn-wsd.naf" | > "$fn-time.naf"

# Run PredicateMatrix inserter
cat "$fn-wsd.naf" | java -Xmx1812m -cp "$ONT/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.KafPredicateMatrixTagger --mappings "fn;mcr;ili;eso" --key odwn-eq --version 1.2 --predicate-matrix "./dependencies/vua-resources/PredicateMatrix.v1.3.txt.role.odwn.gz" --grammatical-words "$DEP/vua-resources/Grammatical-words.nl" > "$fn-pmat.naf"

# Run SONAR's Semantic Role Labeller (timbl)
cat "$fn-pmat.naf" | bash $SRL/run.sh  

# Run Framenet classifier
cat "$fn-pmat.naf" | java -Xmx1812m -cp "$ONT/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.SrlFrameNetTagger --frame-ns "fn:" --role-ns "fn-role:;pb-role:;fn-pb-role:;eso-role:" --ili-ns "mcr:ili" --sense-conf 0.05 --frame-conf 30 > "$fn-frm.naf"

# Run Nominal Event recognizer
cat "$fn-frm.naf" | java -Xmx812m -cp "$ONT/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.NominalEventCoreference --framenet-lu "$DEP/vua-resources/nl-luIndex.xml" > "$fn-events.naf"

# Run additional Semantic Roles detector
cat "$fn-events.naf" | python2 $NEV/vua-srl-dutch-additional-roles.py > "$fn-evtad.naf" 

# Run Event Coreference
# cat "$fn-evtad.naf" | > "$fn-coref.naf"

# Run Opinion Miner
cat "$fn-evtad.naf" | python2 $OPI/tag_file.py -f $DEP/models/ > "$fn-opin.naf"

# Close dbpedia-spotlight server
if lsof -Pi :2060 -sTCP:LISTEN -t > /dev/null ; then
    echo "Closing dbpedia-spotlight server."
    kill $(lsof -Pi :2060 -sTCP:LISTEN -t)
fi

# Report complete
echo "Done."
