//
//  NewProjectView.swift
//  GeoFile
//
//  Created by knut on 08/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
protocol NewProjectProtocol {
    
    func setPositionNewProject()
    func setCurrentPositionNewProject()
    func addNewProject()
    func cancelNewProject()
}

class NewProjectView: UIView
{
    var newProjectTitle:UILabel!

    var delegate: NewProjectProtocol?
    
    var setCurrentPositionButton:CustomButton!
    var setPositionButton:CustomButton!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        //newProjectView = UIView(frame: self.view.frame)
        self.backgroundColor = UIColor.whiteColor()

        newProjectTitle = UILabel(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.size.height/2) + buttonBarHeight, UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        newProjectTitle.textAlignment = NSTextAlignment.Center
          self.addSubview(newProjectTitle)
        
        setCurrentPositionButton = CustomButton(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.size.height/2) + (buttonBarHeight*3) ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        setCurrentPositionButton.setTitle("Set current position", forState: .Normal)
        setCurrentPositionButton.addTarget(self, action: "setCurrentPositionNewProject", forControlEvents: .TouchUpInside)
        self.addSubview(setCurrentPositionButton)
        
        setPositionButton = CustomButton(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.size.height/2) + (buttonBarHeight*4) ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        setPositionButton.setTitle("Set manual position", forState: .Normal)
        setPositionButton.addTarget(self, action: "setPositionNewProject", forControlEvents: .TouchUpInside)
        self.addSubview(setPositionButton)
        
        var cancelButton = CustomButton(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.size.height/2) + (buttonBarHeight*5) ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.addTarget(self, action: "cancelNewProject", forControlEvents: .TouchUpInside)
        self.addSubview(cancelButton)
    }
    
    func setPositionNewProject()
    {
        delegate?.setPositionNewProject()
    }
    
    func setCurrentPositionNewProject()
    {
        delegate?.setCurrentPositionNewProject()
    }
    
    func cancelNewProject()
    {
        delegate?.cancelNewProject()
    }
    
    
}