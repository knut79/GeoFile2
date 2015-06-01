//
//  TreeView.swift
//  GeoFile
//
//  Created by knut on 22/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
import CoreData

protocol TreeViewProtocol
{
    func jumpToFilepoint()
    func showOverlay()
    func setEditOverlay()
    func deleteFilepointNode()
    func deleteProjectNode()
    func deleteOverlayNode()
    func setContentsize(size:CGSize)
    func showImageInstancesScrollView(pointLeaf:PointLeaf)
    func hideImageInstancesScrollView()
    func setTreeviewScrollViewSizeBig()
    func setTreeviewScrollViewSizeSmall()
}

class TreeView:UIView, PointLeafProtocol
{

    var imageViewTest:UIImageView!
    //var projectButtons:[UIButton] = []
    var delegate:TreeViewProtocol?
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var projectLeafs = [PointLeaf]()
    var overlayLeafs = [OverlayLeaf]()
    var currentFilepointLeaf:PointLeaf!
    var currentProjectLeaf:PointLeaf!
    var selectedLeaf:UIView!
    var overlayDropzone:OverlayDropzone!
    
    var jumpToFilepointButton:UIButton!
    var deleteNodeButton:UIButton!
    var setEditNodeButton:UIButton!
    
    
    init(frame: CGRect, delegate: TreeViewProtocol) {
        super.init(frame: frame)

        
        self.delegate = delegate
        selectedLeaf = UIView(frame: CGRectMake(0, 0, leafSize.width + 4, leafSize.height + 4))
        selectedLeaf.hidden = true
        selectedLeaf.layer.cornerRadius = 5
        selectedLeaf.clipsToBounds = true
        selectedLeaf.backgroundColor = UIColor.redColor()
        self.addSubview(selectedLeaf)
        
        jumpToFilepointButton = CustomButton(frame: CGRectMake(0, 0, 75, buttonBarHeight))
        jumpToFilepointButton.setTitle("Show", forState: UIControlState.Normal)
        jumpToFilepointButton.alpha = 0
        jumpToFilepointButton.layer.cornerRadius = 5
        jumpToFilepointButton.clipsToBounds = true
        jumpToFilepointButton.addTarget(self, action: "showNode", forControlEvents: .TouchUpInside)
        self.addSubview(jumpToFilepointButton)
        
        deleteNodeButton = CustomButton(frame: CGRectMake(0, 0, 75, buttonBarHeight))
        deleteNodeButton.setTitle("Delete", forState: UIControlState.Normal)
        deleteNodeButton.alpha = 0
        deleteNodeButton.layer.cornerRadius = 5
        deleteNodeButton.clipsToBounds = true
        deleteNodeButton.addTarget(self, action: "deleteNode", forControlEvents: .TouchUpInside)
        self.addSubview(deleteNodeButton)
        
        setEditNodeButton = CustomButton(frame: CGRectMake(0, 0, 75, buttonBarHeight))
        setEditNodeButton.setTitle("Set/Edit", forState: UIControlState.Normal)
        setEditNodeButton.alpha = 0
        setEditNodeButton.layer.cornerRadius = 5
        setEditNodeButton.clipsToBounds = true
        setEditNodeButton.addTarget(self, action: "setEditNode", forControlEvents: .TouchUpInside)
        self.addSubview(setEditNodeButton)
        
        
        //populateTestOverlays()
        
        
        fetchOverlays()
        fetchProjects()

    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func drawRect(rect: CGRect) {
        //[[UIColor brownColor] set];

        var currentContext = UIGraphicsGetCurrentContext()
        CGContextSetLineCap(currentContext, kCGLineCapRound)
        for item in projectLeafs
        {
            drawFilepointsFromProject(currentContext,projectLeaf: item)
        }
        
        //draw for overlaynodes
        CGContextSetLineWidth(currentContext,3.0)
        var ra:[CGFloat] = [6,6]
        CGContextSetLineDash(currentContext, 0.0, ra, 2);
        var fromX = overlayDropzone.center.x
        var fromY = overlayDropzone.center.y
        CGContextMoveToPoint(currentContext,fromX, fromY)
        for item in overlayLeafs
        {
            var toX = item.center.x
            var toY = item.center.y
            CGContextAddLineToPoint(currentContext,toX, toY)
            CGContextStrokePath(currentContext)
            CGContextMoveToPoint(currentContext,toX, toY)
        }
    }
    
    func drawFilepointsFromProject(currentContext:CGContext, projectLeaf:PointLeaf)
    {
        CGContextSetLineCap(currentContext, kCGLineCapRound)
        if(projectLeaf.pointLeafs.count > 0)
        {
            CGContextSetLineWidth(currentContext,3.0)
            //draw horizontal line
            var x:CGFloat = projectLeaf.center.x
            var y = projectLeaf.center.y
            var drawToX:CGFloat = x + projectLeaf.frame.width //x + (horizontalLineLength/2)
            CGContextMoveToPoint(currentContext,x, y);
            CGContextAddLineToPoint(currentContext,drawToX, y);
            CGContextStrokePath(currentContext);
        }
        
        var selectedItem:PointLeaf?
        for item in projectLeaf.pointLeafs
        {
            //draw horizontal line backwards
            CGContextSetLineWidth(currentContext,3.0)
            //var x = item.frame.minX
            var x = item.center.x
            var y = item.center.y
            var drawToX = x -  (item.frame.width / 2) //( horizontalLineLength / 2 )
            CGContextMoveToPoint(currentContext,x, y)
            CGContextAddLineToPoint(currentContext,drawToX, y);
            CGContextStrokePath(currentContext);
            

            drawFilepointsFromFilepoint(currentContext,filepointLeaf: item)
          
        }
        
        //vertical line
        if let item = projectLeaf.pointLeafs.first
        {
            var firstItem = item as PointLeaf
            var fromX = firstItem.frame.minX
            var fromY = firstItem.center.y
            CGContextMoveToPoint(currentContext,fromX, fromY);
            
            //var lastButtonItem = selectedItem == nil ? projectLeaf.filepointLeafs.last!.button : selectedItem!.button
            var lastItem = projectLeaf.pointLeafs.last!
            var toX = lastItem.frame.minX 
            var toY = lastItem.center.y
            CGContextAddLineToPoint(currentContext,toX, toY)
            CGContextStrokePath(currentContext)
        }
        

    }
    
    
    func drawFilepointsFromFilepoint(currentContext:CGContext, filepointLeaf:PointLeaf)
    {
        CGContextSetLineCap(currentContext, kCGLineCapRound)
        if(filepointLeaf.pointLeafs.count > 0)
        {
            //draw horizontal line
            let item = filepointLeaf
            CGContextSetLineWidth(currentContext,3.0)
            var x = item.center.x
            var y = item.center.y
            var drawToX = x + filepointLeaf.frame.width //( horizontalLineLength / 2 )
            CGContextMoveToPoint(currentContext,x, y);
            CGContextAddLineToPoint(currentContext,drawToX, y);
            CGContextStrokePath(currentContext);
        }
        
        var selectedItem:PointLeaf?
        for item in filepointLeaf.pointLeafs
        {
            //draw horizontal line
            if(item.isDescendantOfView(self))
            {
                //var lengths:[CGFloat] = [CGFloat(0),CGFloat(0.5 * 2)]
                //CGContextSetLineDash(currentContext, 0.0, lengths, 2)
                if(item.filepoint!.x != 0 && item.filepoint!.y != 0)
                {
                    CGContextSetLineWidth(currentContext,3.0)
                    var x = item.center.x
                    var y = item.center.y
                    var drawToX = x - (item.frame.width / 2) //( horizontalLineLength / 2 )
                    CGContextMoveToPoint(currentContext,x, y)
                    CGContextAddLineToPoint(currentContext,drawToX, y)
                    CGContextStrokePath(currentContext);
                }
            }


            drawFilepointsFromFilepoint(currentContext,filepointLeaf: item)

        }
        
        //vertical line
        if let item = filepointLeaf.pointLeafs.first
        {
            var firstItem = item
            var fromX = firstItem.frame.minX //+ (horizontalLineLength/2)
            var fromY = firstItem.center.y
            CGContextMoveToPoint(currentContext,fromX, fromY);
        

            //var lastButtonItem = getLastFilepointWithCoordinates(filepointLeaf).button
            var lastItem = filepointLeaf.pointLeafs.last!
            var toX = lastItem.frame.minX // (horizontalLineLength/2)
            var toY = lastItem.center.y
            CGContextAddLineToPoint(currentContext,toX, toY)
            CGContextStrokePath(currentContext)
        }

    }
    
    func getLastFilepointWithCoordinates(filepointLeaf:PointLeaf) -> PointLeaf
    {
        var lastNodeWithCoordinates = filepointLeaf.pointLeafs.first
        for var i = 0; i < filepointLeaf.pointLeafs.count ; i++
        {
            if(filepointLeaf.pointLeafs[i].filepoint!.x == 0 && filepointLeaf.pointLeafs[i].filepoint!.y == 0)
            {
                if(i > 0)
                {
                    lastNodeWithCoordinates = filepointLeaf.pointLeafs[i-1]
                    break
                }
            }
        }
        return lastNodeWithCoordinates!
    }
    
    func addOverlayNode()
    {
        overlayDropzone = OverlayDropzone(frame: CGRectMake(0, 0, leafSize.width, leafSize.height))
        overlayDropzone.center =  CGPointMake((UIScreen.mainScreen().bounds.size.width * 0.1) + (overlayDropzone.frame.size.width/2), (self.frame.minY) + (overlayDropzone.frame.size.height/2))
        self.addSubview(overlayDropzone)
    }
        
    func populateTestOverlays()
    {
        var image = UIImage(named: "pictureOverviewSmall.png")
        var imageData = UIImageJPEGRepresentation(image,0.0)
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        var newfilepointItem = Overlay.createInManagedObjectContext(self.managedObjectContext!,title:"Imported image \(timestamp)",file:imageData)
        save()
    }
    
    func clearOverlays()
    {
        for var i = 0 ; i < overlayLeafs.count ; i++
        {
            overlayLeafs[i].removeFromSuperview()
        }
        overlayLeafs = []
        
    }
    func fetchOverlays()
    {
        
        addOverlayNode()
        let fetchRequest = NSFetchRequest(entityName: "Overlay")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Overlay] {
            var i = 1
            for item in fetchResults
            {
                var node = OverlayLeaf(overlay:item as Overlay, viewRef:self)
                node.center =  CGPointMake(overlayDropzone.center.x + (node.frame.width * CGFloat(i)),  overlayDropzone.center.y)
                overlayLeafs.append(node)
                expandContentsize(node.frame)
                self.addSubview(node)
                
                i++
            }
        }
    }
    
