//
//  ProjectLeaf.swift
//  GeoFile
//
//  Created by knut on 24/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

class ProjectLeaf
{
    var project:Project
    var button:UIButton!
    var selected:Bool = false
    var filepointLeafs:[FilepointLeaf]
    
    init(_project:Project, _button:UIButton)
    {
        project = _project
        button = _button
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        selected = false
        filepointLeafs = []
    }
}