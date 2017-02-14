<?php
#namespace ARP\SolrClient2;

/**
 * Paging
 * @author A.R.Pour
 */
class Paging
{
    private $count = 0;
    private $limit = 0;
    private $offset = 0;
    private $length = 10;

    public function __construct($count, $limit, $page = null, $offset = null)
    {
        $this->count = (int)$count;
        $this->limit = (int)$limit;

        if (!is_null($page)) {
            $this->offset = (int)($page * $limit) - $limit;
        }

        elseif (!is_null($offset))
            $this->offset = (int)$offset;
    }

    public function length($length)
    {
        $this->length = (int)$length;

        return $this;
    }

    public function calculate()
    {
        $response = new stdClass();

        $response->count = $this->count;
        $response->offset = $this->offset;
        $response->pages = $this->limit > 0
            ? ceil($response->count / $this->limit)
            : 0;
        $response->currentPage = floor(($response->offset / $this->limit)) + 1;

        if ($response->pages >= 1) {
            // INDEX START
            if ($response->currentPage > ($this->length / 2)) {
                $response->startPage = $response->currentPage - floor($this->length / 2);
            } else {
                $response->startPage = 1;
            }

            // INDEX END
            if (($response->startPage + $this->length - 1) > $response->pages
                && $response->pages > ($this->length - 1)) {
                $response->endPage = ceil($response->pages);
            } else {
                $response->endPage = $response->startPage + $this->length - 1;
            }

            // END OF LIST?
            if ($response->endPage - $response->startPage < $this->length) {
                $response->startPage = $response->startPage
                    - ($this->length - ($response->endPage - $response->startPage));
            }

            if ($response->startPage < 1) {
                $response->startPage = 1;
            }

            if ($response->currentPage < $response->pages) {
                $response->nextPage = $response->currentPage + 1;
            }

            if ($response->currentPage > 1) {
                $response->prevPage = $response->currentPage - 1;
            }
        }
        return $response;
    }
}
