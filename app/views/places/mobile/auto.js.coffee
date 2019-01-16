$('#places_results').html('<%= j render("/places/mobile/results") %>');
$('a[data-transform=true]').each ->
  link = $(this).attr('href')
  match = link.match(/[0-9]+\.[0-9]+/gi)
  transformedBbox = ol.proj.transformExtent([
    match[0]
    match[1]
    match[2]
    match[3]
  ], KS.projectionWGS84, KS.projection())
  link = link.replace(match[0], transformedBbox[0])
  link = link.replace(match[1], transformedBbox[1])
  link = link.replace(match[2], transformedBbox[2])
  link = link.replace(match[3], transformedBbox[3])
  $(this).attr 'href', link
  return