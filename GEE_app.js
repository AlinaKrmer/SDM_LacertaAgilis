// Loead landcover
var land1 = ee.Image("projects/alinakraemer-sdm-l-agilis/assets/Clip_wcres100");
var land2 = ee.Image("projects/alinakraemer-sdm-l-agilis/assets/Clip_wcres101");
var land = ee.ImageCollection([land1, land2]).mosaic();

// Loead soiltypes
var soil1 = ee.Image("projects/alinakraemer-sdm-l-agilis/assets/Clip_soil_neu_100");
var soil2 = ee.Image("projects/alinakraemer-sdm-l-agilis/assets/Clip_soil_neu_101");
var soil = ee.ImageCollection([soil1, soil2]).mosaic();

// Load corridor map
var cor1 = ee.Image("projects/alinakraemer-sdm-l-agilis/assets/Corridor0");
var cor2 = ee.Image("projects/alinakraemer-sdm-l-agilis/assets/Corridor1");
var cor = ee.ImageCollection([cor1, cor2]).mosaic();

// Load prediction map
var pred1 = ee.Image("projects/alinakraemer-sdm-l-agilis/assets/pred0");
var pred2 = ee.Image("projects/alinakraemer-sdm-l-agilis/assets/pred1");
var pred = ee.ImageCollection([pred1, pred2]).mosaic();

// Load Trainingdata, filter by prediction geometry, and categorize features
var shape = ee.FeatureCollection("projects/alinakraemer-sdm-l-agilis/assets/traindat_25000_Clip");
var shape = shape.filterBounds(pred.geometry());
var presence = shape.filter(ee.Filter.eq('abundance', 'Presence'));
var absence = shape.filter(ee.Filter.eq('abundance', 'Absence'));

// Load study area
var studyarea = ee.FeatureCollection("projects/alinakraemer-sdm-l-agilis/assets/Mask_Merge");

// Define color palettes
var colorPaletteCorridor = [
    '215b8a', '7095b3', 'dbd1b8','eff0cc','f5956c', 'cf6323', '9e1111'
];

var colorPalettePrediction = [
    'd1d1bb', 'bba885', 'ac8070','a56662','782e2e','93000f'
];

var colorPaletteLand = [
  '5F5885', '99FB66', 'D8874C', 'FC59F7', '77F3F3', '628544', 'CC4A72', 'EBF29A', '8875F0'
  ];

var colorPaletteSoil = [
  '5F5885', '99FB66', 'D8874C', 'FC59F7', '77F3F3', '628544', 'CC4A72', 'EBF29A', '8875F0','94456D','A9FB5D','F55F61','4CB164','6D3EB0','73C3F4'
  ];

// Create the main map
var mapPanel = ui.Map();

// Center the map on Germany.
mapPanel.setCenter(10.4515, 51.1657, 6);

// Add layers to the map
var landLayer = mapPanel.addLayer(land, {min: 10, max: 90, palette: colorPaletteLand}, 'Landcover');
var soilLayer = mapPanel.addLayer(soil, {min: 1, max: 16, palette: colorPaletteSoil}, 'Soil');
var predLayer = mapPanel.addLayer(pred, { palette: colorPalettePrediction }, 'Habitat suitability');
var corLayer = mapPanel.addLayer(cor, { palette: colorPaletteCorridor }, 'Connectivity');
var presenceLayer = mapPanel.addLayer(presence, { color: 'b54848' }, 'Presence');
var absenceLayer = mapPanel.addLayer(absence, { color: 'a4a6ab' }, 'Absence');
var areaLayer = mapPanel.addLayer(studyarea, { color: 'a4a6ab' }, 'Study Area');


// Set the initial visibility of the layers to false.
predLayer.setShown(false);
corLayer.setShown(true);
presenceLayer.setShown(false);
absenceLayer.setShown(false);
areaLayer.setShown(false);
landLayer.setShown(false);
soilLayer.setShown(false);

// Create side panel
var sidePanel = ui.Panel({
    style: {
      width: '20%',
      backgroundColor: '525150'
    }
  });

