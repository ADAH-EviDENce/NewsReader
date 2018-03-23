#!/usr/bin/env bash
DIR="$(pwd)/dependencies/dbpedia-spotlight"
java -jar $DIR/dbpedia-spotlight-0.7.1.jar $DIR/nl http://localhost:2060/rest
