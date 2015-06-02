//
//  CustomViewController.swift
//  GeoFile
//
//  Created by knut on 25/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import CoreData

class CustomViewController:UIViewController, TopNavigationViewProtocol
{
    var pdfImages:[UIImage]?
    var topNavigationBar:TopNavigationView!
    //var yOffset:CGFloat!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topNavigationBar = TopNavigationView(frame:CGRectMake(0, 0 ,UIScreen.mainScreen().bounds.size.width, buttonBarHeight))
        
        topNavigationBar.delegate = self
        self.view.addSubview(topNavigationBar)
        
        /*
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "enteredForeground",
            name: UIApplicationWillEnterForegroundNotification,
            object: nil)
        */

        
        //test

        /*
        var pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "CV-mal.pdf", nil,nil)
        pdfImages = pdfToImages(pdfURL!)
        enteredForeground()
        */
        
    }
    
    func toMapView()
    {
        self.storyboard!.instantiateViewControllerWithIdentifier("MapOverviewViewController") as! MapOverviewViewController
        self.performSegueWithIdentifier("showProjectInMap", sender: nil)
    }
    
    func toListView()
    {
        self.storyboard!.instantiateViewControllerWithIdentifier("FilepointListViewController") as! FilepointListViewController
        self.performSegueWithIdentifier("showFilepointList", sender: nil)
    }
    
    func toTreeView(images:[UIImage]?)
    {
        pdfImages = images
        self.storyboard!.instantiateViewControllerWithIdentifier("TreeViewController") as! TreeViewController
        self.performSegueWithIdentifier("showTreeView", sender: nil)
    }
    
    func toTreeView()
    {
        self.storyboard!.instantiateViewControllerWithIdentifier("TreeViewController") as! TreeViewController
        self.performSegueWithIdentifier("showTreeView", sender: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    

    

}