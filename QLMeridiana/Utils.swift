//
//  Utils.swift
//  Meridiana
//
//  Created by Francesco Meschia on 9/28/15.
//  Copyright © 2015 Francesco Meschia. All rights reserved.
//

import Cocoa

class Utils: NSObject {
    static func deg2rad(deg: Double) -> Double {
        return deg * M_PI / 180.0;
    }
    
    static func rad2deg(rad: Double) -> Double {
        return rad * 180.0 / M_PI;
    }
    
    /*
    static func round(value: Double, factor: Double) -> Double {
        return round(value * factor)/factor;
    }
*/
}
