//
//  CustomButton.swift
//  GeoFile
//
//  Created by knut on 25/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

class CustomButton:UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        self.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    }
}
