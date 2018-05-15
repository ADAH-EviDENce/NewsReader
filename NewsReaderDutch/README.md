# NewsReaderDutch

In this folder you can find a dockerfile to install all Newsreader modules -including their dependencies- for the natural language processing pipeline [NewsReader](http://www.newsreader-project.eu/) in Dutch.

# Build

The image is available from Docker Hub and can be obtained by pulling:
```shell
docker pull evidence/newsreaderdutch
```

If you would like to make change and build the image yourself, call:
```shell
docker image build -t newsreaderdutch NewsReaderDutch/
```
from within the root of the repository.

# Usage

The Docker container can be run directly on your text files by calling:
```shell
docker run -v /workspace/:/work/ newsreaderdutch /work/file.txt
```
where `/workspace/` is your local directory containing files that need to be processed and `file.txt` is the document that you would like to get annotated. The output will have the same filename, but with a `*.naf` extension. Currently, the pipeline writes the output of each module separately as well.

# Contact

Questions, comments and bugs can be submitted to the [issues tracker](https://github.com/ADAH-EviDENce/NewsReader/issues).
