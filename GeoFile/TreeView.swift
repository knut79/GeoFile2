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
}

class TreeView:UIView
{

    var imageViewTest:UIImageView!
    //var projectButtons:[UIButton] = []
    var delegate:TreeViewProtocol?
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var projectLeafs = [ProjectLeaf]()
    var currentFilepointLeaf:FilepointLeaf!
    var currentProjectLeaf:ProjectLeaf!
    var selectedLeaf:UIView!
    
    var jumpToFilepointButton:UIButton!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        selectedLeaf = UIView(frame: CGRectMake(0, 0, leafSize.width + 4, leafSize.height + 4))
        selectedLeaf.hidden = true
        selectedLeaf.layer.cornerRadius = 5
        selectedLeaf.clipsToBounds = true
        selectedLeaf.backgroundColor = UIColor.redColor()
        self.addSubview(selectedLeaf)
        
        jumpToFilepointButton = CustomButton(frame: CGRectMake(0, 0, 75, buttonBarHeight))
        jumpToFilepointButton.setTitle("Show file", forState: UIControlState.Normal)
        jumpToFilepointButton.alpha = 0
        jumpToFilepointButton.layer.cornerRadius = 5
        jumpToFilepointButton.clipsToBounds = true
        jumpToFilepointButton.addTarget(self, action: "jumpToFilepoint", forControlEvents: .TouchUpInside)
        self.addSubview(jumpToFilepointButton)
        
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
        
