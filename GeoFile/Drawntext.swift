//
//  Drawntext.swift
//  GeoFile
//
//  Created by knut on 16/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation


class Drawntext
{
    var color:drawColorEnum
    var label:UILabel?
    //var text:String
    //var position:CGPoint!
    
    init(label _label:UILabel, color _color:drawColorEnum)
    {
        color = _color
        label = _label
        label?.textColor = getUIColor(color)

    }

    
}