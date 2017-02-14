# Configuration
* [Simple](#simple)
* [Extended](#extended)

## <a name="simple"></a>Simple
This example ...

```php
use ARP\SolrClient2\SolrClient;  
$client = new SolrClient();
```
... is equal to ...

```php
use ARP\SolrClient2\SolrClient; 

$client = new SolrClient(array(
    'host' => 'localhost',
    'port' => 8080,
    'path' => 'solr',
    'version' => 4
));
```
... or ...

```php
use ARP\SolrClient2\SolrClient; 

$client = new SolrClient();
$client ->host('localhost')
        ->port(8080)
        ->path('solr')
        ->version(4);
```
... or ...
```php
use ARP\SolrClient2\SolrClient; 

... or

```php
use ARP\SolrClient2\SolrClient; 

$client = new SolrClient("http:\\localhost:8080\solr");
```

## <a name="extended"></a>Extended
```php
use ARP\SolrClient2\SolrClient; 

$client = new SolrClient(array(
    'port' => 80,
    'core' => 'core0',
    'params' => array(
        'fq' => 'category:user'
    )
));
```
... <b>is equal to</b> ...
```php
use ARP\SolrClient2\SolrClient; 

$client ->port(80)
        ->fromCore('core0')
        ->params(array(
            'fq' => 'category:user'
        ));
```
