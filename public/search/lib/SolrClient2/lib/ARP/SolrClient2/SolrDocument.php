<?php
//namespace ARP\SolrClient2;

/**
 * SolrDocument
 * @author A.R.Pour
 */
class SolrDocument
{
    private $_doc;

    public function __construct()
    {
        $this->_doc['commitWithin'] = 0;
        /*
        Not implemented
            allowDups
            overwritePending
            overwriteCommitted
        */
    }

    /**
     * Document boost
     * @param float $boost
     */
    public function setBoost($boost)
    {
        $this->_doc['boost'] = (float)$boost;
    }

    /**
     * Field boost
     * @param string $field
     * @param float $boost
     */
    public function setFieldBoost($field, $boost)
    {
        if (isset($this->_doc['doc'][$field])) {
            if (is_array($this->_doc['doc'][$field]) && isset($this->_doc['doc'][$field]['boost'])) {
                $this->_doc['doc'][$field]['boost'] = (float)$boost;
            } else {
                $this->_doc['doc'][$field] = array(
                    'boost' => (float)$boost,
                    'value' => $this->_doc['doc'][$field]
                );
            }
        }
    }

    /**
     * Add field
     * @param string  $field field
     * @param string  $value value
     * @param float $boost field boost
     */
    public function add($field, $value, $boost = false)
    {
        if ($boost) {
            $this->_doc['doc'][$field] = array(
                'boost' => (float)$boost,
                'value' => $value
            );
        } else {
            $this->_doc['doc'][$field] = $value;
        }
    }

    /**
     * Solr json update string
     * @return string json update string
     */
    public function toJson()
    {
        return json_encode(array(
            'add' => $this->_doc
        ));
    }

    // TODO: parseDate in eine andere Datei verlagern.
    public function solrDate($date = null)
    {
        $return = '';
        $dateObj = null;

        if (is_string($date) && preg_match('/[\d]{4}\-[\d]{2}\-[\d]{2}/', $date)) {
            $dateObj = new DateTime($date);
        } else {
            $dateObj = new DateTime();
        }

        if (is_object($dateObj)) {
            $return = $dateObj->format('Y-m-d\TH:i:s\Z');
        }

        return $return;
    }

    public function __get($field)
    {
        if (isset($this->_doc['doc'][$field])) {
            if (is_array($this->_doc['doc'][$field]) && isset($this->_doc['doc'][$field]['value'])) {
                return $this->_doc['doc'][$field]['value'];
            }
            return $this->_doc['doc'][$field];
        }
        return null;
    }

    public function __set($field, $value)
    {
        $this->add($field, $value);
    }
}
