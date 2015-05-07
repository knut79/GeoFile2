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
    func setNewContentSize()
    func jumpToFilepoint()
    func showOverlay()
    func setEditOverlay()
    func deleteFilepointNode()
    func deleteProjectNode()
    func deleteOverlayNode()
}

class TreeView:UIView
{

    var imageViewTest:UIImageView!
    //var projectButtons:[UIButton] = []
    var delegate:TreeViewProtocol?
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var projectLeafs = [ProjectLeaf]()
    var overlayNodes = [OverlayNode]()
    var currentFilepointLeaf:FilepointLeaf!
    var currentProjectLeaf:ProjectLeaf!
    var selectedLeaf:UIView!
    var overlayNode:UILabel!
    
    var jumpToFilepointButton:UIButton!
    var deleteNodeButton:UIButton!
    var setEditNodeButton:UIButton!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
    
    

    
    var horizontalLineLength:CGFloat = 20
    var verticalLineLength:CGFloat = 20
    var leafSize = CGSizeMake( 60, 40)
    
    override func drawRect(rect: CGRect) {
        //[[UIColor brownColor] set];

        var currentContext = UIGraphicsGetCurrentContext()
        CGContextSetLineCap(currentContext, kCGLineCapRound)
        var xOffset:CGFloat = 0
        var yOffset:CGFloat = 0
        for item in projectLeafs
        {
            let buttonItem = item.button
            var x = buttonItem.frame.maxX
            var y = buttonItem.frame.maxY - (buttonItem.frame.size.height/2)

            var drawToX = x + horizontalLineLength
            var drawToY = y
            //if(item.selected)
            //{
                //xOffset = drawToX
                //yOffset = drawToY
                drawFilepointsFromProject(currentContext,projectLeaf: item)
            //}

        }
    }
    
    func drawFilepointsFromProject(currentContext:CGContext, projectLeaf:ProjectLeaf)
    {
        CGContextSetLineCap(currentContext, kCGLineCapRound)
        if(projectLeaf.filepointLeafs.count > 0)
        {
            let buttonItem = projectLeaf.button
            CGContextSetLineWidth(currentContext,3.0)
            //draw horizontal line
            var x = buttonItem.frame.maxX
            var y = buttonItem.center.y
            var drawToX = x + (horizontalLineLength/2)
            CGContextMoveToPoint(currentContext,x, y);
            CGContextAddLineToPoint(currentContext,drawToX, y);
            CGContextStrokePath(currentContext);
        }
        
        var selectedItem:FilepointLeaf?
        for item in projectLeaf.filepointLeafs
        {
            //draw horizontal line backwards
            let buttonItem = item.button

            CGContextSetLineWidth(currentContext,3.0)
            var x = buttonItem.frame.minX
            var y = buttonItem.center.y
            var drawToX = x - ( horizontalLineLength / 2 )
            CGContextMoveToPoint(currentContext,x, y);
            CGContextAddLineToPoint(currentContext,drawToX, y);
            CGContextStrokePath(currentContext);
            

            drawFilepointsFromFilepoint(currentContext,filepointLeaf: item)
          
        }
        
        //vertical line
        if let item = projectLeaf.filepointLeafs.first
        {
            var firstButtonItem = item.button
            var fromX = firstButtonItem!.frame.minX - (horizontalLineLength/2)
            var fromY = firstButtonItem!.center.y
            CGContextMoveToPoint(currentContext,fromX, fromY);
            
            //var lastButtonItem = selectedItem == nil ? projectLeaf.filepointLeafs.last!.button : selectedItem!.button
            var lastButtonItem = projectLeaf.filepointLeafs.last!.button
            var toX = lastButtonItem.frame.minX - (horizontalLineLength/2)
            var toY = lastButtonItem.center.y
            CGContextAddLineToPoint(currentContext,toX, toY)
            CGContextStrokePath(currentContext)
        }
    }
    
    
    func drawFilepointsFromFilepoint(currentContext:CGContext, filepointLeaf:FilepointLeaf)
    {
        CGContextSetLineCap(currentContext, kCGLineCapRound)
        if(filepointLeaf.filepointLeafs.count > 0)
        {
            //draw horizontal line
            let buttonItem = filepointLeaf.button
            CGContextSetLineWidth(currentContext,3.0)
            var x = buttonItem.frame.maxX
            var y = buttonItem.center.y
            var drawToX = x + ( horizontalLineLength / 2 )
            CGContextMoveToPoint(currentContext,x, y);
            CGContextAddLineToPoint(currentContext,drawToX, y);
            CGContextStrokePath(currentContext);
        }
        
        var selectedItem:FilepointLeaf?
        for item in filepointLeaf.filepointLeafs
        {
            //draw horizontal line
            let buttonItem = item.button
            if(buttonItem.isDescendantOfView(self))
            {
                //var lengths:[CGFloat] = [CGFloat(0),CGFloat(0.5 * 2)]
                //CGContextSetLineDash(currentContext, 0.0, lengths, 2)
                if(item.filepoint.x != 0 && item.filepoint.y != 0)
                {
                CGContextSetLineWidth(currentContext,3.0)
                var x = buttonItem.frame.minX
                var y = buttonItem.center.y
                var drawToX = x - ( horizontalLineLength / 2 )
                CGContextMoveToPoint(currentContext,x, y);
                CGContextAddLineToPoint(currentContext,drawToX, y);
                CGContextStrokePath(currentContext);
                }
            }


                drawFilepointsFromFilepoint(currentContext,filepointLeaf: item)

        }
        
        if let item = filepointLeaf.filepointLeafs.first
        {
            var firstButtonItem = item.button
            var fromX = firstButtonItem!.frame.minX - (horizontalLineLength/2)
            var fromY = firstButtonItem!.center.y
            CGContextMoveToPoint(currentContext,fromX, fromY);
        

            //var lastButtonItem = getLastFilepointWithCoordinates(filepointLeaf).button
            var lastButtonItem = filepointLeaf.filepointLeafs.last!.button
            var toX = lastButtonItem.frame.minX - (horizontalLineLength/2)
            var toY = lastButtonItem.center.y
            CGContextAddLineToPoint(currentContext,toX, toY)
            CGContextStrokePath(currentContext)
        }

    }
    
