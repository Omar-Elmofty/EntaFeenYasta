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
    // Constructor
    // @param image_name Name of image_name to use from asset library
    // @param location Location of marker on map.
    init(image_name : String, location : (longtitude : Double, latitude : Double))
    {
       super.init()
       set(key: "image_name", value: image_name)
       set(key: "location", value: location)
    }
}
