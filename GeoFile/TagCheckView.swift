//
//  File.swift
//  GeoFile
//
//  Created by knut on 09/06/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
protocol TagCheckItemProtocol
{
    func checkChanged()
}

class TagCheckView: UIView
{
    var checkBoxView:UIButton!
    var titleLabel:UILabel!
    var checked = true
    var tagTitle:String!
    var delegate:TagCheckItemProtocol!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, tagTitle:String, checked:Bool = true) {
        super.init(frame: frame)
        
        self.checked = checked
        checkBoxView = UIButton(frame: CGRectMake(0, 0, frame.width * 0.33, frame.height))
        if self.checked
        {
            checkBoxView.setTitle("🔳", forState: UIControlState.Normal)
        }
        else
        {
            checkBoxView.setTitle("◽️", forState: UIControlState.Normal)
        }
        checkBoxView.addTarget(self, action: "toggleSelect:", forControlEvents: UIControlEvents.TouchUpInside)

        self.addSubview(checkBoxView)
        
        self.tagTitle = tagTitle
        titleLabel = UILabel(frame: CGRectMake(checkBoxView.frame.maxX, 0, frame.width * 0.66, frame.height))
        titleLabel.text = tagTitle
        self.addSubview(titleLabel)
        
    }
    
    func toggleSelect(sender:UIButton)
    {
        if checked
        {
            checked = false
            checkBoxView.setTitle("◽️", forState: UIControlState.Normal)
        }
        else
        {
            checked = true
            checkBoxView.setTitle("🔳", forState: UIControlState.Normal)
        }
        delegate?.checkChanged()
    }

}