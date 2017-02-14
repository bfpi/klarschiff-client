<?php

#namespace Klarschiff;

require_once dirname(__FILE__) . "/lib/SolrClient2/lib/ARP/SolrClient2/SolrClient.php";
require_once dirname(__FILE__) . "/lib/ColognePhonetic.php";
require_once dirname(__FILE__) . "/conf/config.php";

#use ARP\SolrClient2\SolrClient;

/**
 * Class Search
 * @package Klarschiff
 * @author A. R. Pour
 */
class Search
{
    protected $solr = null;
    protected $phonetic = null;
    protected $id = 0;

    /**
     * @param array $solrConf
     */
    public function __construct(array $solrConf)
    {
        $this->solr     = new SolrClient($solrConf);
        $this->phonetic = Text_ColognePhonetic::singleton();
    }

    /**
     * Search
     * @param $string
     * @return Object
     */
    public function find($string)
    {
        $array = $this->tokenize($string);
        $query = $array['query'];
        if(defined('ORT')){
            $ortArr = $this->tokenize(ORT);
            $query = $ortArr['query'] . " AND " . $query;
        }
        return $this->solr->exec($query);
    }

    /**
     * Truncates the index.
     */
    public function openIndex()
    {
        $this->solr->deleteAll();
        $this->solr->commit();
    }

    /**
     * Add or update a document in the index.
     * @param $string
     * @param array $data
     */
    public function updateIndex($string, array $data)
    {
        $array = $this->tokenize($string);

        $doc       = $this->solr->newDocument();
        $doc->id   = ++$this->id;
        $doc->text = trim($array['terms']);
        $doc->json = json_encode($data);

        $this->solr->appendDocument($doc);
    }

    /**
     * Commit all documents into the index and optimize.
     */
    public function closeIndex()
    {
        $this->solr->commit();
        $this->solr->optimize();
    }

    /**
     * Create tokens from string.
     * @param $string
     * @return array
     */
    public function tokenize($string)
    {
        $terms = "";
        $query = "";

        // Tokenize
        $array = array_unique(
            array_filter(
                preg_split("/[^a-z0-9äöüÄÖÜßé]/i", strtolower($string))
            )
        );

        // Prepare street
        $tmp = array();

        foreach ($array as $token) {
            // Ignore street string.
            if (in_array($token, array('str', 'straße', 'strasse'))) {
                continue;
            }

            // Cut street string at the end of the file.
            $term = preg_replace("/strasse$|straße$|str$/i", "", $token);

            // House number or house number addition
            if (preg_match("/^[\d]+$/", $term) || strlen($term) <= 2) {
                $tmp[]  = $term;
                $terms .= " $term";
                $query .= " $term^2.5";
                continue;
            }

            // Normal word
            $phon = $this->phonetic->encode($term);
            $tmp[] = $term;
            $terms .= " $term $phon";
            $query .= " ($term^31.0 OR $term*^30.5 OR *$term*^30.0 OR $phon^1.5 OR $phon*^1.0 OR *$phon*^0.5)";

            // Street
            if ($term !== $token) {
                $tmp[]  = "str";
                $terms .= " str";
                $query .= " str^2.5";
            }
        }

        $array = $tmp;

        unset($tmp);

        return array(
            'array' => $array,
            'query' => trim($query),
            'terms' => trim($terms),
        );
    }
}