// Add title and text
var title = ui.Label('Investigation of habitat suitability and connectivity of the '+
                    'Sand Lizard (Lacerta agilis) at its distribution limit using '+
                    'machine learning and Citizen Science data',
{
  fontWeight: 'bold',
  fontSize: '18px',
  backgroundColor: '525150',
  color: 'c4c4c4', // Schriftfarbe auf Weiß setzen
  fontFamily: 'Arial', // Schrifttyp auf Arial setzen
  whiteSpace: 'pre-line' // Blockformatierung mit Zeilenumbrüchen
});
sidePanel.add(title);


var text = ui.Label('This web map illustrates the connectivity assessed '+
                    'through a cost-distance analysis and the prediction '+
                    'of habitat suitability for the sand lizard (Lacerta Agilis),'+
                    'computed using a Random Forest algorithm. The connectivity '+
                    'map elucidates the movement costs from a occurance of L. agilis '+
                    'to the nearest corridor, scaled from 0 to 1. Likewise, habitat '+
                    'suitability is quantified on a scale of 0 to 1, where 0 signifies '+
                    'low suitability and 1 indicates high suitability. '+
                    'All code used to perform models, analyses, maps, and this app is available on this', 
{
  fontSize: '13px',
  backgroundColor: '525150',
  color: 'a4a6ab', 
  fontFamily: 'Arial',
  whiteSpace: 'pre-line' 
});

sidePanel.add(text);

// Create link button to GitHub repository
var linkButton = ui.Button({
    label: 'GitHub Repository',
    style: {
      fontWeight: 'bold',
      fontSize: '13px',
      backgroundColor: 'a4a6ab',
      color: '525150', 
      fontFamily: 'Arial',
      whiteSpace: 'pre-line', 
      textAlign: 'center',
      border: 'none', // Remove button border
      padding: '0', // Remove padding to make it look like a link
    },
    onClick: function() {
      window.open('https://github.com/AlinaKrmer/SpeciesDistributionModelLacertaAgilis', '_blank');
    }
  });
  

// Create legend elements for corridors and predictions
// Colorbar Corridor
var colorBarCorridor = ui.Thumbnail({
    image: ee.Image.pixelLonLat().select(0),
    params: {
      bbox: [0, 0, 1, 0.1],
      dimensions: '100x10',
      format: 'png',
      min: 0,
      max: 1,
      palette: colorPaletteCorridor
    },
    style: { margin: '0px 8px', maxHeight: '24px' }
  });
  
// Labels Corridor legend
var legendLabelsCorridor = ui.Panel({
    widgets: [
      ui.Label('0', {
        margin: '4px 1px',
        color: 'c4c4c4',
        backgroundColor: '525150', // Hintergrundfarbe des Labels auf Grau setzen
      }),
      ui.Label('0.5', {
        margin: '4px 30px',
        color: 'c4c4c4',
        backgroundColor: '525150', // Hintergrundfarbe des Labels auf Grau setzen
      }),
      ui.Label('1', {
        margin: '4px 8px',
        color: 'c4c4c4',
        backgroundColor: '525150', // Hintergrundfarbe des Labels auf Grau setzen
      })
    ],
    layout: ui.Panel.Layout.Flow('horizontal'),
    style: {
      backgroundColor: '525150', // Hintergrundfarbe des Panels auf Grau setzen
    }
  });
  
  
// Colorbar Prediction
var colorBarPrediction = ui.Thumbnail({
    image: ee.Image.pixelLonLat().select(0),
    params: {
      bbox: [0, 0, 1, 0.1],
      dimensions: '100x10',
      format: 'png',
      min: 0,
      max: 1,
      palette: colorPalettePrediction
    },
    style: { margin: '0px 8px', maxHeight: '24px' }
  });
  
// Labels Prediction legend
var legendLabelsPrediction = ui.Panel({
    widgets: [
      ui.Label('0', {
        margin: '4px 1px',
        color: 'c4c4c4',
        backgroundColor: '525150', // Hintergrundfarbe des Labels auf Grau setzen
      }),
      ui.Label('0.5', {
        margin: '4px 30px',
        color: 'c4c4c4',
        backgroundColor: '525150', // Hintergrundfarbe des Labels auf Grau setzen
      }),
      ui.Label('1', {
        margin: '4px 8px',
        color: 'c4c4c4',
        backgroundColor: '525150', // Hintergrundfarbe des Labels auf Grau setzen
      })
    ],
    layout: ui.Panel.Layout.Flow('horizontal'),
    style: {
      backgroundColor: '525150', // Hintergrundfarbe des Panels auf Grau setzen
    }
  });

