//https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_S2_SR#bands
var grid = ee.FeatureCollection("projects/ee-alinakraemer/assets/gridwgs84");
var list= grid.toList(101);


// function for masking of low quality pixels according to the SCL band
function maskS2clouds(image) {
  var scl = image.select('SCL');
  var wantedPixels = scl.gt(3).and(scl.lt(7)).or(scl.eq(1)).or(scl.eq(2));
  return image.updateMask(wantedPixels);
}

// Map the function over the time period of data and take the median.

for (var i = 1; i < 101; i++){
  var aoi = ee.Feature(list.get(i)).geometry();
  var aoi_id = ee.Feature(list.get(i)).get('id');

var collection = ee.ImageCollection('COPERNICUS/S2_SR')
    .filterBounds(aoi)
    .filterDate('2018-05-01', '2018-09-30')
    .map(maskS2clouds)
    .select('B2', 'B3', 'B4', 'B8');

var composite = collection.median();


  
  
  Export.image.toDrive({
  image: composite,
  description: 'sentinel',
  scale: 10,
  region: aoi
});

  
  
}

