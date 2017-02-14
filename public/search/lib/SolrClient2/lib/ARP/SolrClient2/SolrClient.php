<?php
//namespace ARP\SolrClient2;

require_once dirname(__FILE__) . '/Paging.php';
require_once dirname(__FILE__) . '/SolrQuery.php';

/**
 * SolrClient
 * @author A.R.Pour
 */
class SolrClient extends SolrQuery
{
    protected $pagingLength = 10;
    protected $wordWildcard = true;
    protected $numericWildcard = false;
    protected $leftWildcard = false;
    protected $wildcardMinStrlen = 3;
    protected $searchTerms = array();
    protected $autocompleteField = '';
    protected $autocompleteLimit = 10;
    protected $autocompleteSort = 'count';
    protected $fuzzy = false;

    public function __construct($options = null)
    {
        parent::__construct($options);
    }

    public function fuzzy($fuzzy, $percent = '')
    {
        if ($fuzzy && $this->version >= 4) {
            $this->fuzzy = '~' . $percent;
        }

        return $this;
    }

    public function pagingLength($length)
    {
        $this->pagingLength = (int)$length;
        return $this;
    }

    public function wordWildcard($wordWildcard)
    {
        $this->wordWildcard = (boolean)$wordWildcard;
        return $this;
    }

    public function numericWildcard($numericWildcard)
    {
        $this->numericWildcard = (boolean)$numericWildcard;
        return $this;
    }

    public function leftWildcard($leftWildcard)
    {
        $this->leftWildcard = (boolean)$leftWildcard;
        return $this;
    }

    public function wildcardMinStrlen($wildcardMinStrlen)
    {
        $this->wildcardMinStrlen = (int)$wildcardMinStrlen;
        return $this;
    }

    public function autocomplete($field, $limit = 10, $sort = 'count')
    {
        $this->autocompleteField = trim($field);
        $this->autocompleteLimit = (int)$limit;
        $this->autocompleteSort = $sort;
        return $this;
    }

    public function find($string = '')
    {
        $this->searchTerms = array_filter(explode(' ', $string));

        if ($this->autocompleteField !== '') {
            $this->params['facet'] = 'on';

            if (!isset($this->params['facet.field'])) {
                $this->params['facet.field'] = array($this->autocompleteField);
            } else {
                $this->params['facet.field'][] = $this->autocompleteField;
            }

            $this->params['f.' . $this->autocompleteField . '.facet.sort'] = $this->autocompleteSort;
            $this->params['f.' . $this->autocompleteField . '.facet.limit'] = $this->autocompleteLimit;
            $this->params['f.' . $this->autocompleteField . '.facet.prefix'] = end($this->searchTerms);
            $this->params['f.' . $this->autocompleteField . '.facet.mincount'] = 1;
        }

        $response = $this->exec($this->buildQuery('standardQuery'));

        // PREPAIR PAGING
        if (isset($response->count) && isset($response->offset)) {
            $paging = new Paging($response->count, $this->params['rows'], null, $response->offset);

            foreach ($paging->calculate() as $key => $val) {
                $response->$key = $val;
            }
        }

        return $response;
    }

    private function buildQuery($method, $terms = null)
    {
        if (is_null($terms)) {
            $terms = $this->searchTerms;
        }

        if (count($terms) !== 0) {
            array_walk($terms, 'self::' . $method);
            return implode(' ', $terms);
        }

        return null;
    }

    private function standardQuery(&$term)
    {
        $rawTerm = trim($term);

        // NORMAL
        $term = $this->escape($rawTerm) . '^1';

        // WILDCARD
        if ((is_numeric($rawTerm) && $this->numericWildcard)
            || (!is_numeric($rawTerm) && $this->wordWildcard)
            && strlen($rawTerm) >= $this->wildcardMinStrlen) {

            $term .= ' OR '
                . ($this->leftWildcard ? '*' : '')
                . $this->escape($rawTerm)
                . '*^0.6';
        }

        // FUZZY
        if (!empty($this->fuzzy)
            && strlen($rawTerm) >= $this->wildcardMinStrlen
            && !is_numeric($rawTerm)) {

            $term .= ' OR '
                . $this->escape($rawTerm)
                . $this->fuzzy
                . '^0.3';
        }

        $term = '(' . $term . ')';
    }
}
