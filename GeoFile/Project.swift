//
//  Project.swift
//  GeoFile
//
//  Created by knut on 08/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import CoreData

class Project: NSManagedObject {
    
    @NSManaged var longitude: Double
    @NSManaged var latitude: Double
    @NSManaged var title: String
    @NSManaged var filepoints: NSSet
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, title:String, lat: Double, long: Double ) -> Project{
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("Project", inManagedObjectContext: moc) as Project
        newitem.latitude = lat
        newitem.longitude = long
        newitem.title = title
        newitem.filepoints = NSMutableSet()
        
        return newitem
    }
    
}

extension Project {
    
    func addFilepointToProject(filepoint:Filepoint) {
        
        var files: NSMutableSet
        
        files = self.mutableSetValueForKey("filepoints")
        files.addObject(filepoint)
        
    }

    func getNumberOfFilepoints() -> Int {
        return self.filepoints.count
    }

}