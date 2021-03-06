//
//  EditMapPointView.swift
//  GeoFile
//
//  Created by knut on 09/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
protocol EditMapPointProtocol {
    
    func editMapPointPosition()
    func cancelEditMapPoint()
    func saveEditMapPoint()
}

class EditMapPointView: UIView
{
    var titleTextBox:UITextField!
    var delegate: EditMapPointProtocol?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        //newMapPointView = UIView(frame: self.view.frame)
        self.backgroundColor = UIColor.whiteColor()

        titleTextBox = UITextField(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.size.height/2) + buttonBarHeight, UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        titleTextBox.textAlignment = NSTextAlignment.Center
        titleTextBox.placeholder = "Title"
        self.addSubview(titleTextBox)
        
        let setPositionButton = CustomButton(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.size.height/2) + (buttonBarHeight*3) ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        setPositionButton.setTitle("Edit position", forState: .Normal)
        setPositionButton.addTarget(self, action: "editMapPointPosition", forControlEvents: .TouchUpInside)
        self.addSubview(setPositionButton)
        
        let cancelButton = CustomButton(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.size.height/2) + (buttonBarHeight*4) ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.addTarget(self, action: "cancelEditMapPoint", forControlEvents: .TouchUpInside)
        self.addSubview(cancelButton)
        
        let saveButton = CustomButton(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.size.height/2) + (buttonBarHeight*5) ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        saveButton.setTitle("Save", forState: .Normal)
        saveButton.addTarget(self, action: "saveEditMapPoint", forControlEvents: .TouchUpInside)
        self.addSubview(saveButton)
    }
    
    func editMapPointPosition()
    {
        delegate?.editMapPointPosition()
    }
    
    func cancelEditMapPoint()
    {
        delegate?.cancelEditMapPoint()
    }
    
    func saveEditMapPoint()
    {
        delegate?.saveEditMapPoint()
    }
    
    
}
