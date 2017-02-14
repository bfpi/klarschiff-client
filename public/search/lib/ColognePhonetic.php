<?php
/**
 * Copyright 2008 magdev <info@magdev.de>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *    * Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    * Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    * The names of the authors may not be used to endorse or promote products
 *      derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * @category  Text
 * @package   Text_ColognePhonetic
 * @author    Marco Graetsch <info@magdev.de>
 * @copyright 2008 magdev
 * @version   Release: @package_version@
 * @link      http://pear.magdev.de/package/Text_ColognePhonetic
 * @license   http://opensource.org/licenses/bsd-license.php New BSD License
 */


/**
 * Implementation of the 'Koelner Phonetik' algorithm
 *
 * @category  Text
 * @package   Text_ColognePhonetic
 * @author    Marco Graetsch <info@magdev.de>
 * @link      http://pear.magdev.de/package/Text_ColognePhonetic
 * @link      http://de.wikipedia.org/wiki/K%C3%B6lner_Phonetik
 * @license   http://opensource.org/licenses/bsd-license.php New BSD License
 * @example   example.php
 */
class Text_ColognePhonetic
{
    /**
     * Store the singleton instance
     * @var Text_ColognePhonetic
     */
    private static $_inst = null;
    
    /**
     * Store the rules for conversion
     * @var array
     */
    private $_rules = array(
        array('/[aejiouyäöüÄÖÜ]/i', '0'),
        array('/[b]/i', '1'),
        array('/[p][^h]/i', '1'),
        array('/[dt]([csz])/i', '8$1'),
        array('/[dt](?<=[^csz])/i', '2$1'),
        array('/[fvw]/i', '3'),
        array('/p([h])/i', '3$1'),
        array('/[gkq]/i', '4'),
        array('/^c([ahkloqrux])/i', '4$1'),
        array('/([^sz])c([ahkoqux])/i', '${1}4$2'),
        array('/([^ckq]??)x/i', '${1}48'),
        array('/[l]/i', '5'),
        array('/[mn]/i', '6'),
        array('/[r]/i', '7'),
        array('/([sz])c/i', '${1}8'),
        array('/[szß]/i', '8'),
        array('/^c([^ahkloqrux]??)/i', '8$1'),
        array('/([ckq])x/i', '${1}8'),
        array('/[h]/i', ''),
    );
    
    
    /**
     * Get a singleton-instance of Text_ColognePhonetic
     *
     * @return  Text_ColognePhonetic
     */
    public static function singleton()
    {
        if (is_null(self::$_inst)) {
            self::$_inst = new Text_ColognePhonetic();
        }
        return self::$_inst;
    }
    
    
    
    /**
     * Compare two strings
     *
     * @param   string  $string1
     * @param   string  $string2
     * @return  string
     */
    public static function staticCompare($string1, $string2)
    {
        return self::singleton()->compare($string1, $string2);
    }
    
    
    /**
     * Encode a string
     *
     * @param   string  $string    The string to encode
     * @return  string
     */
    public static function staticEncode($string)
    {
        return self::singleton()->encode($string);
    }
    
    
    
    /**
     * Compare two strings
     *
     * @param   string  $string1
     * @param   string  $string2
     * @return  string
     */
    public function compare($string1, $string2)
    {
        if ($string1 == $string2 || strtolower($string1) === strtolower($string2)) {
            return true;
        }
        if ($this->encode($string1) === $this->encode($string2)) {
            return true;
        }
        return false;
    }
    
    
    /**
     * Encode a string
     *
     * @param   string  $string    The string to encode
     * @return  string
     */
    public function encode($string)
    {
        // First pass: Strip non-alpha
        $string = preg_replace('/[^a-zöäüÖÄÜß]/i', '', $string);
        // Second pass: Apply conversion-rules
        $string = $this->_applyRules($string);
        // Third pass: Strip double occurrences
        $string = $this->_stripDoubles($string);
        // Fourth pass: Strip all zeros except a leading one
        $string = $this->_stripZeros($string);
        
        return $string;
    }
    
    
    
    /**
     * Apply the ruleset for conversion
     *
     * @param   string  $string
     * @return  string
     */
    private function _applyRules($string)
    {
        foreach ($this->_rules as $rule) {
            $string = preg_replace($rule[0], $rule[1], $string);
        }
        return $string;
    }
    
    
    /**
     * Strip double occurrences of numbers
     *
     * @param   string  $string
     * @return  string
     */
    private function _stripDoubles($string)
    {
        $i = 0;
        while ($i <= 9) {
            $string = preg_replace('/['.$i.']{2,}/', $i, $string);
            $i++;
        }
        return $string;
    }
    
    
    /**
     * Strip all zeros except a leading one
     *
     * @param   string  $string
     * @return  string
     */
    private function _stripZeros($string)
    {
        $first = '';
        if ($string[0] === '0') {
            $first = '0';
            $string = substr($string, 1);
        }
        return $first.str_replace('0', '', $string);
    }
    
    
    /**
     * Protect the constructor
     */
    protected function __construct() {}
}
?>