            //var lastButtonItem = selectedItem == nil ? filepointLeaf.filepointLeafs.last!.button : selectedItem!.button
            //var lastButtonItem = filepointLeaf.filepointLeafs.last!.button
            var lastButtonItem = getLastFilepointWithCoordinates(filepointLeaf).button
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

    
    func fetchProjects()
    {
        let fetchRequest = NSFetchRequest(entityName: "Project")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Project] {
            var i = 0
            for item in fetchResults
            {
                var _button = UIButton(frame: CGRectMake(0, 0, leafSize.width, leafSize.height))
                _button.setTitle("\(item.title)", forState: UIControlState.Normal)
                _button.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
                _button.center = CGPointMake((UIScreen.mainScreen().bounds.size.width * 0.1) + (_button.frame.size.width/2), (UIScreen.mainScreen().bounds.size.height * 0.1) + ((_button.frame.height  + verticalLineLength) * CGFloat(i)))
                _button.addTarget(self, action: "projectSelected:", forControlEvents: .TouchUpInside)
                projectLeafs.append(ProjectLeaf(_project:item,_button:_button))
                self.addSubview(_button)
                i++
            }

        }
        self.setNeedsDisplay()
    }
    
    func fetchFilepointsFromProject()
    {
       
        var i = 0
        for item in currentProjectLeaf.project.filepoints
        {

            var filePointItem = item as Filepoint
            var image = UIImage(data: filePointItem.file!)
            var xOffset = currentProjectLeaf.button.center.x
            var yOffset = currentProjectLeaf.button.center.y
            var _button = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
            _button.frame =  CGRectMake(0, 0, leafSize.width, leafSize.height)
            _button.setImage(image, forState: UIControlState.Normal)
            _button.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
            _button.center = CGPointMake(xOffset + _button.frame.size.width + horizontalLineLength, yOffset + ((_button.frame.height + verticalLineLength) * CGFloat(i)))
            _button.addTarget(self, action: "filepointSelectedFromFilepoint:", forControlEvents: .TouchUpInside)
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
            var filePointItem = item as Filepoint
            var image = UIImage(data: filePointItem.file!)
            var xOffset = filepointLeaf.button.center.x
            var yOffset = filepointLeaf.button.center.y
            var _button = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
            _button.frame =  CGRectMake(0, 0, 60, 40)
            _button.setImage(image, forState: UIControlState.Normal)
            _button.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
            _button.center = CGPointMake(xOffset + _button.frame.size.width + horizontalLineLength, yOffset +  ((_button.frame.height + verticalLineLength) * CGFloat(i)))
            _button.addTarget(self, action: "filepointSelectedFromFilepoint:", forControlEvents: .TouchUpInside)
            filepointLeaf.filepointLeafs.append(FilepointLeaf(_filePoint:item as Filepoint,_button:_button,_parent:nil))
            self.addSubview(_button)
            i++
            }
        }
        for item in filepointLeaf.filepoint.filepoints
        {
            if((item as Filepoint).x == 0 && (item as Filepoint).y == 0)
            {
                var filePointItem = item as Filepoint
                var image = UIImage(data: filePointItem.file!)
                var xOffset = filepointLeaf.button.center.x
                var yOffset = filepointLeaf.button.center.y
                var _button = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
                _button.frame =  CGRectMake(0, 0, 60, 40)
                _button.setImage(image, forState: UIControlState.Normal)
                _button.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
                _button.center = CGPointMake(xOffset + _button.frame.size.width + horizontalLineLength, yOffset +  ((_button.frame.height + verticalLineLength) * CGFloat(i)))
                _button.addTarget(self, action: "filepointSelectedFromFilepoint:", forControlEvents: .TouchUpInside)
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
   
    
    
    func findSelecedFilepointLeaf(filepointLeaf:FilepointLeaf, buttonPushed:UIButton)
    {
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
    
    
    func filepointSelectedFromFilepoint(sender:AnyObject)
    {
       
        var filepointLeafs = currentProjectLeaf.filepointLeafs
        for var i = 0 ;  i < filepointLeafs.count ; i++
        {
            if(filepointLeafs[i].button == (sender as UIButton))
            {
                currentFilepointLeaf = filepointLeafs[i]
                selectedLeaf.hidden = false
                selectedLeaf.center = currentFilepointLeaf.button.center
            }
            else
            {
                findSelecedFilepointLeaf(filepointLeafs[i],buttonPushed: (sender as UIButton))
            }
        }
        
        currentFilepointLeaf.selected = true

        self.bringSubviewToFront(jumpToFilepointButton)
        var jumpToFilepointButtonY = currentFilepointLeaf.button.center.y > self.frame.height / 2 ? currentFilepointLeaf.button.center.y - currentFilepointLeaf.button.frame.height : currentFilepointLeaf.button.center.y + currentFilepointLeaf.button.frame.height
        var jumpToFilepointButtonX = currentFilepointLeaf.button.center.x > self.frame.width / 2 ? currentFilepointLeaf.button.center.x - currentFilepointLeaf.button.frame.width : currentFilepointLeaf.button.center.x + currentFilepointLeaf.button.frame.width
        jumpToFilepointButton.alpha = 0.75
        jumpToFilepointButton.center = CGPointMake(jumpToFilepointButtonX,jumpToFilepointButtonY)
        
        
        //remove all buttons
        removeProjectLeafs()
        
        buildNodesUpToSelectedNode()
        
        setNeedsDisplay()
    }
    
    
    func projectSelected(sender:AnyObject)
    {
        //remove all buttons
        removeProjectLeafs()
        
        for var i = 0 ;  i < projectLeafs.count ; i++
        {
            if(projectLeafs[i].button == (sender as UIButton))
            {
                currentProjectLeaf = projectLeafs[i]
                selectedLeaf.hidden = false
                selectedLeaf.center = currentProjectLeaf.button.center
            }
            
            projectLeafs[i].selected = false
            projectLeafs[i].button.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
        }
        
        
        //(sender as UIButton).backgroundColor = UIColor.redColor()
        
        currentProjectLeaf.selected = true
        jumpToFilepointButton.alpha = 0
        
        fetchFilepointsFromProject()
        
        /*
        self.bringSubviewToFront(jumpToFilepointButton)
        jumpToFilepointButton.alpha = 0.75
        var jumpToFilepointButtonY = currentProjectLeaf.button.center.y > self.frame.height / 2 ? currentProjectLeaf.button.center.y - currentProjectLeaf.button.frame.height : currentProjectLeaf.button.center.y + currentProjectLeaf.button.frame.height
        jumpToFilepointButton.center = CGPointMake(currentProjectLeaf.button.center.x + currentProjectLeaf.button.frame.width ,jumpToFilepointButtonY)
        */
        
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
        for filepointLeafItem in filepointLeaf.filepointLeafs
        {
            if(isOnBranchWith(filepointLeafItem.filepoint, onBranchWith:currentFilepointLeaf.filepoint))
            {
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
    
    func jumpToFilepoint()
    {
        
        delegate?.jumpToFilepoint()
    }
}