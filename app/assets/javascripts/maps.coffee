# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

KS.projection = ->
  if typeof proj4 is 'function'
    proj4.defs 'EPSG:25833', '+proj=utm +zone=33 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs'
    proj4.defs 'urn:ogc:def:crs:EPSG::25833', proj4.defs('EPSG:25833')
    projection_25833 = ol.proj.get 'EPSG:25833'
    projection_25833.setExtent [304094, 5993070, 323567, 6014340]
    return projection_25833
  else
    console.log 'Proj4J ist nicht geladen!'

class KS.Map
  constructor: (@projection = KS.projection()) ->
    @olMap = new ol.Map
      target: 'ol-map'
      view: new ol.View
        projection: @projection
        center: [313356.88711652, 6002555.7959791]
        zoom: 2
        maxZoom: 10

    KS.layers = new KS.Layers(@olMap)


  addControls = (map) ->
    map.addControl new ol.control.MousePosition
      coordinateFormat: ol.coordinate.createStringXY(4)
      projection: @projection
      undefinedHTML: '?,?'

    map.addControl new ol.control.MousePosition
      className: 'll-mouse-position'
      target: document.getElementById('ol-overlaycontainer-stopevent')
      coordinateFormat: ol.coordinate.createStringXY(6)
      projection: 'EPSG:4326'
      undefinedHTML: '?,?'

    map.addControl new ol.control.ScaleLine


class KS.Layers
  constructor: (map) ->
    @active = 0
    @layers = [
      new ol.layer.Tile
        source: new ol.source.TileWMS
          url: "http:\/\/geo.sv.rostock.de\/geodienste\/stadtplan\/ows?"
          params:
            "LAYERS": "stadtplan"
            "FORMAT": "image/png"
          attributions: [
            new ol.Attribution
              html: "Kartenbild © Hansestadt Rostock (<a href=\"http://creativecommons.org/licenses/by/3.0/deed.de\" target=\"_blank\" style=\"color:#006CB7;text-decoration:none;\">CC BY 3.0</a>) | Kartendaten © <a href=\"http://www.openstreetmap.org/\" target=\"_blank\" style=\"color:#006CB7;text-decoration:none;\">OpenStreetMap</a> (<a href=\"http://opendatacommons.org/licenses/odbl/\" target=\"_blank\" style=\"color:#006CB7;text-decoration:none;\">ODbL</a>) und <a href=\"https://geo.sv.rostock.de/uvgb.html\" target=\"_blank\" style=\"color:#006CB7;text-decoration:none;\">uVGB-MV</a>"
          ]
        visible: true,
      new ol.layer.Tile
        source: new ol.source.TileWMS
          url: "http:\/\/geo.sv.rostock.de\/geodienste\/luftbild\/ows?"
          params:
            "LAYERS": "luftbild"
            "FORMAT": "image/png"
          attributions: [
            new ol.Attribution
              html: "© GeoBasis-DE/M-V"
          ]
        visible: false
    ]
    map.addLayer layer for layer in @layers


  toggle: ->
    @active = (@active + 1) % @layers.length
    layer.setVisible(i == @active) for layer, i in @layers

$ ->
  KS.olMap = new KS.Map
