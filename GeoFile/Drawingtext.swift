//
//  Drawingtext.swift
//  GeoFile
//
//  Created by knut on 09/05/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import CoreData

class Drawingtext: NSManagedObject {
    
    @NSManaged var centerX: Float
    @NSManaged var centerY: Float
    @NSManaged var color: Int16
    @NSManaged var size: Int16
    @NSManaged var text: String
    @NSManaged var startX: Float
    @NSManaged var startY: Float
    @NSManaged var endX: Float
    @NSManaged var endY: Float
    
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, centerPoint: CGPoint, color:drawColorEnum, text:String, size:Int ) -> Drawingtext{
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("Drawingtext", inManagedObjectContext: moc) as! Drawingtext
        newitem.centerX = Float(centerPoint.x)
        newitem.centerY = Float(centerPoint.y)
        newitem.text = text
        newitem.color = Int16(color.rawValue)
        newitem.size = Int16(size)
        return newitem
    }
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, startPoint: CGPoint, endPoint: CGPoint, color:drawColorEnum, text:String, size:Int ) -> Drawingtext{
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("Drawingtext", inManagedObjectContext: moc) as! Drawingtext
        newitem.startX = Float(startPoint.x)
        newitem.startY = Float(startPoint.y)
        newitem.endX = Float(endPoint.x)
        newitem.endY = Float(endPoint.y)
        newitem.text = text
        newitem.color = Int16(color.rawValue)
        newitem.size = Int16(size)
        return newitem
    }
    
    //OBSOLETE
    var center:CGPoint
        {
        get{
            return CGPointMake(CGFloat(centerX), CGFloat(centerY))
        }
    }
    
    var start:CGPoint
        {
        get{
            return CGPointMake(CGFloat(startX), CGFloat(startY))
        }
    }
    
    var end:CGPoint
        {
        get{
            return CGPointMake(CGFloat(endX), CGFloat(endY))
        }
    }
}