<?php

//namespace Klarschiff;

require_once dirname(__FILE__) . "/conf/config.php";
require_once dirname(__FILE__) . "/Search.php";

$search = new Search($solrConf);

$result = $search->find(
  isset($_GET["searchtext"]) ? $_GET["searchtext"] : "*"
);

$backend = isset($_GET["backend"]) && strtolower($_GET["backend"]) === 'true';

$resultJson = array("result" => "", "array" => array());

function generateHtml($href, $name, $type, $title, $backend) {
  $class = $backend ? "resultElement" : "result-element";
  return '<div class="' . $class . '">&nbsp;<a href="' . $href . '" name="' . $name .
    '" class="gotoBBOX">' . $title . '</a><span>' . $type . '</span></div>';
}

function generateJson($bbox_array, $type, $title) {
  return array(
    "label" => $title,
    "bbox" => $bbox_array
  );
}

foreach ($result->documents as $doc) {
  $data = json_decode($doc->json, true);
  $type = strtolower($data["type"]);

  $bbox_array = array();
  if (substr($data['geom'], 0, 3) == "BOX") {
    foreach (explode(",", substr($data['geom'], 4, -1)) AS $i) {
      foreach (explode(" ", $i) AS $j) {
        $bbox_array[] = $j;
      }
    }
  }

  if ($type === "ort") {
    $title = $data['ort_name'];
  } elseif ($type === "ortsteil") {
    $title = $data['stadtteil_name'];
  } elseif ($type === "straße") {
    $title = $data['strasse_name'] . " " . $data["zusatz"];;
  } elseif ($type === "adresse") {
    $title = $data["strasse"] . " " . $data["hausnummer"] . $data["hausnummerzusatz"] . " " . $data["zusatz"];
  } elseif ($type === "poi") {
    $title = $data['poi_titel'];
  } else {
    $title = "";
  }

  $bbox_string = implode(",", $bbox_array);
  if ($backend) {
    $href = 'javascript:map.zoomToExtent(new OpenLayers.Bounds(' . $bbox_string . '));';
  } else {
    $href = URL . '?BBOX=' . $bbox_string;
  }

  $resultJson["result"] .= generateHtml($href, $bbox_string, $data["type"], $title, $backend);
  $resultJson["array"][] = generateJson($bbox_array, $data["type"], $title);
}

header('Content-Type: application/json');
echo json_encode($resultJson);

?>
