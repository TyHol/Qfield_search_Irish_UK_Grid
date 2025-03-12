import QtQuick
import QtQuick.Controls

import org.qfield
import org.qgis
import Theme

Item {
  id: plugin

  property var mainWindow: iface.mainWindow()
  property var mapCanvas: iface.mapCanvas()

  Component.onCompleted: {
    igukGridsFilter.locatorBridge.registerQFieldLocatorFilter(igukGridsFilter);
  }

  Component.onDestruction: {
    igukGridsFilter.locatorBridge.deregisterQFieldLocatorFilter(igukGridsFilter);
  }

  QFieldLocatorFilter {
    id: igukGridsFilter
    delay: 1000
    name: "IGUK Grids"
    displayName: "IG UK Grid finder"
    prefix: "grid"
    locatorBridge: iface.findItemByObjectName('locatorBridge')
    source: Qt.resolvedUrl('grids.qml')
    

function triggerResult(result) {
  if (result.userData && result.userData.geometry) {
    const geometry = result.userData.geometry;
    const crs = CoordinateReferenceSystemUtils.fromDescription(result.userData.crs);

    // Reproject the geometry to the map's CRS
    const reprojectedGeometry = GeometryUtils.reprojectPoint(
      geometry,
      crs,
      mapCanvas.mapSettings.destinationCrs
    );

    // Center the map on the reprojected geometry
   mapCanvas.mapSettings.setCenter(reprojectedGeometry, true);

    // Highlight the geometry on the map
    locatorBridge.locatorHighlightGeometry.qgsGeometry = geometry;
    locatorBridge.locatorHighlightGeometry.crs = crs;
  } else {
    mainWindow.displayToast("Invalid geometry in result");
  }
}
function triggerResultFromAction(result, actionId) {
  if (actionId === 1 && result.userData && result.userData.geometry) {
    const geometry = result.userData.geometry;
    const crs = CoordinateReferenceSystemUtils.fromDescription(result.userData.crs);

    // Reproject the geometry to the map's CRS
    const reprojectedGeometry = GeometryUtils.reprojectPoint(
      geometry,
      crs,
      mapCanvas.mapSettings.destinationCrs
    );

    // Set the navigation destination
    const navigation = iface.findItemByObjectName('navigation');
    if (navigation) {
      navigation.destination = reprojectedGeometry;
      mainWindow.displayToast("Destination set successfully");
    } else {
      mainWindow.displayToast("Navigation component not found");
    }
  } else {
    mainWindow.displayToast("Invalid action or geometry");
  }
}

}
}