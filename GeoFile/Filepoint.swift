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
    
    @NSManaged var file: NSData?
    @NSManaged var text: String
    @NSManaged var title: String
    @NSManaged var x: Float
    @NSManaged var y: Float
    @NSManaged var toPoints: NSSet
    @NSManaged var parent: Filepoint?
    @NSManaged var filetype:Int16
    @NSManaged var project: Project?
    @NSManaged var filepoints: NSSet
    
    //added on picture with coordinates on parent filepoint
    class func createInManagedObjectContext(moc: NSManagedObjectContext, title: String, file: NSData?, x:Float, y:Float) -> Filepoint{
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("Filepoint", inManagedObjectContext: moc) as Filepoint
        newitem.title = title
        newitem.file = file
        newitem.filepoints = NSMutableSet()
        newitem.x = x
        newitem.y = y
        
        return newitem
    }
    
    //added without coordinates on parent filepoint
    class func createInManagedObjectContext(moc: NSManagedObjectContext, title: String, file: NSData?) -> Filepoint{
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("Filepoint", inManagedObjectContext: moc) as Filepoint
        newitem.title = title
        newitem.file = file
        newitem.filepoints = NSMutableSet()
        newitem.x = 0
        newitem.y = 0
        
        return newitem
    }
    
    //strait on project
    class func createInManagedObjectContext(moc: NSManagedObjectContext, title: String, file: NSData?, project:Project?) -> Filepoint{
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("Filepoint", inManagedObjectContext: moc) as Filepoint
        newitem.title = title
        newitem.file = file
        newitem.filepoints = NSMutableSet()
        newitem.project = project
        newitem.x = 0
        newitem.y = 0
        
        return newitem
    }
}

extension Filepoint {

    
    func addFilepointToFilepoint(filepoint:Filepoint) {
        
        var points: NSMutableSet
        points = self.mutableSetValueForKey("filepoints")
        points.addObject(filepoint)
    }
    
    
    func getNumberOfPoints() -> Int {
        return self.filepoints.count
    }
    
    
    
}