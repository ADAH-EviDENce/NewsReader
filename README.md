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

The script `newsreader.sh` is a work-in-progress bash script to run all modules sequentially. Before calling each functionality, it checks for the necessary dependencies. The bash script serves as a template for the Docker image that we aim to build. 

Once complete, the image will be uploaded to Docker Hub. Then, it is possible to process a textfile using a single command.

### Contact
Questions, comments and bugs can be submitted to the issues tracker.
