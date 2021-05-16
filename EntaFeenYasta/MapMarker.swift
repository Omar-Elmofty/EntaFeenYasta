//
//  MapMarker.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-05-16.
//

import Foundation
import Mapbox

// Base class for landmark on the map
class MapMarker : AttributeHandler
{
    // Default Constructor
    override init() {
        super.init()
    }
    
    // Constructor
    // @param image_name Name of image_name to use from asset library
    // @param location Location of marker on map [latitude, longtitude].
    init(marker_name : String, image_name : String, location : [Double])
    {
       super.init()
       set("marker_name", marker_name)
       set("image_name", image_name)
       set("location", location)
    }

    func createMapMarker() throws -> (MGLShapeSource, MGLSymbolStyleLayer)
    {
        // Create point to represent where the symbol should be placed
        let point = MGLPointAnnotation()
        var location : [Double] = [0.0, 0.0]
        var marker_name : String = ""
        var image_name : String = ""

        if !(get("location", &location) && get("marker_name", &marker_name) && get("image_name", &image_name))
        {
            throw AppError.runtimeError("Couldn't retrieve Marker params")
        }

        point.coordinate = CLLocationCoordinate2D(latitude: location[0], longitude: location[1])

        // Create a data source to hold the point data
        let shapeSource = MGLShapeSource(identifier: "\(marker_name)-source", shape: point, options: nil)

        // Create a style layer for the symbol
        let shapeLayer = MGLSymbolStyleLayer(identifier: "\(marker_name)-style", source: shapeSource)

        // Tell the layer to use the image in the sprite
        shapeLayer.iconImageName = NSExpression(forConstantValue: image_name)

        return (shapeSource, shapeLayer)
    }
}
