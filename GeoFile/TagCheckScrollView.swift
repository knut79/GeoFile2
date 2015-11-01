//
//  TagCheckScrollView.swift
//  GeoFile
//
//  Created by knut on 09/06/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

//◻️◼️
//⚪️🔘
//◽️🔳

protocol TagCheckViewProtocol
{
    func closeTagCheckView()
    func reloadMarks(tags:[String])
    
}

class TagCheckScrollView: UIView , UIScrollViewDelegate, TagCheckItemProtocol{
    
    var tagCheckItems:[TagCheckView]!
    var tags:[String]!
    var scrollView:UIScrollView!
    var closeButton:UIButton!
    var delegate:TagCheckViewProtocol!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tags = []
        tagCheckItems = []
        
        closeButton = UIButton(frame: CGRectMake(frame.width - buttonIconSideSmall, 0, buttonIconSideSmall, buttonIconSideSmall))
        closeButton.setTitle("❌", forState: UIControlState.Normal)
        closeButton.addTarget(self, action: "close", forControlEvents: UIControlEvents.TouchUpInside)
        closeButton.layer.borderColor = UIColor.blackColor().CGColor
        closeButton.layer.borderWidth = 2.0
        self.addSubview(closeButton)
        
        scrollView = UIScrollView(frame: CGRectMake(0, buttonBarHeight, frame.width, frame.height - closeButton.frame.height))

        scrollView.delegate = self
        self.addSubview(scrollView)
        
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 2.0

        
        tags.append("skinnebrudd")
        tags.append("asfalt")
        tags.append("vannavløp")
        tags.append("skinnegang")


        let unselectBoxButton = UIButton(frame: CGRectMake(0, 0, frame.width * 0.33, buttonBarHeight))
        unselectBoxButton.setTitle("◽️", forState: UIControlState.Normal)
        unselectBoxButton.addTarget(self, action: "unselectAllTags", forControlEvents: UIControlEvents.TouchUpInside)
        
        let unselectTitleLabel = UILabel(frame: CGRectMake(unselectBoxButton.frame.maxX, 0, frame.width * 0.66, buttonBarHeight))
        unselectTitleLabel.text = "Unselect all"

        scrollView.addSubview(unselectBoxButton)
        scrollView.addSubview(unselectTitleLabel)

        var contentHeight:CGFloat = 0
        var i:CGFloat = 1
        for tagItem in tags
        {
            let newTagCheckItem = TagCheckView(frame: CGRectMake(0, buttonBarHeight * i, self.frame.width, buttonBarHeight), tagTitle: tagItem)
            newTagCheckItem.delegate = self
            tagCheckItems.append(newTagCheckItem)
            scrollView.addSubview(newTagCheckItem)
            contentHeight = newTagCheckItem.frame.maxY
            i++
        }
        
        scrollView.contentSize = CGSizeMake(scrollView.frame.width, contentHeight)
    }
    
    func unselectAllTags()
    {
        for item in tagCheckItems
        {
            item.checked = false
            item.checkBoxView.setTitle("◽️", forState: UIControlState.Normal)
        }
        delegate.reloadMarks(getTagsAsArray())
    }
    
    func checkChanged()
    {
        delegate.reloadMarks(getTagsAsArray())
    }
    
    func getTagsAsArray() -> [String]
    {
        var returnValue:[String] = []
        for item in tagCheckItems
        {
            if item.checked
            {
                returnValue.append(item.tagTitle)
            }
        }
        return returnValue
    }
    
    func getTagsAsString() -> String
    {
        var returnValue = ""
        for item in tagCheckItems
        {
            if item.checked
            {
                returnValue += "#\(item.tagTitle)"
            }
        }
        return returnValue
    }
    
    func close()
    {
        delegate!.closeTagCheckView()
    }
}