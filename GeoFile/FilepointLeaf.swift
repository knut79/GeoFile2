//
//  FilepointLeaf.swift
//  GeoFile
//
//  Created by knut on 24/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

class FilepointLeaf
{
    var filepoint:Filepoint
    var parent:FilepointLeaf?
    var button:UIButton!
    var selected:Bool = false
    var filepointLeafs:[FilepointLeaf]
    
    init(_filePoint:Filepoint, _button:UIButton, _parent:FilepointLeaf?)
    {
        filepoint = _filePoint
        button = _button
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        selected = false
        filepointLeafs = []
        parent = _parent
    }
}
