//
//  TreeViewController.swift
//  GeoFile
//
//  Created by knut on 22/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation

import UIKit
import AVFoundation
import MobileCoreServices

class TreeViewController: CustomViewController, UIScrollViewDelegate, TreeViewProtocol, TopNavigationViewProtocol{
    
    var visibleContentView: TreeView!
    var overviewScrollView: UIScrollView!
    var childFilepointItems = [Filepoint]()
    var sameLevelFilepointsTableView = UITableView(frame: CGRectZero, style: .Plain)


    var passingFilepoint:Filepoint?
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var incommingFilesView: UIView!
    var imageViews:[UIImageView] = []
    var yOffset:CGFloat!
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yOffset = UIScreen.mainScreen().bounds.size.height - (buttonBarHeight * 2)
        incommingFilesView = UIView(frame: CGRectMake(0, yOffset, UIScreen.mainScreen().bounds.size.width , 100))
        incommingFilesView.hidden = true

        self.view.addSubview(incommingFilesView)
        
        var viewFrame = self.view.frame


        topNavigationBar.showForViewtype(.tree)
        

        let strechedHeight = UIScreen.mainScreen().bounds.size.height - (buttonBarHeight * 2)
        overviewScrollView = UIScrollView(frame: CGRectMake(0, buttonBarHeight, UIScreen.mainScreen().bounds.size.width, strechedHeight - 100))
        overviewScrollView.backgroundColor = UIColor.whiteColor()
        visibleContentView = TreeView(frame: CGRectMake(0, 0, overviewScrollView.frame.size.width * 1.4, overviewScrollView.frame.size.height * 1.4))
        visibleContentView.backgroundColor = UIColor.clearColor()
        visibleContentView.delegate = self
        overviewScrollView.addSubview(visibleContentView)
        overviewScrollView.contentSize = visibleContentView.frame.size
        
        if(passingFilepoint != nil)
        {
            visibleContentView.currentFilepointLeaf = FilepointLeaf(_filePoint:passingFilepoint!,_button:UIImageView(),_parent:nil)
            
            visibleContentView.buildNodesUpToSelectedNode_V2()
            visibleContentView.setNeedsDisplay()
        }
        
        
        let scrollViewFrame = overviewScrollView.frame
        let scaleWidth = scrollViewFrame.size.width / overviewScrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / overviewScrollView.contentSize.height
        let minScale = max(scaleWidth, scaleHeight)
        overviewScrollView.minimumZoomScale = minScale
        overviewScrollView.maximumZoomScale = 1.0
        overviewScrollView.zoomScale = minScale
        overviewScrollView.delegate = self

        self.view.addSubview(overviewScrollView)
        
