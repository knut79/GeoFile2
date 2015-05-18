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
    @NSManaged var imagefiles: NSSet
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, title:String, lat: Double, long: Double ) -> Project{
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("Project", inManagedObjectContext: moc) as Project
        newitem.latitude = lat
        newitem.longitude = long
        newitem.title = title
        newitem.imagefiles = NSMutableSet()
        
        return newitem
    }
    
    //TODO: should find first on info type then on any other .... make some rules
    var firstImagefile:Imagefile
        {
        get{
            return self.imagefiles.allObjects.first as Imagefile
        }
    }
    
    
    var filepoints:NSSet
        {
        get{
            return (self.imagefiles.allObjects.first as Imagefile).filepoints
        }
    }
}

extension Project {
    
    func addImagefileToProject(imagefile:Imagefile) {
        
        var files: NSMutableSet
        
        files = self.mutableSetValueForKey("imagefiles")
        files.addObject(imagefile)
        
    }
    


    func getNumberOfFiles() -> Int {
        return self.imagefiles.count
    }

}