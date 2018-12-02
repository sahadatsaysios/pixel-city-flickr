//
//  DropablePin.swift
//  Pixel-city-two
//
//  Created by Sahadat  Hossain on 28/11/18.
//  Copyright © 2018 Sahadat  Hossain. All rights reserved.
//

import UIKit
import MapKit

class DropablePin : NSObject, MKAnnotation {
    
    var coordinate : CLLocationCoordinate2D
    var identifier : String
    
    init(coordinate : CLLocationCoordinate2D, identifier : String) {
        self.coordinate = coordinate
        self.identifier = identifier
        
        super.init()
    }
}
