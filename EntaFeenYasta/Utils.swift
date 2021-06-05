//
//  Utils.swift
//  EntaFeenYasta
//
//  Created by Omar Elmofty on 2021-05-23.
//

import Foundation

func checkLocation(_ location : [Double]) throws
{
    if location.count != 2 {
        throw AppError.runtimeError("Location size must be equal to 2, input count is \(location.count)")
    }

    // Check latitude
    if (location[0] < -90.0) || (location[0] > 90.0) {
        throw AppError.runtimeError("Latitude \(location[0]) is out of bounds")
    }

    // Check longtitude
    if (location[1] < -180.0) || (location[1] > 180.0) {
        throw AppError.runtimeError("Longtitude \(location[1]) is out of bounds")
    }
}