    func fetchProjects()
    {
        projectLeafs = []
        let fetchRequest = NSFetchRequest(entityName: "Project")
        let overlayNodeMargin = overlayDropzone.frame.height
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Project] {
            var i = 0
            for item in fetchResults
            {

                let newProjectLeaf = PointLeaf(_project:item, viewRef:self)
                projectLeafs.append(newProjectLeaf)

                
                newProjectLeaf.center = CGPointMake((UIScreen.mainScreen().bounds.size.width * 0.1) + (leafSize.width/2), (UIScreen.mainScreen().bounds.size.height * 0.2) + ((leafSize.height ) * CGFloat(i)) + overlayNodeMargin)
                
                expandContentsize(newProjectLeaf.frame)
                self.addSubview(newProjectLeaf)
                i++
            }

        }
        self.setNeedsDisplay()
    }
    
    func expandContentsize(rect:CGRect)
    {
        let newWidth = self.frame.width < rect.maxX ? rect.maxX : self.frame.width
        let newHeight = self.frame.height < rect.maxY ? rect.maxY : self.frame.height
        
        println(" new maxx and y \(rect.maxX) \(rect.maxY)")
        var newSize  = CGSizeMake(newWidth + elementMargin, newHeight + elementMargin)
        self.frame.size = newSize
        
        
        println(" new self.frame \(self.frame.origin.x) \(self.frame.origin.y) \(self.frame.width) \(self.frame.height)")
        delegate?.setContentsize(newSize)
    }

    
    func fetchFilepointsFromProject()
    {
        let xOffset = currentProjectLeaf.center.x
        let yOffset = currentProjectLeaf.center.y
        var i = 0
        if let currentImagefile = currentProjectLeaf.currentImage //.project!.firstImagefile
        {
            for item in currentImagefile.filepoints
            {
                let filepointLeaf = PointLeaf(_filePoint:item as Filepoint,_parent:nil,viewRef:self)
                currentProjectLeaf.pointLeafs.append(filepointLeaf)
                filepointLeaf.center = CGPointMake(filepointLeaf.frame.width + xOffset, yOffset + ((filepointLeaf.frame.height) * CGFloat(i)))
                expandContentsize(filepointLeaf.frame)
                self.addSubview(filepointLeaf)
                i++

            }
        }
        
    }
    
    func fetchFilepointsFromFilepoint(filepointLeaf:PointLeaf)
    {
        let xOffset = filepointLeaf.center.x
        let yOffset = filepointLeaf.center.y
        var i = 0
        for item in filepointLeaf.currentImage!.filepoints
        {
            let newFilepointLeaf = PointLeaf(_filePoint:item as Filepoint,_parent:nil,viewRef:self)
            filepointLeaf.pointLeafs.append(newFilepointLeaf)
            newFilepointLeaf.center = CGPointMake(xOffset + leafSize.width, yOffset + ((leafSize.height) * CGFloat(i)))
            expandContentsize(newFilepointLeaf.frame)
            self.addSubview(newFilepointLeaf)
            
            i++
        }
    }
   
    
    
    func findSelecedFilepointLeaf(filepointLeaf:PointLeaf, pointLeafPushed:PointLeaf)
    {
        fadeoutActionButtons()
        
        var filepointLeafs = filepointLeaf.pointLeafs
        for var i = 0 ; i < filepointLeafs.count ; i++
        {
            if(filepointLeafs[i] == pointLeafPushed)
            {
                currentFilepointLeaf = filepointLeafs[i]
                selectedLeaf.hidden = false
                selectedLeaf.center = currentFilepointLeaf.center
            }
            else
            {
                findSelecedFilepointLeaf(filepointLeafs[i],pointLeafPushed: pointLeafPushed)
            }

        }
    }
    

    
    func unselectAllLeafsOnCurrentProjectLeaf()
    {
        for item in currentProjectLeaf.pointLeafs
        {
            item.unselectLeaf()
            
            unselectAllLeafsOnPointLeaf(item as PointLeaf)
            /*
            if(item != currentFilepointLeaf)
            {
                item.unselectLeaf()
            }
            */
        }
    }
    
    func unselectAllLeafsOnPointLeaf(pointLeaf:PointLeaf)
    {
        for item in pointLeaf.pointLeafs
        {
            item.unselectLeaf()
            
            unselectAllLeafsOnPointLeaf(item as PointLeaf)
            /*
            if(item != currentFilepointLeaf)
            {
            item.unselectLeaf()
            }
            */
        }
    }
    
    func findLeafForFilepointAndSelectIt(filepointToCheck:Filepoint, pointLeafs:[PointLeaf]? = nil)
    {
        var _pointsLeafs = pointLeafs ?? currentProjectLeaf.pointLeafs!

        for item in _pointsLeafs
        {
            if(item.filepoint!.objectID == filepointToCheck.objectID)
            {
                filepointSelectedFromFilepoint(item)
            }
            else
            {
                findLeafForFilepointAndSelectIt(filepointToCheck, pointLeafs: item.pointLeafs)
            }
        }
    }
    
    func unselectAllOverlayLeafs()
    {
        for var i = 0 ; i < overlayLeafs.count ; i++
        {
            overlayLeafs[i].selected = false
        }
    }
    
    func getSelectedOverlayNode() -> OverlayLeaf?
    {
        for var i = 0 ; i < overlayLeafs.count ; i++
        {
            if(overlayLeafs[i].selected)
            {
                return overlayLeafs[i]
            }
        }
        return nil
    }
 
    func overlaySelected(sender:UITapGestureRecognizer)
    {
        var overlayLeaf = sender.view?.superview as OverlayLeaf
        
        for item in overlayLeafs
        {
            if(item != overlayLeaf)
            {
                item.unselectLeaf()
            }
        }
        
        for item in projectLeafs
        {
            item.unselectLeaf()
        }
        /*
        for item in currentProjectLeaf.pointLeafs
        {
            if(item != currentFilepointLeaf)
            {
                item.unselectLeaf()
            }
        }
        */
        overlayLeaf.selectLeaf()
        
        setNeedsDisplay()
        
        //remove imageinstances from scrollview
        //delegate!.setScrollViewSize(CGSizeMake(self.frame.width, self.frame.height))
    }
    
    var actionForOverlay = false
    func showActionButtonsForOverlay(sender:UITapGestureRecognizer)
    {
        var node = sender.view
        if(node != nil)
        {
            actionForOverlay = true
            self.bringSubviewToFront(deleteNodeButton)
            var deleteNodeButtonY = node!.center.y + (node!.frame.height * 2)
            var deleteNodeButtonX = node!.center.x > self.frame.width / 2 ? node!.center.x - node!.frame.width : node!.center.x + node!.frame.width
            deleteNodeButton.alpha = 0.75
            deleteNodeButton.center = CGPointMake(deleteNodeButtonX,deleteNodeButtonY)
            
            self.bringSubviewToFront(jumpToFilepointButton)
            jumpToFilepointButton.alpha = 0.75
            jumpToFilepointButton.center = CGPointMake(deleteNodeButton.center.x,deleteNodeButton.center.y - deleteNodeButton.frame.height - 2 )
            
            self.bringSubviewToFront(setEditNodeButton)
            setEditNodeButton.alpha = 0.75
            setEditNodeButton.center = CGPointMake(jumpToFilepointButton.center.x,jumpToFilepointButton.center.y - jumpToFilepointButton.frame.height - 2 )
            
            unselectAllOverlayLeafs()
            
            (node as OverlayLeaf).selected = true
        }
        
    }
    
    func showActionButtonsForProject(sender:AnyObject)
    {
        //TODO: should handle doubletap of nodes that are not selected
        if(currentProjectLeaf != nil)
        {
            self.bringSubviewToFront(deleteNodeButton)
            var buttonY = currentProjectLeaf.center.y > self.frame.height / 2 ? currentProjectLeaf.center.y - currentProjectLeaf.frame.height : currentProjectLeaf.center.y + currentProjectLeaf.frame.height
            var buttonX = currentProjectLeaf.center.x > self.frame.width / 2 ? currentProjectLeaf.center.x - currentProjectLeaf.frame.width : currentProjectLeaf.center.x + currentProjectLeaf.frame.width
            deleteNodeButton.alpha = 0.75
            deleteNodeButton.center = CGPointMake(buttonX,buttonY)
        }
    }
    
    func showActionButtonsForFilepoint(sender:AnyObject)
    {
        //TODO: should handle doubletap of nodes that are not selected
        if(currentFilepointLeaf != nil)
        {
            self.bringSubviewToFront(deleteNodeButton)
            var jumpToFilepointButtonY = currentFilepointLeaf.center.y > self.frame.height / 2 ? currentFilepointLeaf.center.y - currentFilepointLeaf.frame.height : currentFilepointLeaf.center.y + currentFilepointLeaf.frame.height
            var jumpToFilepointButtonX = currentFilepointLeaf.center.x > self.frame.width / 2 ? currentFilepointLeaf.center.x - currentFilepointLeaf.frame.width : currentFilepointLeaf.center.x + currentFilepointLeaf.frame.width
            deleteNodeButton.alpha = 0.75
            deleteNodeButton.center = CGPointMake(jumpToFilepointButtonX,jumpToFilepointButtonY)
            
            self.bringSubviewToFront(jumpToFilepointButton)
            jumpToFilepointButton.alpha = 0.75
            jumpToFilepointButton.center = CGPointMake(deleteNodeButton.center.x,deleteNodeButton.center.y - deleteNodeButton.frame.height - 2 )
        }
    }
    
    
    func projectSelected(sender:UITapGestureRecognizer)
    {
        currentFilepointLeaf = nil
        fadeoutActionButtons()
        var selectedProjectLeaf = (sender as UITapGestureRecognizer).view?.superview
        projectSelected(selectedProjectLeaf as PointLeaf)
    }
    
    func projectSelected(pointLeaf:PointLeaf)
    {
        //remove all buttons
        removeProjectLeafChildren()
        
        for item in projectLeafs
        {
            if(item == pointLeaf)
            {
                item.selectLeaf()
            }
            else
            {
                item.unselectLeaf()
            }
        }

        currentProjectLeaf = pointLeaf
        fetchFilepointsFromProject()
        setNeedsDisplay()
        delegate?.showImageInstancesScrollView(currentProjectLeaf)
    }
    
    func filepointSelectedFromFilepoint(sender:UITapGestureRecognizer)
    {
        //fadeoutActionButtons()
        
        var selectedFilepointLeaf = (sender as UITapGestureRecognizer).view?.superview
        filepointSelectedFromFilepoint(selectedFilepointLeaf as PointLeaf)
    }
    
    func filepointSelectedFromFilepoint(selectedFilepointLeaf:PointLeaf)
    {
        currentFilepointLeaf = selectedFilepointLeaf
        
        for item in projectLeafs
        {
            item.unselectLeaf()
        }
        unselectAllLeafsOnCurrentProjectLeaf()
        
        //buildNodesUpToSelectedNode()
        buildForNode(currentFilepointLeaf)
        currentFilepointLeaf.selectLeaf()
        
        setNeedsDisplay()
        delegate?.showImageInstancesScrollView(currentFilepointLeaf)

        
    }

    func getProjectleafForFilepoint(_filepoint:Filepoint) -> PointLeaf?
    {
        for projectLeaf in projectLeafs
        {
            for filepoint in projectLeaf.currentImage!.filepoints
            {
                if(isOnBranchWith(filepoint as Filepoint, onBranchWith:_filepoint))
                {
                    return projectLeaf
                }
            }
        }
        return nil
    }
    
    //base ass in checking from projectleafs
    func getFilepointLeafForFilepointBase(_filepoint:Filepoint) -> PointLeaf?
    {
        var filepointLeafToReturn:PointLeaf?
        for projectLeaf in projectLeafs
        {
            for filepointLeaf in projectLeaf.pointLeafs
            {
                filepointLeafToReturn = getFilepointLeafForFilepoint(_filepoint,filepointLeafBase: filepointLeaf)

                if(filepointLeafToReturn != nil)
                {
                    break
                }
            }
            if(filepointLeafToReturn != nil)
            {
                break
            }
        }
        return filepointLeafToReturn
    }
    
    func getFilepointLeafForFilepoint(_filepoint:Filepoint, filepointLeafBase:PointLeaf) -> PointLeaf?
    {
        if(filepointLeafBase.filepoint == _filepoint)
        {
            return filepointLeafBase
        }
        
        var filepointLeafToReturn:PointLeaf?
        for filepointLeaf in filepointLeafBase.pointLeafs
        {
            if(filepointLeaf.filepoint == _filepoint)
            {
                filepointLeafToReturn = filepointLeaf
                break
            }
            else
            {
                filepointLeafToReturn = getFilepointLeafForFilepoint(_filepoint,filepointLeafBase: filepointLeaf)
            }
            
            if(filepointLeafToReturn != nil)
            {
                return filepointLeafToReturn
            }

        }
        return filepointLeafToReturn
    }
    
    
    
    func buildNodesUpToSelectedNode_V2()
    {
        //find project
        currentProjectLeaf = getProjectleafForFilepoint(currentFilepointLeaf.filepoint!)
        
        fetchFilepointsFromProject()
        for filepointLeaf in currentProjectLeaf.pointLeafs
        {
            if(isOnBranchWith(filepointLeaf.filepoint!, onBranchWith:currentFilepointLeaf.filepoint!))
            {
                buildForNode(filepointLeaf)
            }
        }
        
        currentFilepointLeaf = getFilepointLeafForFilepointBase(currentFilepointLeaf.filepoint!)
        
        selectedLeaf.hidden = false
        selectedLeaf.center = currentFilepointLeaf.center
        
        //filepointSelectedFromFilepoint(currentProjectLeaf.button)
    }
    
    func buildNodesUpToSelectedNode()
    {
        fetchFilepointsFromProject()
        for filepointLeaf in currentProjectLeaf.pointLeafs
        {
            if(isOnBranchWith(filepointLeaf.filepoint!, onBranchWith:currentFilepointLeaf.filepoint!))
            {
                
                buildForNode(filepointLeaf)
            }
        }
    }

    
    func buildForNode(filepointLeaf:PointLeaf)
    {
        fetchFilepointsFromFilepoint(filepointLeaf)
        println("filepointLeaf.filepoint id is \(filepointLeaf.filepoint!.objectID)")
        for filepointLeafItem in filepointLeaf.pointLeafs
        {
            if(isOnBranchWith(filepointLeafItem.filepoint!, onBranchWith:currentFilepointLeaf.filepoint!))
            {
                //println("parent id is \(filepointLeafItem.filepoint.parent?.objectID)")
                buildForNode(filepointLeafItem)
            }
        }
    }
    
    
    func isOnBranchWith(filepointToCheck:Filepoint,onBranchWith:Filepoint) -> Bool
    {
        if(filepointToCheck == onBranchWith)
        {
            return true
        }
        for item in filepointToCheck.firstImagefile!.filepoints
        {
            if(isOnBranchWith(item as Filepoint, onBranchWith: onBranchWith))
            {
                return true
            }
        }
        return false
    }

    func removeProjectLeafs_AndProjectButtons()
    {
        for var i = 0 ;  i < projectLeafs.count ; i++
        {
            for var y = 0 ;  y < projectLeafs[i].pointLeafs.count ; y++
            {
                removePointLeaf(projectLeafs[i].pointLeafs[y])
            }
            projectLeafs[i].removeFromSuperview()
            projectLeafs[i].pointLeafs = []
        }
        projectLeafs = []
        selectedLeaf.hidden = true
    }
    
    func removeProjectLeafChildren()
    {
        for var i = 0 ;  i < projectLeafs.count ; i++
        {
            for var y = 0 ;  y < projectLeafs[i].pointLeafs.count ; y++
            {
                removePointLeaf(projectLeafs[i].pointLeafs[y])
            }
            projectLeafs[i].pointLeafs = []
        }
    }
    
    func removePointLeafChildren(pointLeaf:PointLeaf)
    {
        for var i = 0 ;  i < pointLeaf.pointLeafs.count ; i++
        {
            removePointLeaf(pointLeaf.pointLeafs[i])
        }
        pointLeaf.pointLeafs = []
    }
    
    func removePointLeaf(pointLeaf:PointLeaf)
    {
        for var i = 0 ;  i < pointLeaf.pointLeafs.count ; i++
        {
            removePointLeaf(pointLeaf.pointLeafs[i])
        }
        pointLeaf.pointLeafs = []
        pointLeaf.removeFromSuperview()
    }
    
    func deleteNode()
    {
        if(actionForOverlay)
        {
            actionForOverlay = false
            delegate?.deleteOverlayNode()
        }
        else if(currentFilepointLeaf != nil)
        {
            delegate?.deleteFilepointNode()
            
        }
        else if (currentProjectLeaf != nil)
        {
            delegate?.deleteProjectNode()
            

            
        }
    }
    
    func findPointLeafForImagefileAndSetNewCurrentImageInstance(imagefile:Imagefile)
    {
        
        var found = false
        for item in currentProjectLeaf.imageInstances
        {
            if item.imagefile == imagefile
            {
                currentProjectLeaf.setImageInstanceOnTop(item)
                removePointLeafChildren(currentProjectLeaf)
                fetchFilepointsFromProject()
                found = true
                break
            }
        }
        
        if !found
        {
            for item in currentFilepointLeaf.imageInstances
            {
                if item.imagefile == imagefile
                {
                    currentFilepointLeaf.setImageInstanceOnTop(item)
                    removePointLeafChildren(currentFilepointLeaf)
                    buildForNode(currentFilepointLeaf)
                }
            }
        }
        
        setNeedsDisplay()
    }
    
    func save() {
        var error : NSError?
        if(managedObjectContext!.save(&error) ) {
            println(error?.localizedDescription)
        }
    }
    
    func fadeoutActionButtons()
    {
        jumpToFilepointButton.alpha = 0
        deleteNodeButton.alpha = 0
        setEditNodeButton.alpha = 0
    }
    
    func setEditNode()
    {
        if(actionForOverlay)
        {
            actionForOverlay = false
            delegate?.setEditOverlay()
        }
    }
    
    func showNode()
    {
        if(actionForOverlay)
        {
            actionForOverlay = false
            delegate?.showOverlay()
        }
        else
        {
            delegate?.jumpToFilepoint()
        }
    }
}