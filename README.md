# NewsReader
[NewsReader](www.newsreader-project.eu/) is a natural language processing pipeline. Among others, it tags parts-of-speech, recognizes named entities and annotates entities with predicates.

There are a number of implementations of the NewsReader pipeline:
- [POAS](http://poas.eu/): pipeline-on-a-stick.
- [cltl/nlpp](https://github.com/cltl/nlpp): contains a script that constructs the pipeline (EN+NL) from components.
- [vmc-from-scratch](https://github.com/ixa-ehu/vmc-from-scratch): creating a VM with the Dutch version of NewsReader
- [newsreader-docker](https://hub.docker.com/r/vanatteveldt/newsreader-docker/): a Docker image for setting up a NewsReader server.

At the moment, none of these implementations succesfully build the whole pipeline for Dutch (see [issues tracker](https://github.com/ADAH-EviDENce/NewsReader/issues)). We have therefore decided to build the pipeline from individual modules.

## Modules

We have imported all modules from [NewsReader](http://www.newsreader-project.eu/results/software/) under the heading "Dutch modules":

- [tokenization](https://github.com/ixa-ehu/ixa-pipe-pos): Splits text into tokens (words / punctuation symbols) ([wiki](https://en.wikipedia.org/wiki/Lexical_analysis#Tokenization)).
- [part-of-speech-tagging](https://github.com/cltl/morphosyntactic_parser_nl): tags words with grammar categories such as 'nouns' and 'verbs' ([wiki](https://en.wikipedia.org/wiki/Part-of-speech_tagging)).
- [named-entity-recognition](https://github.com/ixa-ehu/ixa-pipe-nerc): recognizes words as named entities such as 'Holland' ([wiki](https://en.wikipedia.org/wiki/Named-entity_recognition)).
- [named-entity-disambiguation](https://github.com/ixa-ehu/ixa-pipe-ned): some names refer to multiple entities, this module selects the most likely one ([wiki](https://en.wikipedia.org/wiki/Entity_linking)).
- [word-sense-disambiguation](https://github.com/cltl/svm_wsd): selects the most likely meaning of individual words ([wiki](https://en.wikipedia.org/wiki/Word-sense_disambiguation)).
- [time-expression-recognition](https://github.com/ixa-ehu/ixa-heideltime): recognizes temporal expressions, such as "last week" ([wiki](https://en.wikipedia.org/wiki/Temporal_expressions), [Heideltime](https://github.com/HeidelTime/heideltime)).
- [ontological-tagger](https://github.com/cltl/OntoTagger): tags words with [predicates](https://en.wikipedia.org/wiki/Predicate_(grammar)), recognizes equivalent [semantic frames](https://en.wikipedia.org/wiki/FrameNet) and identifies events.
- [semantic-role-labeling](https://github.com/newsreader/vua-srl-nl): assigns roles to agents, such as 'murderer' and 'murdered' ([wiki](https://en.wikipedia.org/wiki/Semantic_role_labeling), [additional-roles](https://github.com/newsreader/vua-srl-dutch-nominal-events)).
- [event-coreference](https://github.com/cltl/EventCoreference): determines that two recognized events are actually referring to the same event ([wiki](https://en.wikipedia.org/wiki/Coreference)).
- [opinion-miner](https://github.com/cltl/opinion_miner_deluxe): detects whether a statement contains an opinion.

These modules depend on the following software packages:
- [KafNafParserPy](https://github.com/cltl/KafNafParserPy): a parser for [KAF/NAF](https://github.com/newsreader/NAF) files in python.
- [vua-resources](http://svmlight.joachims.org/): a package with utility functions of the [Computational Lexicology & Terminology Lab](https://github.com/newsreader/vua-srl-dutch-nominal-events/).
- [Alpino](http://www.let.rug.nl/vannoord/alp/Alpino/): a dependency parser for Dutch text.
- [dbpedia-spotlight](https://github.com/dbpedia-spotlight/dbpedia-spotlight): tool for annotating mentions of DBpedia resources ([more info](http://www.dbpedia-spotlight.org/)).
- [libsvm](https://www.csie.ntu.edu.tw/~cjlin/libsvm/): library of support vector machines.
- [svmlight](http://svmlight.joachims.org/): library of support vector machines.
- [timbl](https://languagemachines.github.io/timbl/): Tilburg Memory-Based Learner, containing classifiers for symbolic feature spaces.

## Build
The goal is to construct a lightweight, portable pipeline, which we achieve through a Docker image. This image is available from Docker Hub and can be obtained by pulling:
```shell
docker pull evidence/newsreaderdutch
```

If you would like to make change and build the image yourself, call:
```shell
docker image build -t newsreaderdutch NewsReaderDutch/
```
from within the root of the repository.

## Usage
The Docker container can be run directly on your text files by calling:
```shell
docker run -v /workspace/:/work/ newsreaderdutch /work/file.txt
```
where `/workspace/` is your local directory containing files that need to be processed and `file.txt` is the document that you would like to get annotated. The output will have the same filename, but with a `*.naf` extension. Currently, the pipeline writes the output of each module separately as well.

### Contact
Questions, comments and bugs can be submitted to the [issues tracker](https://github.com/ADAH-EviDENce/NewsReader/issues).
