//
//  MarkerItem.swift
//  GeoFile
//
//  Created by knut on 12/06/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

class MarkerItem {
    
    var tags:String!
    var gmsmarker:GMSMarker!
    
    init(gmsmarker:GMSMarker, tagsString:String, statusTODO:String)
    {
        tags = tagsString
        self.gmsmarker = gmsmarker
        let arrayOfTags = tagsString.componentsSeparatedByString("#")
        
    }
}