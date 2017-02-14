<?php
//namespace ARP\SolrClient2;

require_once dirname(__FILE__) . '/SolrDocument.php';
require_once dirname(__FILE__) . '/CurlBrowser.php';

/**
 * SolrCore
 * @author A.R.Pour
 */
class SolrCore extends CurlBrowser
{
    protected $host = null;
    protected $port = null;
    protected $path = null;
    protected $core = null;
    protected $version = null;
    protected $params = array();
    protected $cache;
    protected $cacheSize = 10240;
    protected $content = '';

    /**
     * Constructor.
     * @param array $options Options.
     */
    public function __construct($options)
    {
        $this->options($options);
    }

    public function options($options)
    {
        if (is_string($options)) {
            $options = parse_url($options);
            $path = array_filter(explode('/', $options['path']));
            if (count($path) === 2) {
                $options['core'] = array_pop($path);
                $options['path'] = array_pop($path);
            }
        }

        $this->host = isset($options['host']) ? $options['host'] : 'localhost';
        $this->port = isset($options['port']) ? $options['port'] : 8080;
        $this->path = isset($options['path']) ? $options['path'] : 'solr';
        $this->core = isset($options['core']) ? $options['core'] : '';
        $this->version = isset($options['version']) ? (int)$options['version'] : 4;

        $this->params = array(
            'fl'        => '*',
            'wt'        => 'json',
            'json.nl'   => 'map',
            'start'     => 0,
            'rows'      => 20,
            'q'         => '*:*'
        );

        if (isset($options['params'])) {
            $this->params = $this->mergeRecursive($this->params, $options['params']);
        }

        return $this;
    }

    public function host($host)
    {
        $this->host = $host;
        return $this;
    }

    public function port($port)
    {
        $this->port = $port;
        return $this;
    }

    public function path($path)
    {
        $this->path = $path;
        return $this;
    }

    public function core($core)
    {
        $this->core = $core;
        return $this;
    }

    /**
     * @deprecated
     * @param  string $core
     * @return SolrCore
     */
    public function fromCore($core)
    {
        trigger_error("Method 'fromCore' is deprecated use 'core' instead.", E_USER_DEPRECATED);
        return $this->core($core);
    }

    public function version($version)
    {
        $this->version = $version;
        return $this;
    }

    public function params(array $params)
    {
        $this->params = $params;
        return $this;
    }

    public function cacheSize($size)
    {
        $this->cacheSize = (int)$size;
        return $this;
    }

    public function newDocument()
    {
        return new SolrDocument();
    }

    public function addDocument(SolrDocument $document)
    {
        $this->jsonUpdate($document->toJson());
        return $this;
    }

    public function addDocuments($documents)
    {
        $json = '';

        foreach ($documents as $document) {
            $json .= substr($document->toJson(), 1, -1) . ',';
        }

        $this->jsonUpdate('{' . substr($json, 0, -1) . '}');
        return $this;
    }

    public function appendDocument(SolrDocument $document)
    {
        $this->cache .= substr($document->toJson(), 1, -1) . ',';
        if (strlen($this->cache) >= $this->cacheSize) {
            return $this->commitCachedDocuments();
        }
        return $this;
    }

    public function deleteByQuery($query)
    {
        $this->jsonUpdate('{"delete": { "query":"' . $query . '" }}');
        return $this;
    }

    public function deleteAll()
    {
        $this->deleteByQuery('*:*');
        return $this;
    }

    public function commit()
    {
        $this->commitCachedDocuments();
        $this->jsonUpdate('{"commit": {}}');
        return $this;
    }

    public function optimize($waitSearcher = false)
    {
        $this->jsonUpdate('{"optimize": {"waitSearcher":' . $waitSearcher ? 'true' : 'false' . '}}', false);
        return $this;
    }

    public function queryInfo()
    {
        return urldecode($this->content) .
            '<pre>' . print_r($this->params, true) . '</pre>';
    }

    protected function solrSelect($params)
    {
        $this->content = http_build_query($params);
        $this->content = preg_replace('/%5B([\d]{1,2})%5D=/', '=', $this->content);

        $response = $this->httpPost(
            $this->generateURL('select'),
            array('Content-type: application/x-www-form-urlencoded'),
            $this->content
        );

        if ($response->status !== 200) {
            throw new RuntimeException("\nStatus: $response->status\nContent: $response->content");
        }

        return $response;
    }

    protected function mergeRecursive($arr1, $arr2)
    {
        foreach (array_keys($arr2) as $key) {
            if (isset($arr1[$key]) && is_array($arr1[$key]) && is_array($arr2[$key])) {
                $arr1[$key] = $this->mergeRecursive($arr1[$key], $arr2[$key]);
            } else {
                $arr1[$key] = $arr2[$key];
            }
        }
        return $arr1;
    }

    protected function appendToFilter($string, $cached = true)
    {
        if (!$cached) {
            $string = '{!cache=false}' . $string;
        }

        if (!isset($this->params['fq'])) {
            $this->params['fq'] = array($string);
        } else {
            $this->params['fq'][] = $string;
        }
    }

    private function generateURL($path = '')
    {
        return 'http://'
            . $this->host
            . ($this->port === null ? '' : ':' . $this->port)
            . ($this->path === null ? '' : '/' . $this->path)
            . ($this->core === null ? '' : '/' . $this->core)
            . ($path == '' ? '' : '/' . $path);
    }

    private function jsonUpdate($content, $checkStatus = true)
    {
        if ($this->version == 4) {
            $url = $this->generateURL('update');
        } else {
            $url = $this->generateURL('update/json');
        }

        $response = $this->httpPost(
            $url,
            array('Content-type: application/json'),
            $content
        );

        if ($checkStatus && $response->status !== 200) {
            throw new RuntimeException("\nStatus: $response->status\nContent: $response->content");
        }

        return $response;
    }

    private function commitCachedDocuments()
    {
        if (strlen($this->cache) > 1) {
            $response = $this->jsonUpdate('{' . substr($this->cache, 0, -1) . '}');
            $this->cache = '';
            return $response;
        }
        return null;
    }
}
