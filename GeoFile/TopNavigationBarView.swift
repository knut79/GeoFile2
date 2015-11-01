//
//  TopNavigationBarView.swift
//  GeoFile
//
//  Created by knut on 25/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation


protocol TopNavigationViewProtocol
{
    func toTreeView(images:[UIImage]?)
    func toTreeView()
    func toMapView()
    func toListView()
}

class TopNavigationView:UIView
{

    var testButton:UIButton!
    var treeButton:CustomButton!
    var mapViewButton:CustomButton!
    var listViewButton:CustomButton!
    var delegate:TopNavigationViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        self.backgroundColor = UIColor.whiteColor()
        /*
        testButton = UIButton(frame: CGRectMake(0, 0 ,UIScreen.mainScreen().bounds.size.width * 0.33, buttonBarHeight))
        testButton.setTitle("Test", forState: .Normal)
        testButton.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        testButton.addTarget(self, action: "test", forControlEvents: .TouchUpInside)
        self.view.addSubview(testButton)
        */
        //var padding = (UIScreen.mainScreen().bounds.size.width * 0.1) / 2
        treeButton = CustomButton(frame: CGRectMake(0, 0 ,UIScreen.mainScreen().bounds.size.width/3, buttonBarHeight))
        treeButton.setTitle("Tree🌿", forState: .Normal)
        treeButton.addTarget(self, action: "toTreeView", forControlEvents: .TouchUpInside)
        self.addSubview(treeButton)
        
        mapViewButton = CustomButton(frame: CGRectMake(treeButton.frame.size.width, 0 ,UIScreen.mainScreen().bounds.size.width / 3, buttonBarHeight))
        mapViewButton.setTitle("Map🌍", forState: .Normal)
        mapViewButton.addTarget(self, action: "toMapView", forControlEvents: .TouchUpInside)
        self.addSubview(mapViewButton)
        
        listViewButton = CustomButton(frame: CGRectMake(treeButton.frame.size.width + mapViewButton.frame.size.width, 0 ,UIScreen.mainScreen().bounds.size.width / 3, buttonBarHeight))
        listViewButton.setTitle("List📑", forState: .Normal)
        listViewButton.addTarget(self, action: "toListView", forControlEvents: .TouchUpInside)
        self.addSubview(listViewButton)
    }
    
    func showForViewtype(viewtype:viewtypeEnum)
    {
        treeButton.enabled = true
        treeButton.alpha = 1
        listViewButton.enabled = true
        listViewButton.alpha = 1
        mapViewButton.enabled = true
        mapViewButton.alpha = 1
        
        switch(viewtype)
        {
        case .tree:
            treeButton.enabled = false
            treeButton.alpha = 0.5
        case .list:
            listViewButton.enabled = false
            listViewButton.alpha = 0.5
        case .map:
            mapViewButton.enabled = false
            mapViewButton.alpha = 0.5
        case .none:
            break

        }
    }
    
    func toTreeView(images:[UIImage]?)
    {
        delegate?.toTreeView(images)
    }
    
    func toTreeView()
    {
        delegate?.toTreeView()
    }
    
    func toMapView()
    {
        delegate?.toMapView()
    }
    
    func toListView()
    {
        delegate?.toListView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}