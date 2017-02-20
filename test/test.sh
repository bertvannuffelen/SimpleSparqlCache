curl --data-urlencode query=' select distinct ?type where { ?thing a ?type } limit 1 ' http://sparql.data.vlaanderen.be

curl --verbose --data-urlencode query=' PREFIX adres: <http://data.vlaanderen.be/ns/adres#> PREFIX mu: <http://mu.semte.ch/vocabularies/core/> SELECT ((COUNT (DISTINCT ?uuid)) AS ?count) WHERE { GRAPH <http://data.vlaanderen.be/id/dataset/CRAB> { ?s mu:uuid ?uuid; a adres:Adres.  } } '  http://sparql.data.vlaanderen.be

