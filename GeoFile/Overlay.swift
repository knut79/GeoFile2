//
//  Overlay.swift
//  GeoFile
//
//  Created by knut on 05/05/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import CoreData

class Overlay: NSManagedObject {
    
    @NSManaged var longitudeSW: Double
    @NSManaged var latitudeSW: Double
    @NSManaged var longitudeNE: Double
    @NSManaged var latitudeNE: Double
    @NSManaged var bearing: Double
    @NSManaged var title: String
    @NSManaged var file: NSData
    @NSManaged var active: Boolean
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, title:String, file: NSData) -> Overlay{
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("Overlay", inManagedObjectContext: moc) as! Overlay
        newitem.title = title
        newitem.file = file
        newitem.active = 0
        return newitem
    }
}
