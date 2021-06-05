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
    private var marker_name_ : String
    private var marker_type_ : String
    private var image_name_ : String
    // Location expressed in (latitude, longtitude)
    private var location_ : (Double, Double)
    
    init(marker_name : String, marker_type : String, image_name : String, location : (lattitude : Double, longtitude : Double))
    {
        marker_name_ = marker_name
        marker_type_ = marker_type
        image_name_ = image_name
        location_ = location
        super.init()
    }

    func createMapMarker() -> (MGLShapeSource, MGLSymbolStyleLayer)
    {
        // Create point to represent where the symbol should be placed
        let point = MGLPointAnnotation()


        point.coordinate = CLLocationCoordinate2D(latitude: location_.0, longitude: location_.1)

        // Create a data source to hold the point data
        let shapeSource = MGLShapeSource(identifier: "\(marker_name_)-source", shape: point, options: nil)

        // Create a style layer for the symbol
        let shapeLayer = MGLSymbolStyleLayer(identifier: "\(marker_name_)-style", source: shapeSource)

        // Tell the layer to use the image in the sprite
        shapeLayer.iconImageName = NSExpression(forConstantValue: image_name_)

        return (shapeSource, shapeLayer)
    }
    
    func getImageName() -> String {
        return image_name_
    }
    
    func createMapAnnotation() -> MGLPointAnnotation {
        let annotation = MGLPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: location_.0, longitude: location_.1)
        annotation.title = marker_name_
        annotation.subtitle = marker_type_
        return annotation
    }
}
