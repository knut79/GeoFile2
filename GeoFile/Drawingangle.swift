//
//  Drawingangle.swift
//  GeoFile
//
//  Created by knut on 09/05/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import CoreData

class Drawingangle: NSManagedObject {
    
    @NSManaged var startX: Float
    @NSManaged var startY: Float
    @NSManaged var endX: Float
    @NSManaged var endY: Float
    @NSManaged var midX: Float
    @NSManaged var midY: Float
    @NSManaged var color: Int16
    @NSManaged var text: String
    
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, startPoint:CGPoint, midPoint:CGPoint, endPoint: CGPoint, color:drawColorEnum, text:String) -> Drawingangle{
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("Drawingangle", inManagedObjectContext: moc) as Drawingangle
        newitem.startX = Float(startPoint.x)
        newitem.startY = Float(startPoint.y)
        newitem.midX = Float(midPoint.x)
        newitem.midY = Float(midPoint.y)
        newitem.endX = Float(endPoint.x)
        newitem.endY = Float(endPoint.y)
        newitem.text = text
        newitem.color = Int16(color.rawValue)
        return newitem
    }
    
    var start:CGPoint
        {
        get{
            return CGPointMake(CGFloat(startX), CGFloat(startY))
        }
    }
    
    var mid:CGPoint
        {
        get{
            return CGPointMake(CGFloat(midX), CGFloat(midY))
        }
    }
    
    var end:CGPoint
        {
        get{
            return CGPointMake(CGFloat(endX), CGFloat(endY))
        }
    }

}