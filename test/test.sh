#!/bin/bash

#TARGET=http://data.vlaanderen.be
TARGET=http://localhost

echo "test 1"
curl --data-urlencode query=' select distinct ?type where { ?thing a ?type } limit 1 ' $TARGET
echo "----------"

echo "test 2"
curl --verbose --data-urlencode query=' PREFIX adres: <http://data.vlaanderen.be/ns/adres#> PREFIX mu: <http://mu.semte.ch/vocabularies/core/> SELECT ((COUNT (DISTINCT ?uuid)) AS ?count) WHERE { GRAPH <http://data.vlaanderen.be/id/dataset/CRAB> { ?s mu:uuid ?uuid; a adres:Adres.  } } '  $TARGET

echo "----------"

echo "test 3 - header x-request-id"
echo "should be visible in the logs"
curl --verbose -H "x-request-id: 123123" --data-urlencode query=' select distinct ?type where { ?thing a ?type } limit 1 ' $TARGET
echo "----------"


echo "test 4 - header x_request_id"
echo "NOT visible in the logs"
curl --verbose -H "x_request_id: 123123" --data-urlencode query=' select distinct ?type where { ?thing a ?type } limit 1 ' $TARGET
echo "----------"
