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
    @NSManaged var tags: String
    @NSManaged var status: Int16
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, title:String, lat: Double, long: Double, tags:String ) -> Project{
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("Project", inManagedObjectContext: moc) as! Project
        newitem.latitude = lat
        newitem.longitude = long
        newitem.title = title
        newitem.imagefiles = NSMutableSet()
        newitem.tags = tags
        newitem.status = Int16(workType.arbeid.rawValue)
        
        return newitem
    }
    
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
    
    var sortedImagefiles:[Imagefile]
        {
        get{
            let sortedArray:[Imagefile] = []
            let sortDescriptor = NSSortDescriptor(key: "worktype", ascending: true)
            self.imagefiles.sortedArrayUsingDescriptors([sortDescriptor])
            
            //_?????
            //sortedArray = self.imagefiles.sortedArrayUsingDescriptors([sortDescriptor])
            
            return sortedArray
        }
    }
    

    
    
    var filepoints:NSSet
        {
        get{
            return (self.firstImagefile)!.filepoints
        }
    }
}

extension Project {
    
    func getSort(documentType:Bool = false) -> Int16
    {
        var sortedArray:[Imagefile] = []
        let sortDescriptor = NSSortDescriptor(key: "sort", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "documenttype", ascending: documentType)
        sortedArray = (self.imagefiles.sortedArrayUsingDescriptors([sortDescriptor,sortDescriptor2]) as? [Imagefile])!


        /*
        sortedArray.filter( { (imgf: Imagefile) -> Bool in
            return imgf.documenttype == documentType
        })
        */
        
        return sortedArray.first == nil ? 0 : sortedArray.first!.sort
    }
    
    func lockImageFiles()
    {
        for item in self.imagefiles
        {
            if (item as! Imagefile).dokumenttype == false
            {
                (item as! Imagefile).locked = true
            }
        }
    }
    
    func addImagefile(imagefile:Imagefile) {
        
        var files: NSMutableSet
        
        files = self.mutableSetValueForKey("imagefiles")
        files.addObject(imagefile)
        
    }
    


    func getNumberOfFiles() -> Int {
        return self.imagefiles.count
    }

}