//
//  Angle.swift
//  GeoFile
//
//  Created by knut on 13/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation


class Angle
{
    var start:CGPoint
    var mid: CGPoint
    var end: CGPoint?
    var hardSetText:Bool = false
    
    var color:drawColorEnum
    private var label:UILabel?
    var text:String
    
    init(start _start:CGPoint, mid _mid:CGPoint, end _end:CGPoint?, color _color:drawColorEnum, text _text:String)
    {
        start = _start
        mid = _mid
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