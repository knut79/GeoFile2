//
//  Filepoint.swift
//  GeoFile
//
//  Created by knut on 10/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//
import Foundation
import CoreData

class Filepoint: NSManagedObject {
    
    @NSManaged var text: String
    @NSManaged var title: String
    @NSManaged var x: Float
    @NSManaged var y: Float
    @NSManaged var imagefile:Imagefile?
    @NSManaged var imagefiles:NSSet

    
    //added on picture with coordinates on parent filepoint
    class func createInManagedObjectContext(moc: NSManagedObjectContext, title: String, x:Float, y:Float) -> Filepoint{
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("Filepoint", inManagedObjectContext: moc) as Filepoint
        newitem.title = title
        newitem.x = x
        newitem.y = y

        newitem.imagefiles = NSMutableSet()
        
        return newitem
    }
    
    var parent:Filepoint?
        {
        get{
            return self.imagefile!.filepoint
        }
    }
    
    var filepoints:NSSet
        {
        get{
            return (self.imagefiles.allObjects.first as Imagefile).filepoints
        }
    }
    
    //TODO: should find first on info type then on any other .... make some rules
    var firstImagefile:Imagefile?
        {
        get{
            if imagefiles.count > 0
            {
                for item in imagefiles
                {
                    if( (item as Imagefile).worktype == Int16(workType.info.rawValue))
                    {
                        return item as Imagefile
                    }
                }
                return self.imagefiles.allObjects.first as Imagefile
            }
            else
            {
                return nil
            }
        }
    }
    
    var file:NSData?
        {
        get{
            return self.imagefiles.count > 0 ? (self.imagefiles.allObjects.first as Imagefile).file : nil
        }
    }

}


extension Filepoint {
    
    
    func addImagefile(imagefile:Imagefile) {
        
        var imagefiles: NSMutableSet
        imagefiles = self.mutableSetValueForKey("imagefiles")
        imagefiles.addObject(imagefile)
    }
    
}
