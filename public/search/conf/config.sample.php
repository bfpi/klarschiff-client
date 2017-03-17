<?php
# POSTGRESQL DATABASE
define("HOST","localhost");
define("PORT",5432);
define("NAME","standortsuche");
define("USER","standortsuche");
define("PASS","standortsuche");
define("SCHEMA","public");

# ORT
define("URL", "/map");
# DEFAULT ORT - zur Begrenzung der Suche
# define("ORT","Rostock");

# SOLR
$solrConf = array(
    'host' => 'localhost',
    'port' => 8080,
    'path' => 'solr',
    'core' => 'klarschiff',
    'version' => 4,
    'params' => array(
      'rows' => 5
    )
);
