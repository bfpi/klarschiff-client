# Query
* [Simple](#simple)
* [Extended](#extended)

## <a name="simple"></a>Simple
This example ...
```php
$result = $client->find();
```

... is equal to ...

```php
$result = $client   ->select('*')
                    ->limit(20)
                    ->page(1)
                    ->exec('*:*');
```

## <a name="extended"></a>Extended
```php
$result = $client   ->select('*,score')
                    ->limit(10)
                    ->page(2)
                    ->where('document', 'valid')
                    ->where('user', array('superuser', 'admin'))
                    ->orderBy('name')
                    ->facet(array('category'))
                    ->find();
```