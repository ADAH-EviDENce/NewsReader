# NewsReader
[NewsReader](www.newsreader-project.eu/) is a natural language processing pipeline. Among other modules, it tokenizes words, tags parts-of-speech, and finds named entities. These tags are used to extract more semantic information later on.

There are a number of implementations of the NewsReader pipeline:
- [POAS](http://poas.eu/): pipeline-on-a-stick.
- [newsreader-docker](https://hub.docker.com/r/vanatteveldt/newsreader-docker/): a Docker file containing the first parts of the pipeline (tok, pos, ner).
- [alpino-docker](https://hub.docker.com/r/rugcompling/alpino/): another Docker file containing the first parts of the pipeline (tok, pos, ner).
- [vmc-from-scratch](https://github.com/ixa-ehu/vmc-from-scratch): creating a VM with the Dutch version of NewsReader
- [newsreader-hadoop](https://github.com/sara-nl/newsreader-hadoop): hadoop implementation by SURFsara ([direct download](http://beehub.nl/surfsara-hadoop/public/newsreader-hadoop.tar.gz))
- [cltl/nlpp](https://github.com/cltl/nlpp): contains a script that constructs the pipeline (EN+NL) from components.

## CWL / nlppln
`cwl-pipeline` contains development of a pipeline in common workflow language (CWL). CWL explicitly describes input and output formats of each processing step and takes of care of individual versioning and dependencies.

CWL files can easily be generated using the python package  [nlppln](https://github.com/nlppln/nlppln).


### Contact
Questions, comments and bugs can be submitted to the issues tracker.
