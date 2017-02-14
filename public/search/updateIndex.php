<?php

//namespace Klarschiff;

require_once dirname(__FILE__) . "/conf/config.php";
require_once dirname(__FILE__) . "/Search.php";

$search = new Search($solrConf);
$search->openIndex();

echo "<br/>\nclear index.\n";
$conn = pg_connect("host=" . HOST . " port=" . PORT . " dbname=" . NAME . " user=" . USER . " password=" . PASS . "");
if (!$conn) die("Error: pg_connect!");
echo "<br/>connect ok";

/* * *********************************************************************
 * O R T S T E I L    S E A R C H
 * ********************************************************************* */
$sql = "SELECT ot.id AS id,ot.stadtteil_name AS stadtteil_name,box2d(ot.geom) AS bbox"
  . ",st_dimension(ot.geom) AS dimension FROM " . SCHEMA . ".standortsuche ot WHERE ot.stadtteil_name IS NOT NULL;";
$result = pg_query($conn, $sql);
$num = 0;
while ($row = pg_fetch_assoc($result)) {
  if ($row["bbox"] === null) {
    continue;
  }
  if ($row["dimension"] == 0 AND strpos($row["bbox"], "BOX") === 0) {
    $tmp = split(",", substr($row["bbox"], 4, -1));
    $row["geom"] = "BOX(" . $tmp[0] . "," . $tmp[0] . ")";
  } else {
    $row["geom"] = $row["bbox"];
  }
  $search->updateIndex(
    $row["stadtteil_name"],
    array(
      "type" => "Ortsteil",
      "stadtteil_name" => $row["stadtteil_name"],
      "geom" => $row["geom"]
    )
  );
  $num++;
}

echo "<br/><br/>Tables :" . SCHEMA . "standortsuche";
echo "<br/>Rows all :" . pg_num_rows($result);
echo "<br/>Rows accepted :" . $num;
echo "<br/>Last error : " . pg_last_error();
/* * *********************************************************************
 * S T R A S S E    S E A R C H
 * ********************************************************************* */
$sql = "SELECT s.id, s.strasse_name, s.zusatz"
  . ",box2d(s.geom) AS bbox, st_dimension(s.geom) AS dimension FROM " . SCHEMA . ".standortsuche s WHERE s.strasse_name IS NOT NULL";
$result = pg_query($conn, $sql);
$num = 0;
while ($row = pg_fetch_assoc($result)) {
  if ($row["bbox"] === null) {
    continue;
  }
  if ($row["dimension"] == 0 AND strpos($row["bbox"], "BOX") === 0) {
    $tmp = split(",", substr($row["bbox"], 4, -1));
    $row["geom"] = "BOX(" . $tmp[0] . "," . $tmp[0] . ")";
  } else {
    $row["geom"] = $row["bbox"];
  }
  $search->updateIndex(
    $row["strasse_name"],
    array(
      "type" => "Straße",
      "strasse_name" => $row["strasse_name"],
      "zusatz" => $row["zusatz"],
      "geom" => $row["geom"]
    )
  );
  $num++;
}

echo "<br/><br/>Tables :" . SCHEMA . ".standortsuche";
echo "<br/>Rows all :" . pg_num_rows($result);
echo "<br/>Rows accepted :" . $num;
echo "<br/>Last error : " . pg_last_error();
/* * *********************************************************************
 * A D R E S S E    S E A R C H
 * ********************************************************************* */
$sql = "SELECT a.id, a.strasse, a.hausnummer, a.hausnummerzusatz, a.zusatz"
  . ",box2d(a.geom) AS bbox, st_dimension(a.geom) AS dimension"
  . " FROM " . SCHEMA . ".standortsuche a WHERE a.hausnummer IS NOT NULL";
$result = pg_query($conn, $sql);
$num = 0;
while ($row = pg_fetch_assoc($result)) {
  if ($row["bbox"] === null) {
    continue;
  }
  if ($row["dimension"] == 0 AND strpos($row["bbox"], "BOX") === 0) {
    $tmp = split(",", substr($row["bbox"], 4, -1));
    $row["geom"] = "BOX(" . $tmp[0] . "," . $tmp[0] . ")";
  } else {
    $row["geom"] = $row["bbox"];
  }
  $search->updateIndex(
    $row["strasse"] . " " . $row["hausnummer"] . $row["hausnummerzusatz"],
    array(
      "type" => "Adresse",
      "strasse" => $row["strasse"],
      "hausnummer" => $row["hausnummer"],
      "hausnummerzusatz" => $row["hausnummerzusatz"],
      "zusatz" => $row["zusatz"],
      "geom" => $row["geom"]
    )
  );
  $num++;
}

echo "<br/><br/>Tables :" . SCHEMA . ".standortsuche";
echo "<br/>Rows all :" . pg_num_rows($result);
echo "<br/>Rows accepted :" . $num;
echo "<br/>Last error : " . pg_last_error();


$search->closeIndex();