    func getLastFilepointWithCoordinates(filepointLeaf:FilepointLeaf) -> FilepointLeaf
    {
        var lastNodeWithCoordinates = filepointLeaf.filepointLeafs.first
        for var i = 0; i < filepointLeaf.filepointLeafs.count ; i++
        {
            if(filepointLeaf.filepointLeafs[i].filepoint.x == 0 && filepointLeaf.filepointLeafs[i].filepoint.y == 0)
            {
                if(i > 0)
                {
                    lastNodeWithCoordinates = filepointLeaf.filepointLeafs[i-1]
                    break
                }
            }
        }
        return lastNodeWithCoordinates!
    }

    func addOverlayNode()
    {
        overlayNode = UILabel(frame: CGRectMake(0, 0, leafSize.width, leafSize.height))
        overlayNode.userInteractionEnabled = true
        overlayNode.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        overlayNode.layer.cornerRadius = 5
        overlayNode.clipsToBounds = true
        overlayNode.text = "🌍"
        overlayNode.textAlignment = NSTextAlignment.Center
        overlayNode.center =  CGPointMake((UIScreen.mainScreen().bounds.size.width * 0.1) + (overlayNode.frame.size.width/2), (UIScreen.mainScreen().bounds.size.height * 0.1))
        self.addSubview(overlayNode)
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
        for var i = 0 ; i < overlayNodes.count ; i++
        {
            overlayNodes[i].removeFromSuperview()
        }
        overlayNodes = []
        
    }
    func fetchOverlays()
    {
        
        addOverlayNode()
        let fetchRequest = NSFetchRequest(entityName: "Overlay")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Overlay] {
            var i = 1
            for item in fetchResults
            {
                var node = OverlayNode(frame: CGRectMake(0, 0, leafSize.width, leafSize.height))
                node.userInteractionEnabled = true
                var image = UIImage(data: item.file)
                node.image = image
                node.center =  CGPointMake(overlayNode.center.x + ((node.frame.size.width + 4) * CGFloat(i)), overlayNode.center.y)
                var doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "showActionButtonsForOverlay:")
                doubleTapRecognizer.numberOfTapsRequired = 2
                node.addGestureRecognizer(doubleTapRecognizer)
                node.overlay = item
                overlayNodes.append(node)
                self.addSubview(node)
                
                i++
            }
        }
    }
    
    func fetchProjects()
    {
        projectLeafs = []
        let fetchRequest = NSFetchRequest(entityName: "Project")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Project] {
            var i = 0
            for item in fetchResults
            {
                var _button = UILabel(frame: CGRectMake(0, 0, leafSize.width, leafSize.height))
                _button.userInteractionEnabled = true
                _button.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
                _button.numberOfLines = 2
                _button.text = "\(item.title)"
                _button.center =  CGPointMake((UIScreen.mainScreen().bounds.size.width * 0.1) + (_button.frame.size.width/2), (UIScreen.mainScreen().bounds.size.height * 0.2) + ((_button.frame.height  + verticalLineLength) * CGFloat(i)))
                var singleTapRecognizer = UITapGestureRecognizer(target: self, action: "projectSelected:")
                singleTapRecognizer.numberOfTapsRequired = 1
                _button.addGestureRecognizer(singleTapRecognizer)
                var doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "showActionButtonsForProject:")
                doubleTapRecognizer.numberOfTapsRequired = 2
                singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
                _button.addGestureRecognizer(doubleTapRecognizer)
                projectLeafs.append(ProjectLeaf(_project:item,_button:_button))
                self.addSubview(_button)
                
                i++
            }

        }
        self.setNeedsDisplay()
    }
    
    func buildLeafButton(xOffset:CGFloat,yOffset:CGFloat,index:Int,item:Filepoint) -> UIImageView
    {
        var filePointItem = item as Filepoint
        var image = UIImage(data: filePointItem.file!)
        var _button = UIImageView(frame: CGRectMake(0, 0, leafSize.width, leafSize.height))
        _button.userInteractionEnabled = true
        _button.image = image
        _button.center = CGPointMake(xOffset + _button.frame.size.width + horizontalLineLength, yOffset + ((_button.frame.height + verticalLineLength) * CGFloat(index)))
        var singleTapRecognizer = UITapGestureRecognizer(target: self, action: "filepointSelectedFromFilepoint:")
        singleTapRecognizer.numberOfTapsRequired = 1
        _button.addGestureRecognizer(singleTapRecognizer)
        var doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "showActionButtonsForFilepoint:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        _button.addGestureRecognizer(doubleTapRecognizer)
        
        return _button
    }
    
    func fetchFilepointsFromProject()
    {
       
        var i = 0
        for item in currentProjectLeaf.project.filepoints
        {
            var xOffset = currentProjectLeaf.button.center.x
            var yOffset = currentProjectLeaf.button.center.y
            var _button = buildLeafButton(xOffset,yOffset: yOffset,index: i,item: item as Filepoint)
            currentProjectLeaf.filepointLeafs.append(FilepointLeaf(_filePoint:item as Filepoint,_button:_button,_parent:nil))
            self.addSubview(_button)
            i++

        }
    }
    
    func fetchFilepointsFromFilepoint(filepointLeaf:FilepointLeaf)
    {
        
        var i = 0
        for item in filepointLeaf.filepoint.filepoints
        {
            if((item as Filepoint).x != 0 && (item as Filepoint).y != 0)
            {
                var xOffset = filepointLeaf.button.center.x
                var yOffset = filepointLeaf.button.center.y
                var _button = buildLeafButton(xOffset,yOffset: yOffset,index: i,item: item as Filepoint)
                filepointLeaf.filepointLeafs.append(FilepointLeaf(_filePoint:item as Filepoint,_button:_button,_parent:nil))
                self.addSubview(_button)
                i++
            }
        }
        for item in filepointLeaf.filepoint.filepoints
        {
            if((item as Filepoint).x == 0 && (item as Filepoint).y == 0)
            {
                var xOffset = filepointLeaf.button.center.x
                var yOffset = filepointLeaf.button.center.y
                var _button = buildLeafButton(xOffset,yOffset: yOffset,index: i,item: item as Filepoint)
                filepointLeaf.filepointLeafs.append(FilepointLeaf(_filePoint:item as Filepoint,_button:_button,_parent:nil))
                self.addSubview(_button)
                i++
            }
        }
    }
    
    func expandFrame(maxPoint:CGPoint)
    {
        self.frame =  CGRectMake(0, 0, self.frame.size.width > maxPoint.x ? self.frame.size.width : maxPoint.x, self.frame.size.height > maxPoint.y ? self.frame.size.height : (maxPoint.y + projectLeafs.first!.button.frame.height))
        delegate!.setNewContentSize()
    }
   
    
    
    func findSelecedFilepointLeaf(filepointLeaf:FilepointLeaf, buttonPushed:UIImageView)
    {
        fadeoutActionButtons()
        
        var filepointLeafs = filepointLeaf.filepointLeafs
        for var i = 0 ; i < filepointLeafs.count ; i++
        {
            if(filepointLeafs[i].button == buttonPushed)
            {
                currentFilepointLeaf = filepointLeafs[i]
                selectedLeaf.hidden = false
                selectedLeaf.center = currentFilepointLeaf.button.center
            }
            else
            {
                findSelecedFilepointLeaf(filepointLeafs[i],buttonPushed: buttonPushed)
            }

        }
    }
    
    
    func filepointSelectedFromFilepoint(sender:UITapGestureRecognizer)
    {
        fadeoutActionButtons()
        
        var button = (sender as UITapGestureRecognizer).view
        filepointSelectedFromFilepoint(button as UIImageView)
    }
    
    func filepointSelectedFromFilepoint(button:UIImageView)
    {
        var filepointLeafs = currentProjectLeaf.filepointLeafs
        for var i = 0 ;  i < filepointLeafs.count ; i++
        {
            if(filepointLeafs[i].button == button )
            {
                currentFilepointLeaf = filepointLeafs[i]
                selectedLeaf.hidden = false
                selectedLeaf.center = currentFilepointLeaf.button.center
            }
            else
            {
                findSelecedFilepointLeaf(filepointLeafs[i],buttonPushed: (button as UIImageView))
            }
        }
        
        currentFilepointLeaf.selected = true
        
        //remove all buttons
        removeProjectLeafs()
        
        buildNodesUpToSelectedNode()
        
        setNeedsDisplay()
    }
    
    func findButtonForFilepointAndSelectIt(filepointToCheck:Filepoint, filepointLeafs:[FilepointLeaf]? = nil)
    {
        var _filepointsLeafs = filepointLeafs ?? currentProjectLeaf.filepointLeafs

        for item in _filepointsLeafs
        {
            if(item.filepoint.objectID == filepointToCheck.objectID)
            {
                filepointSelectedFromFilepoint(item.button)
            }
            else
            {
                findButtonForFilepointAndSelectIt(filepointToCheck, filepointLeafs: item.filepointLeafs)
            }
        }
    }
    
    func unselectAllOverlayNodes()
    {
        for var i = 0 ; i < overlayNodes.count ; i++
        {
            overlayNodes[i].selected = false
        }
    }
    
    func getSelectedOverlayNode() -> OverlayNode?
    {
        for var i = 0 ; i < overlayNodes.count ; i++
        {
            if(overlayNodes[i].selected)
            {
                return overlayNodes[i]
            }
        }
        return nil
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
            
            unselectAllOverlayNodes()
            
            (node as OverlayNode).selected = true
        }
        
    }
    
    func showActionButtonsForProject(sender:AnyObject)
    {
        //TODO: should handle doubletap of nodes that are not selected
        if(currentProjectLeaf != nil)
        {
            self.bringSubviewToFront(deleteNodeButton)
            var buttonY = currentProjectLeaf.button.center.y > self.frame.height / 2 ? currentProjectLeaf.button.center.y - currentProjectLeaf.button.frame.height : currentProjectLeaf.button.center.y + currentProjectLeaf.button.frame.height
            var buttonX = currentProjectLeaf.button.center.x > self.frame.width / 2 ? currentProjectLeaf.button.center.x - currentProjectLeaf.button.frame.width : currentProjectLeaf.button.center.x + currentProjectLeaf.button.frame.width
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
            var jumpToFilepointButtonY = currentFilepointLeaf.button.center.y > self.frame.height / 2 ? currentFilepointLeaf.button.center.y - currentFilepointLeaf.button.frame.height : currentFilepointLeaf.button.center.y + currentFilepointLeaf.button.frame.height
            var jumpToFilepointButtonX = currentFilepointLeaf.button.center.x > self.frame.width / 2 ? currentFilepointLeaf.button.center.x - currentFilepointLeaf.button.frame.width : currentFilepointLeaf.button.center.x + currentFilepointLeaf.button.frame.width
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
        projectSelected(sender.view as UILabel)

    }
    
    func projectSelected(button:UILabel)
    {
        //remove all buttons
        removeProjectLeafs()
        
        for var i = 0 ;  i < projectLeafs.count ; i++
        {
            if(projectLeafs[i].button == (button as UILabel))
            {
                currentProjectLeaf = projectLeafs[i]
                selectedLeaf.hidden = false
                selectedLeaf.center = currentProjectLeaf.button.center
            }
            
            projectLeafs[i].selected = false
            projectLeafs[i].button.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        }
        
        currentProjectLeaf.selected = true
        jumpToFilepointButton.alpha = 0
        
        fetchFilepointsFromProject()
        
        //expandFrame(CGPointMake(projectLeafs.last!.button.frame.maxX, projectLeafs.last!.button.frame.maxY))//   projectButtons.last?.frame.maxX, projectButtons.last?.frame.maxY!))
        setNeedsDisplay()
    }

    func getProjectleafForFilepoint(_filepoint:Filepoint) -> ProjectLeaf?
    {
        for projectLeaf in projectLeafs
        {
            for filepoint in projectLeaf.project.filepoints
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
    func getFilepointLeafForFilepointBase(_filepoint:Filepoint) -> FilepointLeaf?
    {
        var filepointLeafToReturn:FilepointLeaf?
        for projectLeaf in projectLeafs
        {
            for filepointLeaf in projectLeaf.filepointLeafs
            {
                filepointLeafToReturn = getFilepointLeafForFilepoint(_filepoint,filepointLeafBase: filepointLeaf)
                
                /*
                if(filepointLeaf.filepoint == _filepoint)
                {
                    filepointLeafToReturn = filepointLeaf
                }
                else
                {
                    filepointLeafToReturn = getFilepointLeafForFilepoint(_filepoint,filepointLeafBase: filepointLeaf)
                }
                */
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
    
    func getFilepointLeafForFilepoint(_filepoint:Filepoint, filepointLeafBase:FilepointLeaf) -> FilepointLeaf?
    {
        if(filepointLeafBase.filepoint == _filepoint)
        {
            return filepointLeafBase
        }
        
        var filepointLeafToReturn:FilepointLeaf?
        for filepointLeaf in filepointLeafBase.filepointLeafs
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
        currentProjectLeaf = getProjectleafForFilepoint(currentFilepointLeaf.filepoint)
        
        fetchFilepointsFromProject()
        for filepointLeaf in currentProjectLeaf.filepointLeafs
        {
            if(isOnBranchWith(filepointLeaf.filepoint, onBranchWith:currentFilepointLeaf.filepoint))
            {
                buildForNode(filepointLeaf)
            }
        }
        
        currentFilepointLeaf = getFilepointLeafForFilepointBase(currentFilepointLeaf.filepoint)
        
        selectedLeaf.hidden = false
        selectedLeaf.center = currentFilepointLeaf.button.center
        
        //filepointSelectedFromFilepoint(currentProjectLeaf.button)
    }
    
    func buildNodesUpToSelectedNode()
    {
        fetchFilepointsFromProject()
        for filepointLeaf in currentProjectLeaf.filepointLeafs
        {
            if(isOnBranchWith(filepointLeaf.filepoint, onBranchWith:currentFilepointLeaf.filepoint))
            {
                
                buildForNode(filepointLeaf)
            }
        }
    }
    
    func buildForNode(filepointLeaf:FilepointLeaf)
    {
        fetchFilepointsFromFilepoint(filepointLeaf)
        println("filepointLeaf.filepoint id is \(filepointLeaf.filepoint.objectID)")
        for filepointLeafItem in filepointLeaf.filepointLeafs
        {
            if(isOnBranchWith(filepointLeafItem.filepoint, onBranchWith:currentFilepointLeaf.filepoint))
            {
                println("parent id is \(filepointLeafItem.filepoint.parent?.objectID)")
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
        for item in filepointToCheck.filepoints
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
            for var y = 0 ;  y < projectLeafs[i].filepointLeafs.count ; y++
            {
                removeFilepointLeaf(projectLeafs[i].filepointLeafs[y])
            }
            projectLeafs[i].button.removeFromSuperview()
            projectLeafs[i].filepointLeafs = []
        }
        projectLeafs = []
        selectedLeaf.hidden = true
    }
    
    func removeProjectLeafs()
    {
        for var i = 0 ;  i < projectLeafs.count ; i++
        {
            for var y = 0 ;  y < projectLeafs[i].filepointLeafs.count ; y++
            {
                removeFilepointLeaf(projectLeafs[i].filepointLeafs[y])
            }
            projectLeafs[i].filepointLeafs = []
        }
    }
    
    func removeFilepointLeaf(filepointLeaf:FilepointLeaf)
    {
        for var i = 0 ;  i < filepointLeaf.filepointLeafs.count ; i++
        {
            removeFilepointLeaf(filepointLeaf.filepointLeafs[i])
        }
        filepointLeaf.filepointLeafs = []
        filepointLeaf.button.removeFromSuperview()
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