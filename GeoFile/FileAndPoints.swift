//
//  ImageAndPoints.swift
//  GeoFile
//
//  Created by knut on 02/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation


class FileAndPoints
{
    var parentRefPoint:FileAndPoints?
    var originPoint:CGPoint
    var originPointLabel:UILabel
    var refPoints:[FileAndPoints]
    var imageOverrideFile:UIImage?
    var file: String
    
    init(origin: CGPoint, originLabel:UILabel, parentRef:FileAndPoints?)
    {
        self.file = ""
        self.imageOverrideFile = nil
        self.originPoint = origin
        self.originPointLabel = originLabel
        self.refPoints = []
        self.parentRefPoint = parentRef
    }
    

    func setImageDirect(image:UIImage)
    {
        self.file = ""
        self.imageOverrideFile = image
    }
    
    func addPoint(point:CGPoint, label:UILabel)
    {
        let fileAndPoints = FileAndPoints(origin:point,originLabel:label,parentRef:self)
        refPoints.append(fileAndPoints)
        
    }
    
    func pointCount() -> Int
    {
        return refPoints.count
    }
    
    func getPointObjOnIndex(index:Int) -> FileAndPoints
    {
        return refPoints[index]
    }
    
    func getParentPointObj() -> FileAndPoints?
    {
        return self.parentRefPoint
    }
    
    func getLastAddedPointObj() -> FileAndPoints
    {
        return refPoints[refPoints.count-1]
    }
    
    func setLastAddedPointObj(point:CGPoint)
    {
        refPoints[refPoints.count-1].originPoint = point
    }
}