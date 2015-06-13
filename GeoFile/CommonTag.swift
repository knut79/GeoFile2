//
//  CommonTag.swift
//  GeoFile
//
//  Created by knut on 11/06/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

import Foundation
import CoreData

class CommonTag: NSManagedObject {
    
    @NSManaged var tag: String
    @NSManaged var category: Int16
    
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, tag:String) -> CommonTag{
        let newitem = NSEntityDescription.insertNewObjectForEntityForName("CommonTag", inManagedObjectContext: moc) as! CommonTag
        newitem.tag = tag
        return newitem
    }
}