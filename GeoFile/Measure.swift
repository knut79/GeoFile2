//
//  Measure.swift
//  GeoFile
//
//  Created by knut on 12/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

class Measure
{
    var start:CGPoint
    var end: CGPoint
    var color:drawColorEnum
    private var label:UILabel?
    var text:String
    
    init(start _start:CGPoint, end _end:CGPoint, color _color:drawColorEnum, text _text:String)
    {
        start = _start
        end = _end
        color = _color
        label = nil
        text = _text
    }
    
    func setLabel(label _label:UILabel)
    {
        label = _label
        label?.textColor = getUIColor(color)
    }
    
    func getLabel() -> UILabel
    {
        return label!
    }
    
    
}