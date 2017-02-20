# SPARQL endpoint simple cache 
This sets a simple cache for a SPARQL endpoint.

Caching SPARQL request can greatly improve the respons of the SPARQL endpoint. 
[Virtuoso](https://www.mail-archive.com/virtuoso-users@lists.sourceforge.net/msg07242.html) is for instance applying only caching internal structures used in the calculation of the respons. It does not implement a query cache. 

However, SPARQL endpoint caching comes with a challenge. Since SPARQL queries can create a GET HTTP request larger than accepted by most (proxy) services, many of the applications use POST to get around the limitation even if the data is readonly and fully cacheable. Therefore standard url proxy caching is not effective. This proxy cache is a special instance suited for READONLY sparql endpoints.

It is build upon Nginx because Apache 2.4 does not allow to specify caching POST http requests.

## Deployment structure

The service is organized as follows:

@build-time
* /config  : the configuration files

@runtime
* /logs    : the logs


## Architectural embedding
The service connects to other services, which should be declared as accessible hosts:

* sparql-endpoint-service : SPARQL endpoint

The service URLs are given by the following environment variables

| Environment variable | default value |
| -------------------- | ------------- |
| ENV_SPARQL_ENDPOINT_SERVICE_URL    | http://sparql-endpoint-service:8890/sparql |

## Configuration

| Environment variable | default value |
| -------------------- | ------------- |
| ENV_SERVICE_URL | sparql.data.vlaanderen.be|
| ENV_SUCCESS_REQUEST_CACHE_DURATION | 60m |
| ENV_FAILED_REQUEST_CACHE_DURATION | 1m |

## Execution
A typical start in production setting will be

```
docker run -d -p 80:80 
    --add-host sparql-endpoint-service:<ip/hostname>
    -e ENV_FAILED_REQUEST_CACHE_DURATION=2m
    --name=scache
    -v /persistentstorage/logs/:/logs
    bertvannuffelen/simplesparqlcache
```

Note the public exposure of the logs on persistent storage. It is a good practice to ensure that the logs are stored on
a safe location. If the service has to change, the logs are kept for future problem resolution.

# Design decisions

## sparql endpoint
This proxy activates a sparql-endpoint at the url $ENV_URI_DOMAIN/sparql. This sparql interface has a web interface and a machine readable interface.
Via content negotation the machine readable interface is reachable. The Accept header is one of the following values defined according to W3C:

| ACCEPT header | description format |
| -------------------- | ------------- |
|application/sparql-results+json| [https://www.w3.org/TR/sparql11-results-json/] |
|application/sparql-results+xml | [https://www.w3.org/TR/rdf-sparql-XMLres/] |
|text/csv                       | [https://www.w3.org/TR/sparql11-results-csv-tsv/] |
|text/tab-separated-values      | [https://www.w3.org/TR/sparql11-results-csv-tsv/] |


## content negotation
This proxy activates content negotation. The table below describes the implemented accept headers.


| document format | corresponding accept-header | corresponding extension |
| --------------- | --------------------------- | ----------------------- |
| HTML | text/html | .html|
| RDF  | application/rdf+xml | .rdf|
| TURTLE | text/turtle | .ttl|
| NTRIPLES | text/ntriples | .nt|
| jsonld | application/ld+json| .jsonld|
| json | application/json| .json|

