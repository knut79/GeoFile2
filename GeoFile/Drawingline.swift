//
//  LineEntity.swift
//  GeoFile
//
//  Created by knut on 07/05/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import CoreData

class Drawingline: NSManagedObject {
    
    @NSManaged var startX: Float
    @NSManaged var startY: Float
    @NSManaged var endX: Float
    @NSManaged var endY: Float
    @NSManaged var color: Int16
    @NSManaged var lastTouchBegan: Boolean

    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, startPoint:CGPoint, endPoint: CGPoint, color:drawColorEnum, lastTouchBegan:Bool) -> Drawingline{
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("Drawingline", inManagedObjectContext: moc) as! Drawingline
        newitem.startX = Float(startPoint.x)
        newitem.startY = Float(startPoint.y)
        newitem.endX = Float(endPoint.x)
        newitem.endY = Float(endPoint.y)
        newitem.lastTouchBegan = lastTouchBegan ? 1 : 0
        newitem.color = Int16(color.rawValue)
        return newitem
    }
}