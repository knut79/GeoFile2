//
//  NewProjectView.swift
//  GeoFile
//
//  Created by knut on 08/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
protocol NewMapPointProtocol {
    
    func setPositionNewMapPoint()
    func setCurrentPositionNewMapPoint()
    func addNewMapPoint()
    func cancelNewMapPoint()
}

class NewMapPointView: UIView
{
    var newMapPointTitle:UILabel!

    var delegate: NewMapPointProtocol?
    
    var setCurrentPositionButton:CustomButton!
    var setPositionButton:CustomButton!
    var workTypes:[TagCheckView]!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        self.backgroundColor = UIColor.whiteColor()

        workTypes = []
        let labelWorktype = UILabel(frame: CGRectMake(0, 0, self.frame.width, buttonBarHeight))
        labelWorktype.textAlignment = NSTextAlignment.Center
        labelWorktype.text = "Type arbeid"
        labelWorktype.font = UIFont.boldSystemFontOfSize(12)
        labelWorktype.center = CGPointMake(self.frame.width / 2, elementMargin + (labelWorktype.frame.height / 2))
        self.addSubview(labelWorktype)
        
        for i in 0...3
        {
            let tag = commonTags(rawValue: i)
            let newTagCheckItem = TagCheckView(frame: CGRectMake(0, 0, self.frame.width, buttonBarHeight), tagTitle: tag!.description, checked: false)
            newTagCheckItem.center = CGPointMake(self.frame.width / 2, buttonBarHeight * CGFloat(i) + (elementMargin + labelWorktype.frame.maxY))
            self.addSubview(newTagCheckItem)
            workTypes.append(newTagCheckItem)
        }
        
        newMapPointTitle = UILabel(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.size.height/2) + buttonBarHeight, UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        newMapPointTitle.textAlignment = NSTextAlignment.Center
          self.addSubview(newMapPointTitle)
        
        setCurrentPositionButton = CustomButton(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.size.height/2) + (buttonBarHeight*3) ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        setCurrentPositionButton.setTitle("Set current position", forState: .Normal)
        setCurrentPositionButton.addTarget(self, action: "setCurrentPositionNewProject", forControlEvents: .TouchUpInside)
        self.addSubview(setCurrentPositionButton)
        
        setPositionButton = CustomButton(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.size.height/2) + (buttonBarHeight*4) ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        setPositionButton.setTitle("Set manual position", forState: .Normal)
        setPositionButton.addTarget(self, action: "setPositionNewProject", forControlEvents: .TouchUpInside)
        self.addSubview(setPositionButton)
        
        let cancelButton = CustomButton(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.size.height/2) + (buttonBarHeight*5) ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.addTarget(self, action: "cancelNewProject", forControlEvents: .TouchUpInside)
        self.addSubview(cancelButton)
    }
    
    func getTags() -> String
    {
        var returnValue = ""
        for item in workTypes
        {
            if item.checked
            {
                returnValue += "#\(item.tagTitle)"
            }
        }
        return returnValue
    }
    
    func setPositionNewProject()
    {
        delegate?.setPositionNewMapPoint()
    }
    
    func setCurrentPositionNewProject()
    {
        delegate?.setCurrentPositionNewMapPoint()
    }
    
    func cancelNewProject()
    {
        delegate?.cancelNewMapPoint()
    }
    
    
}