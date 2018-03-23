#!/usr/bin/env bash
# 
# Script to run individual Dutch modules of NewsReader
# http://www.newsreader-project.eu/results/software/

# First argument is a text file
if [ $# == 0 ]; then
    echo "No file given as argument."
    exit 1
else
    fn=$(echo $1 | cut -d'.' -f 1)    
fi

# Run IXA Tokenizer
cat "$fn.txt" | java -jar ./tokenization/ixa-pipe-tok-2.0.0-exec.jar tok -l nl > "$fn-tok.naf"

# # Run IXA Part-Of-Speech tagger
# cat "$fn-tok.naf" | java -jar ./part-of-speech-tagging/ixa-pipe-pos/ixa-pipe-pos-1.5.3-exec.jar tag -m ./part-of-speech-tagging/ixa-pipe-pos/morph-models-1.5.0/nl/nl-pos-perceptron-autodict01-alpino.bin -lm ../ixa-pipe-pos/morph-models-1.5.0/nl/nl-lemma-perceptron-alpino.bin > "$fn-pos.naf"

# Morphosyntactic parser
if [ -n $ALPINO_HOME ]; then
    echo "Alpino found."
else
    echo "Alpino not found. Installing Alpino.."
    cd ./morphosyntactic_parser_nl
    sh ./install_alpino.sh
    python setup.py install
    cd ..
fi
cat "$fn-tok.naf" | ./part-of-speech-tagging/morphosyntactic_parser_nl/run_parser.sh > "$fn-pos.naf"

# Run IXA Named Entity Recognition
cat "$fn-pos.naf" | java -jar ./named-entity-recognition/ixa-pipe-nerc-1.6.1-exec.jar tag -m ./named-entity-recognition/nl-6-class-clusters-sonar.bin -l nl > "$fn-ner.naf"

# Start dbpedia-spotlight server
if lsof -Pi :2060 -sTCP:LISTEN -t > /dev/null ; then
    echo "DBpedia-spotlight server already running."
else
    echo "Starting dbpedia-spotlight server.."
    sh ./dbpedia-spotlight/start-dbpedia-spotlight.sh > dbpedia-spotlight.log 2>&1 &
    sleep 10
fi

# Run IXA Named Entity Disambiguation
cat "$fn-ner.naf" | java -jar ./named-entity-disambiguation/ixa-pipe-ned-1.1.6.jar -p 2060 > "$fn-ned.naf"

# Close dbpedia-spotlight server
if lsof -Pi :2060 -sTCP:LISTEN -t > /dev/null ; then
    echo "Closing dbpedia-spotlight server."
    kill $(lsof -Pi :2060 -sTCP:LISTEN -t)
fi

# Download WSD models
echo 'Downloading models...(could take a while)'
wget --user=cltl --password='.cltl.' kyoto.let.vu.nl/~izquierdo/models_wsd_svm_dsc.tgz 2> /dev/null
echo 'Unzipping models...'
tar xzf models_wsd_svm_dsc.tgz ./word-sense-disambiguation/
rm models_wsd_svm_dsc.tgz
echo 'Models installed in folder models'

# Run Word Sense Disambiguation
cat "$fn-ned.naf" | python2 ./word-sense-disambiguation/svm_wsd/dsc_wsd_tagger.py --naf -ref odwnSY> "$fn-wsd.naf"

# Run Heideltime 
# cat "$fn-wsd.naf" | > "$fn-time.naf"

# Run PredicateMatrix inserter
cat "$fn-wsd.naf" | java -Xmx1812m -cp "./ontological-tagger/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.KafPredicateMatrixTagger --mappings "fn;mcr;ili;eso" --key odwn-eq --version 1.2 --predicate-matrix "./dependencies/vua-resources/PredicateMatrix.v1.3.txt.role.odwn.gz" --grammatical-words "./dependencies/vua-resources/Grammatical-words.nl" > "$fn-pmat.naf"

# Run SONAR's Semantic Role Labeller (timbl)
if [ ! -n $(which timbl) ]; then
    echo "TiMBL not found. Please installed through 'apt-get install timbl'."
fi
cat "$fn-pmat.naf" | ./semantic-role-labeling/run.sh  

# Run Framenet classifier
cat "$fn-pmat.naf" | java -Xmx1812m -cp "./ontological-tagger/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.SrlFrameNetTagger --frame-ns "fn:" --role-ns "fn-role:;pb-role:;fn-pb-role:;eso-role:" --ili-ns "mcr:ili" --sense-conf 0.05 --frame-conf 30 > "$fn-frm.naf"

# Run Nominal Event recognizer
cat "$fn-frm.naf" | java -Xmx812m -cp "./ontological-tagger/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.NominalEventCoreference --framenet-lu "./dependencies/vua-resources/nl-luIndex.xml" > "$fn-events.naf"

# Run additional Semantic Roles detector
cat "$fn-events.naf" | python2 ./nominal-events/vua-srl-dutch-additional-roles.py > "$fn-evtad.naf" 

# # Run Event Coreference
# cat "$fn-evtad.naf" | > "$fn-coref.naf"

# # Run Opinion Miner
# cat "$fn-coref.naf" | > "$fn-opin.naf"

# Report complete
echo "Done."