// Legend Presence
var legendPresence = ui.Panel({
    widgets: [
      ui.Panel({
        widgets: [ui.Label(' ● ', { color: 'b54848', fontWeight: 'bold', fontFamily: 'Arial', backgroundColor: '525150'})],
        style: { backgroundColor: '525150'}
      })
    ],
    layout: ui.Panel.Layout.Flow('horizontal'),
    style: { backgroundColor: '525150'}
  });


// Legend Absence
var legendAbsence = ui.Panel({
    widgets: [
      ui.Panel({
        widgets: [ui.Label(' ● ', { color: 'a4a6ab', fontWeight: 'bold', fontFamily: 'Arial', backgroundColor: '525150' })],
        style: { backgroundColor: '525150' }
      })
    ],
    layout: ui.Panel.Layout.Flow('horizontal'),
    style: { backgroundColor: '525150' }
  });
  
  // Lables legend Land
  var landValues = [10, 20, 30, 40, 50, 60, 70, 80, 90];
  var landLabels = ['Treecover', 'Shrubland', 'Grassland', 'Cropland', 'Settlements', 'Bare', 'Snow and ice', 'Permanent waterbodies', 'Herbaceous wetland'];

  // Lables legend Soil
  var soilValues = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15, 16];
  var soilLabels = ['Clayey sand', 'Clean sand', 'Clayey silt','Normal clay','Sandy clay','Clayey loam','Silty sand','Silty loam','Clay loam','Silty clay','Minig area','Water bodies','Moors','Cities','Mudflats'];
  
// Create labelStyle
  var labelStyle = {
    'backgroundColor': '525150',
    'color': 'c4c4c4',
    'fontFamily': 'Arial'
  };

// Create checkboxes to control layer visibility

  // Checkbox Corridor-Layer
  var corridorCheckbox = ui.Checkbox({
    label: 'Connectivity displayed in movement costs',
    style: labelStyle,
    value: true,
    onChange: function(checked) {
      corLayer.setShown(checked);
    }
  });
  
  // Checkbox Prediction-Layer
  var predictionCheckbox = ui.Checkbox({
    label: 'Habitat suitability',
    style: labelStyle,
    value: false,
    onChange: function(checked) {
      predLayer.setShown(checked);
    }
  });
  
  // Checkbox Presence-Layer
  var presenceCheckbox = ui.Checkbox({
    label: 'Lacerta agilis occurrence',
    style: labelStyle,
    value: false,
    onChange: function(checked) {
      presenceLayer.setShown(checked);
    }
  });
  
  // Checkbox Absence-Layer
  var absenceCheckbox = ui.Checkbox({
    label: 'Lacerta agilis pseudo absence',
    style: labelStyle,
    value: false,
    onChange: function(checked) {
      absenceLayer.setShown(checked);
    }
  });
  
  // Checkbox Study Area-Layer
  var AreaCheckbox = ui.Checkbox({
    label: 'Study Area',
    style: labelStyle,
    value: false,
    onChange: function(checked) {
      areaLayer.setShown(checked);
    }
  });
  
  // Checkbox Landcover
  var landCheckbox = ui.Checkbox({
    label: 'Landcover',
    style: labelStyle,
    value: false,
    onChange: function(checked) {
     landLayer.setShown(checked);
    }
  });
  
  // Checkbox Soil
  var soilCheckbox = ui.Checkbox({
    label: 'Soiltype',
    style: labelStyle,
    value: false,
    onChange: function(checked) {
      soilLayer.setShown(checked);
   }
  });


// Create custom legends for land and soil
var landLegend = ui.Panel({
  style: {
    backgroundColor: '525150',
    padding: '8px 15px'
  }
});

