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
    var incommingFilesViewHeight:CGFloat = 100
    var imageInstancesScrollView:UIScrollView!
    var imageViews:[UIImageView] = []
    var yOffset:CGFloat!
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yOffset = UIScreen.mainScreen().bounds.size.height - (buttonBarHeight * 2)
        incommingFilesView = UIView(frame: CGRectMake(0, yOffset, UIScreen.mainScreen().bounds.size.width , incommingFilesViewHeight))
        incommingFilesView.hidden = true
        incommingFilesView.layer.borderColor = UIColor.grayColor().CGColor
        incommingFilesView.layer.borderWidth = 2.0;

        self.view.addSubview(incommingFilesView)
        
        var viewFrame = self.view.frame

        topNavigationBar.showForViewtype(.tree)

        let strechedHeight = UIScreen.mainScreen().bounds.size.height - buttonBarHeight
        overviewScrollView = UIScrollView(frame: CGRectMake(0, buttonBarHeight, UIScreen.mainScreen().bounds.size.width, strechedHeight))
        overviewScrollView.backgroundColor = UIColor.whiteColor()
        visibleContentView = TreeView(frame: CGRectMake(0, 0, overviewScrollView.frame.size.width , overviewScrollView.frame.size.height ),delegate:self)
        visibleContentView.backgroundColor = UIColor.clearColor()
        //visibleContentView.delegate = self
        //overviewScrollView.clipsToBounds = true
        //overviewScrollView.autoresizesSubviews = false
        overviewScrollView.addSubview(visibleContentView)
        overviewScrollView.contentSize = visibleContentView.bounds.size
        
        if(passingFilepoint != nil)
        {
            
            //MARK: TODO: select given leaf
            /*
            visibleContentView.currentFilepointLeaf = FilepointLeaf(_filePoint:passingFilepoint!,_parent:nil,viewRef:nil)
            visibleContentView.buildNodesUpToSelectedNode_V2()
            visibleContentView.setNeedsDisplay()
            */
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
    
    func showImageInstancesScrollView(pointLeaf:PointLeaf)
    {
        setTreeviewScrollViewSizeSmall()

        /*
        var imageInstances:[ImageInstanceWithIcon]? = []
        for imagefile in pointLeaf.project!.imagefiles
        {
            let imageView = ImageInstanceWithIcon(frame: CGRectMake(0, 0, imageinstanceSideBig, imageinstanceSideBig),imagefile: imagefile as Imagefile)
            imageInstances?.append(imageView)
        }
*/
        
        
        if(imageInstancesScrollView != nil)
        {
            imageInstancesScrollView.removeFromSuperview()
            imageInstancesScrollView = nil
        }
        if pointLeaf.imageInstances?.count > 0
        {
            
            imageInstancesScrollView = UIScrollView(frame: CGRectMake(0, self.view.frame.height - 100, self.view.frame.width, 100))
            imageInstancesScrollView.contentSize = CGSizeMake(CGFloat(pointLeaf.imageInstances!.count) * 100, 100)
            imageInstancesScrollView.delegate = self
            
            var index:CGFloat = 0
            for imageView in pointLeaf.imageInstances!
            {
                var newImageView = ImageInstanceWithIcon(frame: CGRectMake(0, 0, imageinstanceSideBig, imageinstanceSideBig),imagefile: imageView.imagefile)
                newImageView.frame = CGRectMake(0, 0, imageinstanceSideBig, imageinstanceSideBig)
                //
                
                //imageView.transform = CGAffineTransformIdentity
                newImageView.center = CGPointMake((newImageView.frame.width / 2) + (index * imageinstanceSideBig), newImageView.frame.height / 2)
                index++
                
                var tapRecognizer = UITapGestureRecognizer(target: self, action: "imageinstancesTapped:")
                tapRecognizer.numberOfTapsRequired = 1
                newImageView.addGestureRecognizer(tapRecognizer)
                
                self.imageInstancesScrollView.addSubview(newImageView)
                if(pointLeaf.currentImage == imageView.imagefile)
                {
                    newImageView.layer.borderColor = UIColor.greenColor().CGColor
                    newImageView.layer.borderWidth = 2.0;
                }
            }

            /*
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                var index:CGFloat = 0
                for imageView in self.imageInstances!
                {
                    imageView.transform = CGAffineTransformIdentity
                    imageView.center = CGPointMake(self.imageInstancesScrollView.frame.origin.x + (imageView.frame.width / 2) + (index * imageinstanceSideBig),self.imageInstancesScrollView.frame.origin.y +  imageView.frame.height / 2)
                    if imageView.imagefile == self.currentImagefile
                    {
                        imageView.layer.borderColor = UIColor.greenColor().CGColor
                        imageView.layer.borderWidth = 2.0;
                    }
                    index++
                    
                }
                
                }, completion: { (value: Bool) in
                    
                    var index:CGFloat = 0
                    for imageView in self.imageInstances!
                    {
                        imageView.transform = CGAffineTransformIdentity
                        imageView.center = CGPointMake((imageView.frame.width / 2) + (index * imageinstanceSideBig), imageView.frame.height / 2)
                        index++
                        
                        var tapRecognizer = UITapGestureRecognizer(target: self, action: "imageinstancesBigTapped:")
                        tapRecognizer.numberOfTapsRequired = 1
                        imageView.addGestureRecognizer(tapRecognizer)
                        
                        self.imageInstancesScrollView.addSubview(imageView)
                    }
            })*/
            
            
            self.view.addSubview(imageInstancesScrollView)
        }
    }
    
    func hideImageInstancesScrollView()
    {
        setTreeviewScrollViewSizeBig()

        if(imageInstancesScrollView != nil)
        {
            imageInstancesScrollView.removeFromSuperview()
            imageInstancesScrollView = nil
        }
    }
    
    func imageinstancesTapped(sender:UITapGestureRecognizer)
    {
        for view in self.imageInstancesScrollView.subviews
        {
            (view as UIView).layer.borderWidth = 0
        }
        
        if let imageInstanceWithIcon = sender.view as? ImageInstanceWithIcon
        {
            imageInstanceWithIcon.layer.borderColor = UIColor.greenColor().CGColor
            imageInstanceWithIcon.layer.borderWidth = 2.0
            visibleContentView.findPointLeafForImagefileAndSetNewCurrentImageInstance(imageInstanceWithIcon.imagefile)
            
            //hideImageInstancesScrollView()
        }
    }
    
    func setContentsize(size:CGSize)
    {
        overviewScrollView.contentSize = size
    }
    
    func setTreeviewScrollViewSizeSmall()
    {
        let strechedHeight = UIScreen.mainScreen().bounds.size.height - buttonBarHeight - incommingFilesViewHeight
        overviewScrollView.frame.size = CGSizeMake(UIScreen.mainScreen().bounds.size.width, strechedHeight)
    }
    
    func setTreeviewScrollViewSizeBig()
    {
        let strechedHeight = UIScreen.mainScreen().bounds.size.height - buttonBarHeight
        overviewScrollView.frame.size = CGSizeMake(UIScreen.mainScreen().bounds.size.width, strechedHeight)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if(scrollView == overviewScrollView)
        {

        }

    }
    
    
    func populatePdfImages()
    {
        if(pdfImages == nil)
        {
            return
        }
        
        
        //set up frame for treeview
        setTreeviewScrollViewSizeSmall()
        
        incommingFilesView.hidden = false
        self.view.bringSubviewToFront(incommingFilesView)
        var xOffset:CGFloat = 0
        var widthPerItem:CGFloat = pdfImages!.count < 3 ? incommingFilesViewHeight : UIScreen.mainScreen().bounds.size.width / CGFloat(pdfImages!.count)
        for image in pdfImages!
        {
            var imageView = UIImageView(frame: CGRectMake(xOffset, 0, incommingFilesViewHeight, widthPerItem))
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
    
    func addImageToProject(image:UIImage,projectLeaf:PointLeaf)
    {
        var imageData = UIImageJPEGRepresentation(image,0.0);
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        //(moc: NSManagedObjectContext, title: String, file: NSData, tags:String, worktype:Int)
        var newImagefile = Imagefile.createInManagedObjectContext(self.managedObjectContext!,title:"Imported image \(timestamp)",file:imageData, tags:nil, worktype:workType.dokument)
        projectLeaf.project!.addImagefile(newImagefile)
        save()
    }
    
    func addImageToFilepoint(image:UIImage,filepointLeaf:PointLeaf) 
    {
        var imageData = UIImageJPEGRepresentation(image,0.0);
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        var newImagefile = Imagefile.createInManagedObjectContext(self.managedObjectContext!, title:"Imported image \(timestamp)",file:imageData, tags: nil, worktype: workType.dokument)
        filepointLeaf.filepoint!.addImagefile(newImagefile)
        save()
    }
    
    var projectDropLeaf:PointLeaf?
    var filepointDropLeaf:PointLeaf?
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        self.touchesMoved(touches, withEvent: event)
        
        var touch = touches.anyObject()
        var touchLocation = touch!.locationInView(self.overviewScrollView)
        
        //check overlay node
        
        
        var isInnView = CGRectContainsPoint(visibleContentView.overlayDropzone.frame,touchLocation)
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

            var isInnView = CGRectContainsPoint(projectItem.frame,touchLocation)
            if(isInnView)
            {
                if(currentTouchedImageView == nil)
                {
                    println("no touched imageView")
                    return
                }
                println("drop inside project")
                addImageToProject(currentTouchedImageView!.image!, projectLeaf: projectItem)
                //imit select of project
                //TODO: reload images
                //visibleContentView.projectSelected(projectDropLeaf!)
                projectItem.reloadImageInstances()
                currentTouchedImageView?.removeFromSuperview()
                return
            }
            else
            {
                for filepointItem in projectItem.pointLeafs
                {
                    var isInnView = CGRectContainsPoint(filepointItem.frame,touchLocation)
                    if(isInnView)
                    {
                        println("drop inside first-level filepoint")

                        filepointDropLeaf = filepointItem
                        addImageToFilepoint(currentTouchedImageView!.image!, filepointLeaf: filepointItem)
                        //visibleContentView.filepointSelectedFromFilepoint(filepointItem)
                        filepointItem.reloadImageInstances()
                        currentTouchedImageView?.removeFromSuperview()
                        return
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
    
    func findFilepointDrop(filepointLeaf:PointLeaf,touchLocation:CGPoint) -> Bool
    {
        for filepointItem in filepointLeaf.pointLeafs
        {
            var isInnView = CGRectContainsPoint(filepointItem.frame,touchLocation)
            if(isInnView)
            {
                println("drop inside filepoint")

                addImageToFilepoint(currentTouchedImageView!.image!, filepointLeaf: filepointItem)
                //visibleContentView.filepointSelectedFromFilepoint(filepointDropLeaf!)
                filepointItem.reloadImageInstances()
                currentTouchedImageView?.removeFromSuperview()
                return true
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
            message: "Sure you want to delete this image and all its content",
            preferredStyle: .Alert)
        
        titlePrompt.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler: { (action) -> Void in
                //if less than 2 images we might ass well delete the whole node
                if(self.visibleContentView!.currentProjectLeaf.project?.imagefiles.count < 2)
                {
                    self.visibleContentView!.removePointLeaf(self.visibleContentView!.currentProjectLeaf)
                    self.managedObjectContext?.deleteObject(self.visibleContentView!.currentProjectLeaf.project!)
                    self.save()
                    
                }
                else
                {
                    self.visibleContentView!.removePointLeafChildren(self.visibleContentView!.currentProjectLeaf)
                    self.managedObjectContext?.deleteObject(self.visibleContentView!.currentProjectLeaf.currentImage)
                    self.save()
                    self.visibleContentView!.currentProjectLeaf.reloadImageInstances()
                }
                
                //self.visibleContentView!.removeProjectLeafs_AndProjectButtons()
                //self.visibleContentView!.fetchProjects()
                self.visibleContentView!.setNeedsDisplay()
                
                
        }))
        titlePrompt.addAction(UIAlertAction(title: "Cancel",
            style: .Default,
            handler: nil))
        
        
        self.presentViewController(titlePrompt,
            animated: true,
            completion: nil)
        
    }
    
    //MARK: TODO: rename to delete imageinstance
    func deleteFilepointNode()
    {
        var titlePrompt = UIAlertController(title: "Delete",
            message: "Sure you want to delete this image and all its content",
            preferredStyle: .Alert)
        
        titlePrompt.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler: { (action) -> Void in
                /*
                var parent = self.visibleContentView!.currentFilepointLeaf.filepoint!.imagefile!.filepoint
                self.managedObjectContext?.deleteObject(self.visibleContentView!.currentFilepointLeaf.filepoint!)
                self.save()
                if(parent == nil)
                {
                    //TODO: this will never happen with the new structure
                    self.visibleContentView!.removeProjectLeafs_AndProjectButtons()
                    self.visibleContentView!.fetchProjects()
                }
                else
                {
                    self.visibleContentView!.findLeafForFilepointAndSelectIt(parent!)
                }
                */
                //if less than 2 images we might ass well delete the whole node
                if(self.visibleContentView!.currentFilepointLeaf.imageInstances.count < 2)
                {
                    self.visibleContentView!.removePointLeaf(self.visibleContentView!.currentFilepointLeaf)
                    self.managedObjectContext?.deleteObject(self.visibleContentView!.currentFilepointLeaf.filepoint!)
                    self.save()
                }
                else
                {
                    self.visibleContentView!.removePointLeafChildren(self.visibleContentView!.currentFilepointLeaf)
                    self.managedObjectContext?.deleteObject(self.visibleContentView!.currentFilepointLeaf.currentImage)
                    self.save()
                    self.visibleContentView!.currentFilepointLeaf.reloadImageInstances()
                }
                
                self.visibleContentView!.setNeedsDisplay()
                
        }))
        titlePrompt.addAction(UIAlertAction(title: "Cancel",
            style: .Default,
            handler: nil))
        
        
        self.presentViewController(titlePrompt,
            animated: true,
            completion: nil)
        
    }

    func showOverlay()
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
            if let pointLeaf = self.visibleContentView.currentFilepointLeaf
            {
                svc.currentFilepoint = pointLeaf.filepoint
                svc.currentImagefile = pointLeaf.currentImage
            }
            else if let projectLeaf = self.visibleContentView.currentProjectLeaf
            {
                svc.project = projectLeaf.project
                svc.currentImagefile = projectLeaf.currentImage
                svc.oneLevelFromProject = true
            }
        }
        else if (segue.identifier == "showFilepointList") {
            var svc = segue!.destinationViewController as FilepointListViewController
            if(self.visibleContentView.currentFilepointLeaf != nil)
            {
                svc.imagefile = self.visibleContentView.currentFilepointLeaf.filepoint!.imagefiles.allObjects.first as Imagefile
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