        populatePdfImages()
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if(scrollView == overviewScrollView)
        {
            visibleContentView.fadeoutActionButtons()
            visibleContentView.unselectAllOverlayNodes()
        }

    }
    
    
    func populatePdfImages()
    {
        if(pdfImages == nil)
        {
            return
        }
        incommingFilesView.hidden = false
        var xOffset:CGFloat = 0
        var widthPerItem:CGFloat = pdfImages!.count < 3 ? 100 : UIScreen.mainScreen().bounds.size.width / CGFloat(pdfImages!.count)
        for image in pdfImages!
        {
            var imageView = UIImageView(frame: CGRectMake(xOffset, 0, 100, widthPerItem))
            imageView.backgroundColor = UIColor.clearColor()
            imageView.layer.borderColor = UIColor.blackColor().CGColor
            imageView.layer.borderWidth = 2.0;
            imageView.image = image
            imageView.userInteractionEnabled = true
            /*
            var tapRecognizer = UITapGestureRecognizer(target: self, action: "pointTapped:")
            tapRecognizer.numberOfTapsRequired = 1
            imageView.addGestureRecognizer(tapRecognizer)*/
            imageViews.append(imageView)
            incommingFilesView.addSubview(imageView)
            xOffset+=widthPerItem
        }
        //incommingFilesScrollView.contentSize = CGSizeMake(xOffset, 100)

    }
    
    func addImageToOverlays(image:UIImage)
    {
        var imageData = UIImageJPEGRepresentation(image,0.0);
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        var newfilepointItem = Overlay.createInManagedObjectContext(self.managedObjectContext!,title:"Imported image \(timestamp)",file:imageData)
        save()
        visibleContentView.clearOverlays()
        visibleContentView.fetchOverlays()
        
    }
    
    func addImageToProject(image:UIImage,projectLeaf:ProjectLeaf)
    {
        var imageData = UIImageJPEGRepresentation(image,0.0);
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        //(moc: NSManagedObjectContext, title: String, file: NSData, tags:String, worktype:Int)
        var newImagefileItem = Imagefile.createInManagedObjectContext(self.managedObjectContext!,title:"Imported image \(timestamp)",file:imageData, tags:nil, worktype:workType.info)
        projectLeaf.project.addImagefileToProject(newImagefileItem)
        save()
        
    }
    
    func addImageToFilepoint(image:UIImage,filepointLeaf:FilepointLeaf)
    {
        var imageData = UIImageJPEGRepresentation(image,0.0);
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        
        var newImagefile = Imagefile.createInManagedObjectContext(self.managedObjectContext!, title:"Imported image \(timestamp)",file:imageData, tags: nil, worktype: workType.dokument)
        
        filepointLeaf.filepoint.addImagefile(newImagefile)

        save()
    }
    
    var projectDropLeaf:ProjectLeaf?
    var filepointDropLeaf:FilepointLeaf?
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        self.touchesMoved(touches, withEvent: event)
        
        var touch = touches.anyObject()
        var touchLocation = touch!.locationInView(self.overviewScrollView)
        
        //check overlay node
        
        
        var isInnView = CGRectContainsPoint(visibleContentView.overlayNode.frame,touchLocation)
        if(isInnView)
        {
            println("drop inside overlays")

            addImageToOverlays(currentTouchedImageView!.image!)
            
            currentTouchedImageView?.removeFromSuperview()
            return
        }
        
        //check for project and filepoint nodes
        for projectItem in visibleContentView.projectLeafs
        {
            let projectView = projectItem.button
            var isInnView = CGRectContainsPoint(projectView.frame,touchLocation)
            if(isInnView)
            {
                println("drop inside project")
                projectDropLeaf = projectItem
                addImageToProject(currentTouchedImageView!.image!, projectLeaf: projectDropLeaf!)
                //imit select of project
                visibleContentView.projectSelected(projectDropLeaf!.button)
                
                currentTouchedImageView?.removeFromSuperview()
                return
            }
            else
            {
                for filepointItem in projectItem.filepointLeafs
                {
                    let filepointView = filepointItem.button
                    var isInnView = CGRectContainsPoint(filepointView.frame,touchLocation)
                    if(isInnView)
                    {
                        println("drop inside first-level filepoint")
                        //we only drop on leafs that have childleafs
                        if(filepointItem.filepointLeafs.count > 0)
                        {
                            filepointDropLeaf = filepointItem
                            addImageToFilepoint(currentTouchedImageView!.image!, filepointLeaf: filepointDropLeaf!)
                            visibleContentView.filepointSelectedFromFilepoint(filepointDropLeaf!.button)
                            
                            currentTouchedImageView?.removeFromSuperview()
                            return
                        }
                    }
                    else
                    {
                        if(findFilepointDrop(filepointItem,touchLocation: touchLocation))
                        {
                            return
                        }
                    }
                }
            }
        }

        //if view not found , move view back
        if let view = currentTouchedImageView
        {
            view.removeFromSuperview()
            incommingFilesView.addSubview(view)
            view.center = startPoint
        }
    }
    
    func findFilepointDrop(filepointLeaf:FilepointLeaf,touchLocation:CGPoint) -> Bool
    {
        for filepointItem in filepointLeaf.filepointLeafs
        {
            let filepointView = filepointItem.button
            var isInnView = CGRectContainsPoint(filepointView.frame,touchLocation)
            if(isInnView)
            {
                println("drop inside filepoint")
                //we only drop on leafs that have childleafs
                if(filepointItem.filepointLeafs.count > 0)
                {
                    filepointDropLeaf = filepointItem
                    addImageToFilepoint(currentTouchedImageView!.image!, filepointLeaf: filepointDropLeaf!)
                    visibleContentView.filepointSelectedFromFilepoint(filepointDropLeaf!.button)
                    
                    currentTouchedImageView?.removeFromSuperview()
                    return true
                }
            }
            else
            {
                if(findFilepointDrop(filepointItem,touchLocation: touchLocation))
                {
                    return true
                }
            }
        }
        return false

    }
    
    //MARK: TreeViewProtocol
    func setNewContentSize()
    {
        overviewScrollView.contentSize = visibleContentView.frame.size
        
        let scrollViewFrame = overviewScrollView.frame
        let scaleWidth = scrollViewFrame.size.width / overviewScrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / overviewScrollView.contentSize.height
        let minScale = max(scaleWidth, scaleHeight)
        overviewScrollView.minimumZoomScale = minScale
        overviewScrollView.maximumZoomScale = 1.0
        overviewScrollView.zoomScale = minScale
        
        visibleContentView.setNeedsDisplay()
    }

    //MARK: UIScrollViewDelegate
    
    func centerScrollViewContents() {
        let boundsSize = overviewScrollView.bounds.size
        var contentsFrame = visibleContentView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        visibleContentView.frame = contentsFrame
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView!) -> UIView! {
        return visibleContentView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView!) {
        
        println("zoomscale \(scrollView.zoomScale)")
        //var yVoidOffset = visibleContentView.frame.height < overviewScrollView.frame.height ? (overviewScrollView.frame.height - visibleContentView.frame.height)/2 : 0.0
        //var xVoidOffset = visibleContentView.frame.width < overviewScrollView.frame.width ? (overviewScrollView.frame.width - visibleContentView.frame.width)/2 : 0.0

        centerScrollViewContents()
        visibleContentView.setNeedsDisplay()
    }


    //test
    
    var currentTouchedImageView:UIImageView?
    var startPoint:CGPoint!
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        //var pointLabel = currentFileAndPoints.getLastAddedPointObj().originPointLabel
        
        var touch = touches.anyObject()
        
        var touchLocation = touch!.locationInView(self.incommingFilesView)
        
        for view in imageViews
        {
            var isInnView = CGRectContainsPoint(view.frame,touchLocation)
            
            //if( (touches.anyObject() as UILabel) == pointLabel )
            if(isInnView)
            {
                startPoint = view.center
                currentTouchedImageView = view
                //view.removeFromSuperview()
                self.view.addSubview(currentTouchedImageView!)
                currentTouchedImageView?.center = CGPointMake(currentTouchedImageView!.center.x, currentTouchedImageView!.center.y + yOffset)
                //currentTouchedImageView?.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, UIScreen.mainScreen().bounds.size.height/2)
                
            }
            else
            {
                println("outside touchmoved")
            }
        }
    }
    
    func save() {
        var error : NSError?
        if(managedObjectContext!.save(&error) ) {
            println(error?.localizedDescription)
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent)  {
        
        var touch = touches.anyObject()
        
        
        //var theImageView = touch?.view
        if let view = currentTouchedImageView
        {
            var touchLocation = touch!.locationInView(self.view)
            println("inside touchmoved")
            
            view.center = CGPointMake(touchLocation.x, touchLocation.y)
        }
        
        
    }
    
    func jumpToFilepoint()
    {
        
        let filesViewController = self.storyboard!.instantiateViewControllerWithIdentifier("FilepointViewController") as FilepointViewController
        self.performSegueWithIdentifier("showFilepoint", sender: nil)
    }
    
    func deleteProjectNode()
    {
        var titlePrompt = UIAlertController(title: "Delete",
            message: "Sure you want to delete this project and all its content",
            preferredStyle: .Alert)
        
        titlePrompt.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler: { (action) -> Void in
                self.managedObjectContext?.deleteObject(self.visibleContentView!.currentProjectLeaf.project)
                self.save()
                self.visibleContentView!.removeProjectLeafs_AndProjectButtons()
                self.visibleContentView!.fetchProjects()
                self.visibleContentView!.setNeedsDisplay()
                
                
        }))
        titlePrompt.addAction(UIAlertAction(title: "Cancel",
            style: .Default,
            handler: nil))
        
        
        self.presentViewController(titlePrompt,
            animated: true,
            completion: nil)
        
        visibleContentView.fadeoutActionButtons()
    }
    
    func deleteFilepointNode()
    {
        var titlePrompt = UIAlertController(title: "Delete",
            message: "Sure you want to delete this image and all its content",
            preferredStyle: .Alert)
        
        titlePrompt.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler: { (action) -> Void in
                var parent = self.visibleContentView!.currentFilepointLeaf.filepoint.imagefile!.filepoint
                //println("aaaa parentID \(parent!.objectID) ")
                //println("aaaa basenodeD \(self.visibleContentView!.currentFilepointLeaf!.filepoint.objectID) ")
                self.managedObjectContext?.deleteObject(self.visibleContentView!.currentFilepointLeaf.filepoint)
                self.save()
                if(parent == nil)
                {
                    //TODO: this will never happen with the new structure
                    self.visibleContentView!.removeProjectLeafs_AndProjectButtons()
                    self.visibleContentView!.fetchProjects()
                }
                else
                {
                    self.visibleContentView!.findButtonForFilepointAndSelectIt(parent!)
                }
                
                
        }))
        titlePrompt.addAction(UIAlertAction(title: "Cancel",
            style: .Default,
            handler: nil))
        
        
        self.presentViewController(titlePrompt,
            animated: true,
            completion: nil)
        
        visibleContentView.fadeoutActionButtons()
    }

    func showOverlay()
    {
        visibleContentView.fadeoutActionButtons()
        //TODO:
    }
    
    func setEditOverlay()
    {
        let filesViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MapOverviewViewController") as MapOverviewViewController
        self.performSegueWithIdentifier("showProjectInMap", sender: nil)
    }

    func deleteOverlayNode()
    {
        var titlePrompt = UIAlertController(title: "Delete",
            message: "Sure you want to delete this overlay",
            preferredStyle: .Alert)
        
        titlePrompt.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler: { (action) -> Void in
                var overlay = self.visibleContentView!.getSelectedOverlayNode()
                if(overlay != nil)
                {
                    self.managedObjectContext?.deleteObject(overlay!.overlay)
                    self.save()
                    self.visibleContentView!.clearOverlays()
                    self.visibleContentView!.fetchOverlays()
                }
                
        }))
        titlePrompt.addAction(UIAlertAction(title: "Cancel",
            style: .Default,
            handler: nil))
        
        
        self.presentViewController(titlePrompt,
            animated: true,
            completion: nil)
        
        visibleContentView.fadeoutActionButtons()
    }
    
    override func toTreeView(images:[UIImage]?)
    {
        pdfImages = images
        populatePdfImages()
    }
    
    override func toListView()
    {
        if(self.visibleContentView.currentProjectLeaf != nil || self.visibleContentView.currentFilepointLeaf != nil)
        {
            self.storyboard!.instantiateViewControllerWithIdentifier("FilepointListViewController") as FilepointListViewController
            self.performSegueWithIdentifier("showFilepointList", sender: nil)
        }
        else
        {
            self.storyboard!.instantiateViewControllerWithIdentifier("ProjectListViewController") as ProjectListViewController
            self.performSegueWithIdentifier("showProjectList", sender: nil)
        }
        
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "showFilepoint") {
            var svc = segue!.destinationViewController as FilepointViewController
            svc.currentFilepoint = self.visibleContentView.currentFilepointLeaf.filepoint
        }
        else if (segue.identifier == "showFilepointList") {
            var svc = segue!.destinationViewController as FilepointListViewController
            if(self.visibleContentView.currentFilepointLeaf != nil)
            {
                svc.imagefile = self.visibleContentView.currentFilepointLeaf.filepoint.imagefiles.allObjects.first as Imagefile
            }
                /*
            else if(self.visibleContentView.currentProjectLeaf != nil)
            {
                svc.project = self.visibleContentView.currentProjectLeaf.project
            }
            */
        }
        else if (segue.identifier == "showProjectInMap") {
            var svc = segue!.destinationViewController as MapOverviewViewController
            if let projectLeaf = self.visibleContentView.currentProjectLeaf
            {
                svc.project = projectLeaf.project
   
            }
            if let overlayNode = visibleContentView.getSelectedOverlayNode()
            {
                svc.overlayToSet = overlayNode.overlay
            }
            
            
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}