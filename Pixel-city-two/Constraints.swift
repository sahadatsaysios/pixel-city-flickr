//
//  Constraints.swift
//  Pixel-city-two
//
//  Created by Sahadat  Hossain on 29/11/18.
//  Copyright © 2018 Sahadat  Hossain. All rights reserved.
//

import Foundation

let API_KEY = "57ed7380c69d520ad6d71355da8486d3"

func flickrUrl (apiKeyfor apiKey : String, withAnnotation annotation : DropablePin, addPhotoNumber numberofPhotos : Int) -> String {
    
    let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(numberofPhotos)&format=json&nojsoncallback=1"
    
    return url
}