var soilLegend = ui.Panel({
  style: {
    backgroundColor: '525150',
    padding: '8px 15px'
  }
});



// Loop through the values and add color squares with labels
for (var i = 0; i < landValues.length; i++) {
  var colorBoxLand = ui.Panel({
    style: {
      backgroundColor: '#' + colorPaletteLand[i],
      padding: '8px',
      margin: '0 0 4px 0'
    }
  });

  var description = ui.Label({
    value: landLabels[i],
    style: {
      fontSize: '12px',
      backgroundColor: '525150',
      color: 'a4a6ab', 
      fontFamily: 'Arial',
      margin: '4px'
    }
  });

  var legendItem = ui.Panel({
    style: {
      backgroundColor: '525150',
      fontSize: '12px',
      margin: '0'
    },
    widgets: [colorBoxLand, description],
    layout: ui.Panel.Layout.Flow('horizontal')
  });

  landLegend.add(legendItem);
}


// Loop through the values and add color squares with labels
for (var i = 0; i < soilValues.length; i++) {
  var colorBoxSoil = ui.Panel({
    style: {
      backgroundColor: '#' + colorPaletteSoil[i],
      padding: '8px',
      margin: '0 0 4px 0'
    }
  });

  var description = ui.Label({
    value: soilLabels[i],
    style: {
      fontSize: '12px',
      backgroundColor: '525150',
      color: 'a4a6ab', 
      fontFamily: 'Arial',
      margin: '4px'
    }
  });

  var soilItem = ui.Panel({
    style: {
      backgroundColor: '525150',
      fontSize: '12px',
      margin: '0'
    },
    widgets: [colorBoxSoil, description],
    layout: ui.Panel.Layout.Flow('horizontal')
  });

  soilLegend.add(soilItem);
}

// Add legend elements and checkboxes to side panel
sidePanel.add(linkButton);
sidePanel.add(AreaCheckbox);

sidePanel.add(corridorCheckbox);
sidePanel.add(colorBarCorridor);
sidePanel.add(legendLabelsCorridor);

sidePanel.add(predictionCheckbox);
sidePanel.add(colorBarPrediction);
sidePanel.add(legendLabelsPrediction);

sidePanel.add(presenceCheckbox);
sidePanel.add(legendPresence);
sidePanel.add(absenceCheckbox);
sidePanel.add(legendAbsence);

sidePanel.add(landCheckbox);
sidePanel.add(landLegend);

sidePanel.add(soilCheckbox);
sidePanel.add(soilLegend);


// Replace the root with a SpidePanel that contains the inspector and map.
ui.root.clear();
ui.root.add(ui.SplitPanel(sidePanel, mapPanel));


// Create Backgroundmap
var LacAgilis = [
    {
        "featureType": "administrative",
        "elementType": "all",
        "stylers": [
            {
                "visibility": "on"
            },
            {
                "lightness": 33
            }
        ]
    },
    {
        "featureType": "landscape",
        "elementType": "all",
        "stylers": [
            {
                "color": "#f2e5d4"
            }
        ]
    },
    {
        "featureType": "poi.park",
        "elementType": "geometry",
        "stylers": [
            {
                "color": "#c5dac6"
            }
        ]
    },
    {
        "featureType": "poi.park",
        "elementType": "labels",
        "stylers": [
            {
                "visibility": "on"
            },
            {
                "lightness": 20
            }
        ]
    },
    {
        "featureType": "road",
        "elementType": "all",
        "stylers": [
            {
                "lightness": 20
            }
        ]
    },
    {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [
            {
                "color": "#c5c6c6"
            }
        ]
    },
    {
        "featureType": "road.arterial",
        "elementType": "geometry",
        "stylers": [
            {
                "color": "#e4d7c6"
            }
        ]
    },
    {
        "featureType": "road.local",
        "elementType": "geometry",
        "stylers": [
            {
                "color": "#fbfaf7"
            }
        ]
    },
    {
        "featureType": "water",
        "elementType": "all",
        "stylers": [
            {
                "visibility": "on"
            },
            {
                "color": "#acbcc9"
            }
        ]
    }
]

mapPanel.setOptions('LacAgilis', {LacAgilis:LacAgilis});
