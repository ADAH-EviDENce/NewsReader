# NewsReader
[NewsReader](www.newsreader-project.eu/) is a natural language processing pipeline. Among others, it tags parts-of-speech, recognizes named entities and annotates entities with predicates. 

There are a number of implementations of the NewsReader pipeline:
- [POAS](http://poas.eu/): pipeline-on-a-stick.
- [newsreader-docker](https://hub.docker.com/r/vanatteveldt/newsreader-docker/): a Docker file containing the first parts of the pipeline (tok, pos, ner).
- [alpino-docker](https://hub.docker.com/r/rugcompling/alpino/): another Docker file containing the first parts of the pipeline (tok, pos, ner).
- [vmc-from-scratch](https://github.com/ixa-ehu/vmc-from-scratch): creating a VM with the Dutch version of NewsReader
- [newsreader-hadoop](https://github.com/sara-nl/newsreader-hadoop): hadoop filesystem implementation by SURFsara ([direct download](http://beehub.nl/surfsara-hadoop/public/newsreader-hadoop.tar.gz))
- [cltl/nlpp](https://github.com/cltl/nlpp): contains a script that constructs the pipeline (EN+NL) from components.

At the moment, none of these implementations succesfully build the whole pipeline for Dutch.

## Building from modules

We have imported all modules from [NewsReader](http://www.newsreader-project.eu/results/software/) under the heading "Dutch modules":

- [tokenization](https://github.com/ixa-ehu/ixa-pipe-pos): Splits text into tokens (words / punctuation symbols) ([wiki](https://en.wikipedia.org/wiki/Lexical_analysis#Tokenization)).
- [part-of-speech-tagging](https://github.com/cltl/morphosyntactic_parser_nl): tags words with grammar categories such as 'nouns' and 'verbs' ([wiki](https://en.wikipedia.org/wiki/Part-of-speech_tagging)).
- [named-entity-recognition](https://github.com/ixa-ehu/ixa-pipe-nerc): recognizes words as named entities such as 'Holland' ([wiki](https://en.wikipedia.org/wiki/Named-entity_recognition)).
- [named-entity-disambiguation](https://github.com/ixa-ehu/ixa-pipe-ned): some names refer to multiple entities, this module selects the most likely one ([wiki](https://en.wikipedia.org/wiki/Entity_linking)).
- [word-sense-disambiguation](https://github.com/cltl/svm_wsd): selects the most likely meaning of individual words ([wiki](https://en.wikipedia.org/wiki/Word-sense_disambiguation)).
- [time-expression-recognition](https://github.com/cltl/NAF-HeidelTime): recognizes that temporal expressions ([wiki](https://en.wikipedia.org/wiki/Temporal_expressions), [Heideltime](https://github.com/HeidelTime/heideltime)).
- [ontological-tagger](https://github.com/cltl/OntoTagger): tags words with [predicates](https://en.wikipedia.org/wiki/Predicate_(grammar)), i.e. subject-predicate-object, recognizes equivalent [semantic frames](https://en.wikipedia.org/wiki/FrameNet) and identifies events.
- [semantic-role-labeling](https://github.com/newsreader/vua-srl-nl): assigns roles to agents, such as 'murderer' to subject and 'murdered' to object ([wiki](https://en.wikipedia.org/wiki/Semantic_role_labeling)).
- [event-coreference](https://github.com/cltl/EventCoreference): determines that two recognized events are actually referring to the same event ([wiki](https://en.wikipedia.org/wiki/Coreference)).
- [opinion-miner](https://github.com/cltl/opinion_miner_deluxe): detects whether a statement contains an opinion.

These modules depend on the following:
- [KafNafParser](https://github.com/cltl/KafNafParserPy): a parser for [KAF/NAF](https://github.com/newsreader/NAF) files in python.
- [Alpino](http://www.let.rug.nl/vannoord/alp/Alpino/): a dependency parser for Dutch text.
- [dbpedia-spotlight](https://github.com/dbpedia-spotlight/dbpedia-spotlight): tool for annotating mentions of DBpedia resources ([more info](http://www.dbpedia-spotlight.org/)).
- [libsvm](https://www.csie.ntu.edu.tw/~cjlin/libsvm/): library of support vector machine classifiers.
- [timbl](https://languagemachines.github.io/timbl/): Tilburg Memory-Based Learner, containing classifiers for symbolic feature spaces.

We have stripped all unnecesary files (e.g. only 1 trained classification model per module) and centralized dependencies. `newsreader.sh` is a work-in-progress bash script to run all modules sequentially. Before calling each module, it checks for the necessary dependencies. The bash script serves as a template for a Docker image. Once complete, the image will be uploaded to Docker Hub. Then, it is possible to download, install and apply NewsReader to a textfile using a single Docker command.

### Contact
Questions, comments and bugs can be submitted to the [issues tracker](https://github.com/ADAH-EviDENce/NewsReader/issues).
