//
//  Line.swift
//  GeoFile
//
//  Created by knut on 11/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation


class Line
{
    var start:CGPoint
    var end: CGPoint
    var color:drawColorEnum
    var lastTouchBegan:Bool
    
    init(start _start:CGPoint, end _end:CGPoint, color _color:drawColorEnum, touchBegan:Bool)
    {
        start = _start
        end = _end
        color = _color
        lastTouchBegan = touchBegan
    }
    
}