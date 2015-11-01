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
    @NSManaged var status: Int16

    
    //added on picture with coordinates on parent filepoint
    class func createInManagedObjectContext(moc: NSManagedObjectContext, title: String, x:Float, y:Float) -> Filepoint{
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("Filepoint", inManagedObjectContext: moc) as! Filepoint
        newitem.title = title
        newitem.x = x
        newitem.y = y

        newitem.imagefiles = NSMutableSet()
        
        newitem.status = Int16(workType.arbeid.rawValue)
        
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
            return (self.firstImagefile)!.filepoints
        }
    }
    
    /*
    var sortedImagefiles:[AnyObject]
        {
        get{
            var sortedArray:[AnyObject] = []
            let sortDescriptor = NSSortDescriptor(key: "sort", ascending: true)
            sortedArray = self.imagefiles.sortedArrayUsingDescriptors([sortDescriptor])

            
            return sortedArray
        }
    }
*/
    
    //TODO: should find first on info type then on any other .... make some rules
    var firstImagefile:Imagefile?
        {
        get{
            let sortDescriptor = NSSortDescriptor(key: "worktype", ascending: true)
            let sortedArray = self.imagefiles.sortedArrayUsingDescriptors([sortDescriptor])
            if let firstelement = sortedArray.first
            {
                return firstelement as? Imagefile
            }
            else
            {
                return nil
            }

        }
    }
    
    var imagefilesSorted:[AnyObject]
    {
        get{
            let sortDescriptor = NSSortDescriptor(key: "worktype", ascending: true)
            return self.imagefiles.sortedArrayUsingDescriptors([sortDescriptor])
        }
    }
    
    var file:NSData?
        {
        get{
            return self.imagefiles.count > 0 ? (self.firstImagefile)!.file : nil
        }
    }

}


extension Filepoint {
    
    func getSort(documentType:Bool = false) -> Int16
    {
        var sortedArray:[Imagefile] = []
        let sortDescriptor = NSSortDescriptor(key: "sort", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "documenttype", ascending: documentType)
        sortedArray = (self.imagefiles.sortedArrayUsingDescriptors([sortDescriptor,sortDescriptor2]) as? [Imagefile])!
        /*
        sortedArray.filter( { (includeElement: Imagefile) -> Bool in
            return includeElement.documenttype == documentType
        })
        */
        
        return sortedArray.first == nil ? 0 : sortedArray.first!.sort
    }
    
    func lockImageFiles()
    {
        for item in self.imagefiles
        {
            if (item as! Imagefile).dokumenttype == true
            {
                (item as! Imagefile).locked = true
            }
        }
    }
    
    func addImagefile(imagefile:Imagefile) {
        
        var imagefiles: NSMutableSet
        imagefiles = self.mutableSetValueForKey("imagefiles")
        imagefiles.addObject(imagefile)
    }
    
}
