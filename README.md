# EviDENce - how individuals recall mass violence.

EviDENce explores new ways of analyzing and contextualizing historical sources by applying event modeling and semantic web technologies. Our project suggests a systematic and integral content analysis of ‘ego-sources’ by applying state-of-the-art entity and event modeling methods and tools, in order to explore the nature and value of ego-sources and to disclose existing collections.

## NewsReader
Basic natural language processing (NLP) of historical texts is performed by the [NewsReader](www.newsreader-project.eu/) pipeline. Among other modules, it tokenizes words, tags parts-of-speech, and finds named entities. These tags are used to extract more semantic information later on.

- The black-box folder contains links to current implementations of NewsReader, including virtual machines and Hadoop filesystem implementations. <br>
- The nlppln folder contains a modular pipeline based on the common workflow language (CWL). CWL explicitly describes input and output formats of each processing step and takes of care of individual versioning and dependencies.

## Event modeling
The goal is to extract violent events from 'ego-source' historical documents. The information extracted by NewsReader will be structured in an adapted SEM (Simple Event Model) format, which related actors, times, and locations.

## Emotion analysis
Collections of historical texts can be distilled to a smaller, more relevant corpus based on violent events. This distilled corpus can then be analyzed for its emotional content to form an idea of how individuals experienced these events.

### Contact
Questions, comments and bugs can be submitted to the issues tracker.
