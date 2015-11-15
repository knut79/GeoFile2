//
//  Imagefile.swift
//  GeoFile
//
//  Created by knut on 13/05/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import CoreData

class Imagefile: NSManagedObject {
    
    @NSManaged var file: NSData
    @NSManaged var text: String
    @NSManaged var title: String
    @NSManaged var tags: String?
    @NSManaged var worktype: Int16
    @NSManaged var filepoint: Filepoint?
    @NSManaged var mappoint: MapPoint?
    @NSManaged var filepoints: NSSet
    @NSManaged var lines: NSSet
    @NSManaged var measures: NSSet
    @NSManaged var angles: NSSet
    @NSManaged var texts: NSSet
    @NSManaged var sort:Int16
    @NSManaged var dokumenttype:DarwinBoolean
    @NSManaged var locked:DarwinBoolean
    
    //added on picture with coordinates on parent filepoint
    class func createInManagedObjectContext(moc: NSManagedObjectContext, title: String, file: NSData, tags:String?, worktype:workType) -> Imagefile{
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("Imagefile", inManagedObjectContext: moc) as! Imagefile
        newitem.title = title
        newitem.file = file
        
        newitem.tags = tags
        newitem.worktype = Int16(worktype.rawValue)
        if worktype == workType.dokument
        {
            newitem.dokumenttype = true
        }
        else
        {
            newitem.dokumenttype = false
        }
        newitem.locked = false
        newitem.filepoints = NSMutableSet()
        newitem.lines = NSMutableSet()
        newitem.measures = NSMutableSet()
        newitem.texts = NSMutableSet()
        newitem.angles = NSMutableSet()
        return newitem
    }
}

extension Imagefile {
    
    func setNewSort(currentSort:Int16) {
        
        var newSort:Int16 = 1
        if currentSort == 0
        {
            if self.dokumenttype == true
            {
                newSort += 1000
            }
        }
        else
        {
            newSort = currentSort + 1
        }
        
        self.sort = newSort
    }
    
    
    func addFilepoint(filepoint:Filepoint) {
        
        var points: NSMutableSet
        points = self.mutableSetValueForKey("filepoints")
        points.addObject(filepoint)
    }
    
    func addDrawingLine(line:Drawingline) {
        
        var lines: NSMutableSet
        lines = self.mutableSetValueForKey("lines")
        lines.addObject(line)
    }
    
    func addDrawingMeasure(measure:Drawingmeasure) {
        
        var measures: NSMutableSet
        measures = self.mutableSetValueForKey("measures")
        measures.addObject(measure)
    }
    
    func addDrawingAngle(angle:Drawingangle) {
        
        var angles: NSMutableSet
        angles = self.mutableSetValueForKey("angles")
        angles.addObject(angle)
    }
    
    func addDrawingText(text:Drawingtext) {
        
        var texts: NSMutableSet
        texts = self.mutableSetValueForKey("texts")
        texts.addObject(text)
    }

    func getNumberOfPoints() -> Int {
        return self.filepoints.count
    }

}
