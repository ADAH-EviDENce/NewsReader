#!/usr/bin/env bash
# 
# Script to run individual Dutch modules of NewsReader
# http://www.newsreader-project.eu/results/software/

# First argument is a text file
fn=$(echo $1 | cut -d'.' -f 1)

# Run IXA Tokenizer
cat "$fn.txt" | java -jar ./tokenization/ixa-pipe-tok-2.0.0-exec.jar tok -l nl > "$fn-tok.naf"

# # Run IXA Part-Of-Speech tagger
# cat "$fn-tok.naf" | java -jar ./ixa-pipe-pos/target/ixa-pipe-pos-1.5.3-exec.jar tag -m ../ixa-pipe-pos/morph-models-1.5.0/nl/nl-pos-perceptron-autodict01-alpino.bin -lm ../ixa-pipe-pos/morph-models-1.5.0/nl/nl-lemma-perceptron-alpino.bin > "$fn-pos.naf"

# # Run Alpino Docker
# docker run -it --mount type=bind,source=$(pwd),target=/work rugcompling/alpino:latest /bin/bash -c "cat /work/$fn.txt | Alpino -flag treebank xml debug=1 end_hook=xml user_max=900000 -parse"

# Morphosyntactic parser
if [ $(echo $ALPINO_HOME) -ne 0 ]; then
    echo "Installing Alpino"
    cd ./part-of-speech-tagging/morphosyntactic_parser_nl
    sh ./install_alpino.sh
    python setup.py install
    cd ..
fi
cat "$fn-tok.naf" | ./part-of-speech-tagging/morphosyntactic_parser_nl/run_parser.sh > "$fn-pos.naf"

# Run IXA Named Entity Recognition
cat "$fn-pos.naf" | java -jar ./named-entity-recognition/ixa-pipe-nerc-1.6.1-exec.jar tag -m ./named-entity-recognition/nl-6-class-clusters-sonar.bin -l nl > "$fn-ner.naf"

# # Start dbpedia-spotlight server
# PORT_OCCUPIED=$(netstat -lpn | grep 2060)
# if [ $? -ne 0 ]; then
#     echo "Starting dbpedia-spotlight server"
#     nohup sh ./dbpedia-spotlight/start-dbpedia-spotlight.sh > dbpedia-spotlight.log 2>&1 &
# fi

# # Run IXA Named Entity Disambiguation
# cat "$fn-ner.naf" | java -jar ./ixa-pipe-ned/target/ixa-pipe-ned-1.1.6.jar -p 2060 > "$fn-ned.naf"

# # # # Run DBpedia Named Entity Recognition & Disambiguation
# # # cat "$fn-pos.naf" | python2 dbpedia_ner.py > "$fn-ned.naf"

# # Run Word Sense Disambiguation
# cat "$fn-ned.naf" | python2 ./svm_wsd/dsc_wsd_tagger.py --naf -ref odwnSY> "$fn-wsd.naf"

# # # Run Heideltime 

# # Run PredicateMatrix inserter
# cat "$fn-wsd.naf" | java -Xmx1812m -cp "./OntoTagger/lib/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.KafPredicateMatrixTagger --mappings "fn;mcr;ili;eso" --key odwn-eq --version 1.2 --predicate-matrix "./vua-resources/PredicateMatrix.v1.3.txt.role.odwn.gz" --grammatical-words "./vua-resources/Grammatical-words.nl" > "$fn-pmat.naf"

# # Run SONAR's Semantic Role Labeller
# cat "$fn-pmat.naf" | ./run.sh > "$fn-srl.naf"

# # Run Framenet classifier
# cat "$fn-srl.naf" | java -Xmx1812m -cp "./OntoTagger/lib/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.SrlFrameNetTagger --frame-ns "fn:" --role-ns "fn-role:;pb-role:;fn-pb-role:;eso-role:" --ili-ns "mcr:ili" --sense-conf 0.05 --frame-conf 30 > "$fn-frm.naf"

# # # Run Nominal Event recognizer
# cat "$fn-frm.naf" | java -Xmx812m -cp "./OntoTagger/lib/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.NominalEventCoreference --framenet-lu "./vua-resources/nl-luIndex.xml" > "$fn-events.naf"

# # Run 
# cat "$fn-events.naf" | python2 ./vua-srl-dutch-nominal-events/vua-srl-dutch-additional-roles.py > "$fn-evtad.naf"

# Report complete
echo "Done."