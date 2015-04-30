//
//  EditProjectView.swift
//  GeoFile
//
//  Created by knut on 09/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
protocol EditProjectProtocol {
    
    func editProjectPosition()
    func cancelEditProject()
    func saveEditProject()
}

class EditProjectView: UIView
{
    var titleTextBox:UITextField!
    var delegate: EditProjectProtocol?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        //newProjectView = UIView(frame: self.view.frame)
        self.backgroundColor = UIColor.whiteColor()

        titleTextBox = UITextField(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.size.height/2) + buttonBarHeight, UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        titleTextBox.textAlignment = NSTextAlignment.Center
        titleTextBox.placeholder = "Title"
        self.addSubview(titleTextBox)
        
        var setPositionButton = CustomButton(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.size.height/2) + (buttonBarHeight*3) ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        setPositionButton.setTitle("Edit position", forState: .Normal)
        setPositionButton.addTarget(self, action: "editProjectPosition", forControlEvents: .TouchUpInside)
        self.addSubview(setPositionButton)
        
        var cancelButton = CustomButton(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.size.height/2) + (buttonBarHeight*4) ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.addTarget(self, action: "cancelEditProject", forControlEvents: .TouchUpInside)
        self.addSubview(cancelButton)
        
        var saveButton = CustomButton(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.size.height/2) + (buttonBarHeight*5) ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        saveButton.setTitle("Save", forState: .Normal)
        saveButton.addTarget(self, action: "saveEditProject", forControlEvents: .TouchUpInside)
        self.addSubview(saveButton)
    }
    
    func editProjectPosition()
    {
        delegate?.editProjectPosition()
    }
    
    func cancelEditProject()
    {
        delegate?.cancelEditProject()
    }
    
    func saveEditProject()
    {
        delegate?.saveEditProject()
    }
    
    
}
