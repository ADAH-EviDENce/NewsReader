# NewsReaderDutch
In this folder you can find a dockerfile to install all Newsreader modules -including their dependencies- for the natural language processing pipeline [NewsReader](http://www.newsreader-project.eu/) in Dutch.

## Build
This image is available through Docker Hub:
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
docker run newsreaderdutch file.txt
```
where `file.txt` is the document that you would like to get annotated.

For an interactive container (with your local workspace mounted) call:
```shell
docker run -it -v /workspace/:/work/ newsreader-dutch
```
where `/workspace/` is your local directory containing files that need to be processed.

From within the container, there is a bash script that runs the entire pipeline:
```shell
./newsreader.sh /work/file.txt
```
The output will be the same file, but with a `*-final.naf` extension. The repository contains an example textfile (`txt03.txt`) with a single sentence. Currently, the pipeline writes the output of each module separately as well.

### Contact
Questions, comments and bugs can be submitted to the [issues tracker](https://github.com/ADAH-EviDENce/NewsReader/issues).
