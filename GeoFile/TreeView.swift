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
    func deleteFilepointNode()
    func deleteMapPointNode()
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
    var delegate:TreeViewProtocol?
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var mapPointLeafs = [PointLeaf]()
    var overlayLeafs = [OverlayLeaf]()
    var currentFilepointLeaf:PointLeaf!
    var currentMapPointLeaf:PointLeaf!
    var currentOverlayLeaf:OverlayLeaf!
    var selectedLeaf:UIView!
    var overlayDropzone:OverlayDropzone!
    
    
    
    init(frame: CGRect, delegate: TreeViewProtocol) {
        super.init(frame: frame)

        
        self.delegate = delegate
        selectedLeaf = UIView(frame: CGRectMake(0, 0, leafSize.width + 4, leafSize.height + 4))
        selectedLeaf.hidden = true
        selectedLeaf.layer.cornerRadius = 5
        selectedLeaf.clipsToBounds = true
        selectedLeaf.backgroundColor = UIColor.redColor()
        self.addSubview(selectedLeaf)

        
        //populateTestOverlays()
        
        
        fetchOverlays()
        fetchMapPoints()

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var leafVerticalMargin = leafSize.height * 0.65
    var leafHorizontalMargin = leafSize.width * 0.65
    var leafHorizontalRestMargin = leafSize.width * 0.35
    override func drawRect(rect: CGRect) {
        //[[UIColor brownColor] set];

        let currentContext = UIGraphicsGetCurrentContext()
        CGContextSetLineCap(currentContext, CGLineCap.Round)
        for item in mapPointLeafs
        {
            drawFilepointsFromMapPoint(currentContext!,mapPointLeaf: item)
        }
        
        //draw for overlaynodes
        CGContextSetLineWidth(currentContext,3.0)
        let ra:[CGFloat] = [6,6]
        CGContextSetLineDash(currentContext, 0.0, ra, 2);
        let fromX = overlayDropzone.center.x
        let fromY = overlayDropzone.center.y
        CGContextMoveToPoint(currentContext,fromX, fromY)
        for item in overlayLeafs
        {
            let toX = item.center.x
            let toY = item.center.y
            CGContextAddLineToPoint(currentContext,toX, toY)
            CGContextStrokePath(currentContext)
            CGContextMoveToPoint(currentContext,toX, toY)
        }
    }
    
    func drawFilepointsFromMapPoint(currentContext:CGContext, mapPointLeaf:PointLeaf)
    {
        CGContextSetLineCap(currentContext, CGLineCap.Round)
        if(mapPointLeaf.pointLeafs.count > 0)
        {
            CGContextSetLineWidth(currentContext,3.0)
            //draw horizontal line
            let x:CGFloat = mapPointLeaf.center.x
            let y = mapPointLeaf.center.y
            let drawToX:CGFloat = x + leafHorizontalMargin //x + (horizontalLineLength/2)
            CGContextMoveToPoint(currentContext,x, y);
            CGContextAddLineToPoint(currentContext,drawToX, y);
            CGContextStrokePath(currentContext);
        }
        
        for item in mapPointLeaf.pointLeafs
        {
            //draw horizontal line backwards
            CGContextSetLineWidth(currentContext,3.0)
            //var x = item.frame.minX
            let x = item.center.x
            let y = item.center.y
            let drawToX = x -  (leafHorizontalMargin / 2) //( horizontalLineLength / 2 )
            CGContextMoveToPoint(currentContext,x, y)
            CGContextAddLineToPoint(currentContext,drawToX, y)
            CGContextStrokePath(currentContext)
            

            drawFilepointsFromFilepoint(currentContext,filepointLeaf: item)
          
        }
        
        //vertical line
        if let item = mapPointLeaf.pointLeafs.first
        {
            let firstItem = item as PointLeaf
            let fromX = firstItem.frame.minX + (leafHorizontalRestMargin / 2)
            let fromY = firstItem.center.y
            CGContextMoveToPoint(currentContext,fromX, fromY);
            
            let lastItem = mapPointLeaf.pointLeafs.last!
            let toX = lastItem.frame.minX + (leafHorizontalRestMargin / 2)
            let toY = lastItem.center.y
            CGContextAddLineToPoint(currentContext,toX, toY)
            CGContextStrokePath(currentContext)
        }
        

    }
    
    
    func drawFilepointsFromFilepoint(currentContext:CGContext, filepointLeaf:PointLeaf)
    {
        CGContextSetLineCap(currentContext, CGLineCap.Round)
        if(filepointLeaf.pointLeafs.count > 0)
        {
            //draw horizontal line
            let item = filepointLeaf
            CGContextSetLineWidth(currentContext,3.0)
            let x = item.center.x
            let y = item.center.y
            let drawToX = x + leafHorizontalMargin
            CGContextMoveToPoint(currentContext,x, y);
            CGContextAddLineToPoint(currentContext,drawToX, y);
            CGContextStrokePath(currentContext);
        }
        
        for item in filepointLeaf.pointLeafs
        {
            //draw horizontal line
            if(item.isDescendantOfView(self))
            {
                if(item.filepoint!.x != 0 && item.filepoint!.y != 0)
                {
                    CGContextSetLineWidth(currentContext,3.0)
                    let x = item.center.x
                    let y = item.center.y
                    let drawToX = x - (leafHorizontalMargin / 2)
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
            let firstItem = item
            let fromX = firstItem.frame.minX + (leafHorizontalRestMargin / 2)//+ (horizontalLineLength/2)
            let fromY = firstItem.center.y
            CGContextMoveToPoint(currentContext,fromX, fromY);
        

            //var lastButtonItem = getLastFilepointWithCoordinates(filepointLeaf).button
            let lastItem = filepointLeaf.pointLeafs.last!
            let toX = lastItem.frame.minX + (leafHorizontalRestMargin / 2) // (horizontalLineLength/2)
            let toY = lastItem.center.y
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
        let image = UIImage(named: "pictureOverviewSmall.png")
        let imageData = UIImageJPEGRepresentation(image!,0.0)
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        Overlay.createInManagedObjectContext(self.managedObjectContext!,title:"Imported image \(timestamp)",file:imageData!)
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
        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Overlay] {
            var i = 1
            for item in fetchResults
            {
                let node = OverlayLeaf(overlay:item as Overlay, viewRef:self)
                node.center =  CGPointMake(overlayDropzone.center.x + (node.frame.width * CGFloat(i)),  overlayDropzone.center.y)
                overlayLeafs.append(node)
                expandContentsize(node.frame)
                self.addSubview(node)
                
                i++
            }
        }
    }
    
    func fetchMapPoints()
    {
        mapPointLeafs = []
        let fetchRequest = NSFetchRequest(entityName: "MapPoint")
        let overlayNodeMargin = overlayDropzone.frame.height * 0.8
        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MapPoint] {
            var i = 0
            for item in fetchResults
            {

                let newMapPointLeaf = PointLeaf(_mappoint:item, viewRef:self)
                mapPointLeafs.append(newMapPointLeaf)

                
                newMapPointLeaf.center = CGPointMake((UIScreen.mainScreen().bounds.size.width * 0.1) + (leafSize.width/2), (UIScreen.mainScreen().bounds.size.height * 0.2) + (leafVerticalMargin * CGFloat(i)) + overlayNodeMargin)
                
                expandContentsize(newMapPointLeaf.frame)
                self.addSubview(newMapPointLeaf)
                i++
            }

        }
        self.setNeedsDisplay()
    }
    
    func expandContentsize(rect:CGRect)
    {
        let newWidth = self.frame.width < rect.maxX ? rect.maxX : self.frame.width
        let newHeight = self.frame.height < rect.maxY ? rect.maxY : self.frame.height
        
        print(" new maxx and y \(rect.maxX) \(rect.maxY)")
        let newSize  = CGSizeMake(newWidth + elementMargin, newHeight + elementMargin)
        self.frame.size = newSize
        
        
        print(" new self.frame \(self.frame.origin.x) \(self.frame.origin.y) \(self.frame.width) \(self.frame.height)")
        delegate?.setContentsize(newSize)
    }

    
    func fetchFilepointsFromMapPoint()
    {
        let xOffset = currentMapPointLeaf.center.x
        let yOffset = currentMapPointLeaf.center.y
        var i = 0
        if let currentImagefile = currentMapPointLeaf.currentImage
        {
            for item in currentImagefile.filepoints
            {
                let filepointLeaf = PointLeaf(_filePoint:item as! Filepoint,_parent:nil,viewRef:self)
                currentMapPointLeaf.pointLeafs.append(filepointLeaf)
                filepointLeaf.center = CGPointMake(leafHorizontalMargin + xOffset, yOffset + (leafVerticalMargin * CGFloat(i)))
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
            let newFilepointLeaf = PointLeaf(_filePoint:item as! Filepoint,_parent:nil,viewRef:self)
            filepointLeaf.pointLeafs.append(newFilepointLeaf)
            newFilepointLeaf.center = CGPointMake(xOffset + leafHorizontalMargin, yOffset + (leafVerticalMargin * CGFloat(i)))
            expandContentsize(newFilepointLeaf.frame)
            self.addSubview(newFilepointLeaf)
            
            i++
        }
    }
    
    func findSelecedFilepointLeaf(filepointLeaf:PointLeaf, pointLeafPushed:PointLeaf)
    {
        
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
    

    
    func unselectAllLeafsOnCurrentMapPointLeaf()
    {
        if(currentMapPointLeaf != nil)
        {
            for item in currentMapPointLeaf.pointLeafs
            {
                item.unselectLeaf()
                
                unselectAllLeafsOnPointLeaf(item as PointLeaf)
            }
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
        let _pointsLeafs = pointLeafs ?? currentMapPointLeaf.pointLeafs!

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
    

 
    func overlaySelected(sender:UITapGestureRecognizer)
    {
        let overlayLeaf = sender.view?.superview as! OverlayLeaf
        
        unselectOverlayLeafs()
        unselectAllLeafsOnCurrentMapPointLeaf()
        
        for item in mapPointLeafs
        {
            item.unselectLeaf()
        }

        overlayLeaf.selectLeaf()
        currentOverlayLeaf = overlayLeaf
        
        setNeedsDisplay()
        
        delegate?.hideImageInstancesScrollView()
        //remove imageinstances from scrollview
        //delegate!.setScrollViewSize(CGSizeMake(self.frame.width, self.frame.height))
    }
    
    func getSelectedOverlayNode() -> OverlayLeaf?
    {
        return currentOverlayLeaf
    }
    
    func unselectOverlayLeafs()
    {
        for item in overlayLeafs
        {
            item.unselectLeaf()
        }
    }
    
    
    
    func mapPointSelectedAction(sender:UITapGestureRecognizer)
    {
        currentFilepointLeaf = nil
        let selectedMapPointLeaf = (sender as UITapGestureRecognizer).view?.superview
        mapPointSelected(selectedMapPointLeaf as! PointLeaf)
    }
    
    func mapPointSelected(pointLeaf:PointLeaf)
    {
        //remove all buttons
        removeMapPointLeafChildren()
        
        unselectOverlayLeafs()
        for item in mapPointLeafs
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

        currentMapPointLeaf = pointLeaf
        fetchFilepointsFromMapPoint()
        setNeedsDisplay()
        delegate?.showImageInstancesScrollView(currentMapPointLeaf)
        
        self.bringSubviewToFront(currentMapPointLeaf)
    }
    
    func filepointSelectedFromFilepointAction(sender:UITapGestureRecognizer)
    {
        //fadeoutActionButtons()
        
        let selectedFilepointLeaf = (sender as UITapGestureRecognizer).view?.superview
        filepointSelectedFromFilepoint(selectedFilepointLeaf as! PointLeaf)
    }
    
    func filepointSelectedFromFilepoint(selectedFilepointLeaf:PointLeaf)
    {
        currentFilepointLeaf = selectedFilepointLeaf
        
        unselectOverlayLeafs()
        for item in mapPointLeafs
        {
            item.unselectLeaf()
        }
        unselectAllLeafsOnCurrentMapPointLeaf()
        
        //buildNodesUpToSelectedNode()
        buildForNode(currentFilepointLeaf)
        self.bringSubviewToFront(currentFilepointLeaf)
        currentFilepointLeaf.selectLeaf()
        
        setNeedsDisplay()
        delegate?.showImageInstancesScrollView(currentFilepointLeaf)

        
    }

    func getMapPointleafForFilepoint(_filepoint:Filepoint) -> PointLeaf?
    {
        for mapPointLeaf in mapPointLeafs
        {
            for filepoint in mapPointLeaf.currentImage!.filepoints
            {
                if(isOnBranchWith(filepoint as! Filepoint, onBranchWith:_filepoint))
                {
                    return mapPointLeaf
                }
            }
        }
        return nil
    }
    
    //base ass in checking from mappointleafs
    func getFilepointLeafForFilepointBase(_filepoint:Filepoint) -> PointLeaf?
    {
        var filepointLeafToReturn:PointLeaf?
        for mapPointLeaf in mapPointLeafs
        {
            for filepointLeaf in mapPointLeaf.pointLeafs
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
        //find map point
        currentMapPointLeaf = getMapPointleafForFilepoint(currentFilepointLeaf.filepoint!)
        
        fetchFilepointsFromMapPoint()
        for filepointLeaf in currentMapPointLeaf.pointLeafs
        {
            if(isOnBranchWith(filepointLeaf.filepoint!, onBranchWith:currentFilepointLeaf.filepoint!))
            {
                buildForNode(filepointLeaf)
            }
        }
        
        currentFilepointLeaf = getFilepointLeafForFilepointBase(currentFilepointLeaf.filepoint!)
        
        selectedLeaf.hidden = false
        selectedLeaf.center = currentFilepointLeaf.center
    }
    
    func buildNodesUpToSelectedNode()
    {
        fetchFilepointsFromMapPoint()
        for filepointLeaf in currentMapPointLeaf.pointLeafs
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
        print("filepointLeaf.filepoint id is \(filepointLeaf.filepoint!.objectID)")
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
        if let firstimage = filepointToCheck.firstImagefile
        {
            for item in firstimage.filepoints
            {
                if(isOnBranchWith(item as! Filepoint, onBranchWith: onBranchWith))
                {
                    return true
                }
            }
        }
        return false
    }
    
    func removeMapPointLeafChildren()
    {
        for var i = 0 ;  i < mapPointLeafs.count ; i++
        {
            for var y = 0 ;  y < mapPointLeafs[i].pointLeafs.count ; y++
            {
                removePointLeaf(mapPointLeafs[i].pointLeafs[y])
            }
            mapPointLeafs[i].pointLeafs = []
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
    

    
    func findPointLeafForImagefileAndSetNewCurrentImageInstance(imagefile:Imagefile)
    {
        
        var found = false
        for item in currentMapPointLeaf.imageInstances
        {
            if item.imagefile == imagefile
            {
                currentMapPointLeaf.setImageInstanceOnTop(item)
                removePointLeafChildren(currentMapPointLeaf)
                fetchFilepointsFromMapPoint()
                found = true
                self.bringSubviewToFront(currentMapPointLeaf)
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
                    self.bringSubviewToFront(currentFilepointLeaf)
                }
            }
        }
        
        setNeedsDisplay()
        
    }
    
    func save() {
        do{
            try managedObjectContext!.save()
        } catch {
            print(error)
        }
    }
    
    func deleteOverlay()
    {
        delegate?.deleteOverlayNode()
        setNeedsDisplay()
    }
    
    func deleteNode()
    {
        if(currentFilepointLeaf != nil)
        {
            delegate?.deleteFilepointNode()
            
        }
            
        else if (currentMapPointLeaf != nil)
        {
            delegate?.deleteMapPointNode()
            
        }
        setNeedsDisplay()
    }
    
    func showOverlay()
    {
        delegate?.showOverlay()
    }
    
    func showNode()
    {
        delegate?.jumpToFilepoint()
    }
}