//
//  DrawingBase.swift
//  GeoFile
//
//  Created by knut on 12/05/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import Foundation
class DrawingBase: UIView{
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame:CGRect)
    {
        super.init(frame: frame)
    }
    
    //TODO: is used both in drawview and here .....  implement a separate class for drawing helper methods
    func drawDisclosureLine(ctxt:CGContextRef, x:CGFloat, y:CGFloat , angle:CGFloat)
    {
       
        CGContextSaveGState(ctxt)
        
        var newPoint = CGPointMake(x, y)
        let pi:CGFloat =  CGFloat(M_PI)
        var distance:CGFloat = 8
        var angleInRadians:CGFloat = pi / CGFloat(180.0) * ((360 - angle) % 360)
        var point1 = CGPointMake(newPoint.x + CGFloat(distance) * CGFloat(sinf(Float(angleInRadians))), newPoint.y + CGFloat(distance) * CGFloat(cosf(Float(angleInRadians))));
        angleInRadians = pi / CGFloat(180.0) * ((180 - angle) % 360)
        var point2 = CGPointMake(newPoint.x + CGFloat(distance) * CGFloat(sinf(Float(angleInRadians))), newPoint.y + CGFloat(distance) * CGFloat(cosf(Float(angleInRadians))));
        
        CGContextMoveToPoint(ctxt, point1.x, point1.y)
        CGContextAddLineToPoint(ctxt, x, y)
        CGContextAddLineToPoint(ctxt, point2.x, point2.y)
        
        
        CGContextSetLineCap(ctxt, kCGLineCapSquare)
        CGContextSetLineJoin(ctxt, kCGLineJoinMiter)
        CGContextSetLineWidth(ctxt, 4)
        
        CGContextStrokePath(ctxt)
        CGContextRestoreGState(ctxt)
    }
    
    //TODO: is used both in drawview and here .....  implement a separate class for drawing helper methods
    func setStrokeColor(context: CGContext,color:drawColorEnum)
    {
        switch(color)
        {
        case .black:
            CGContextSetRGBStrokeColor(context, 0, 0, 0, 1)
        case .white:
            CGContextSetRGBStrokeColor(context, 1, 1, 1, 1)
        case .red:
            CGContextSetRGBStrokeColor(context, 1, 0, 0, 1)
        case .blue:
            CGContextSetRGBStrokeColor(context, 0, 0, 1, 1)
        default:
            CGContextSetRGBStrokeColor(context, 1, 1, 1, 1)
        }
    }
    
    //TODO: is used both in drawview and here .....  implement a separate class for drawing helper methods
    func IsClockwise(vertices:[CGPoint]) -> Bool
    {
        
        var area:CGFloat = 0
        for (var i = 0; i < (vertices.count); i++)
        {
            var j = (i + 1) % vertices.count;
            area += vertices[i].x * vertices[j].y;
            area -= vertices[j].x * vertices[i].y;
            
        }
        return (area < 0);
    }
    
    
    
    
    //TODO: is used both in drawview and here .....  implement a separate class for drawing helper methods
    func drawDisclosureIndicator(ctxt:CGContextRef, x:CGFloat, y:CGFloat , pointRight:Bool = true)
    {
        let R:CGFloat = 4.5 // "radius" of the arrow head
        
        CGContextSaveGState(ctxt)
        
        //
        
        if(pointRight)
        {
            CGContextMoveToPoint(ctxt, x-R, y-R)
            CGContextAddLineToPoint(ctxt, x, y)
            CGContextAddLineToPoint(ctxt, x-R, y+R)
            
        }
        else
        {
            CGContextMoveToPoint(ctxt, x+R, y-R)
            CGContextAddLineToPoint(ctxt, x, y)
            CGContextAddLineToPoint(ctxt, x+R, y+R)
        }
        CGContextSetLineCap(ctxt, kCGLineCapSquare)
        CGContextSetLineJoin(ctxt, kCGLineJoinMiter)
        CGContextSetLineWidth(ctxt, 4)
        
        //CGContextRotateCTM(ctxt,45.0)
        
        CGContextStrokePath(ctxt)
        
        
        
        CGContextRestoreGState(ctxt)
    }
    //TODO: is used both in drawview and here .....  implement a separate class for drawing helper methods
    func getFixedPoint(p1:CGPoint, p2:CGPoint) -> (point:CGPoint,shouldTurn180:Bool)
    {
        
        if(p1.x < p2.x && p1.y > p2.y)
        {
            //upright
            return (CGPointMake(min(p1.x,p2.x), max(p1.y,p2.y)),false)
        }
        else if(p1.x > p2.x && p1.y < p2.y)
        {
            //downleft
            return (CGPointMake(max(p1.x,p2.x), min(p1.y,p2.y)),true)
        }
        else if(p1.x > p2.x && p1.y > p2.y)
        {
            //upleft
            return (CGPointMake(max(p1.x,p2.x), max(p1.y,p2.y)),true)
        }
        else //if(p1.x > p2.x && p1.y > p2.y)
        {
            return (CGPointMake(min(p1.x,p2.x), min(p1.y,p2.y)),false)
        }
    }
    
    //TODO: is used both in drawview and here .....  implement a separate class for drawing helper methods
    func angleOfPointsToFixedPoint(p1:CGPoint, p2:CGPoint,  fixed:CGPoint? = nil) -> CGFloat
    {
        var fixedPoint = getFixedPoint(p1,p2: p2)
        if( fixed != nil)
        {
            fixedPoint = (fixed!,shouldTurn180:false)
        }
        
        
        let v1 = CGVector(dx: p1.x - fixedPoint.point.x, dy: p1.y - fixedPoint.point.y)
        let v2 = CGVector(dx: p2.x - fixedPoint.point.x, dy: p2.y - fixedPoint.point.y)
        
        let angle = atan2(v2.dy, v2.dx) - atan2(v1.dy, v1.dx)
        
        var deg = angle * CGFloat(180.0 / M_PI)
        
        if deg < 0 { deg += 360.0 }
        
        
        return (deg + (fixedPoint.shouldTurn180 ? 180.0:0.0))
    }
    //TODO: is used both in drawview and here .....  implement a separate class for drawing helper methods
    func getPointBetweenPoints(p1:CGPoint, p2:CGPoint, offset: CGPoint) -> CGPoint
    {
        
        var point1 = CGPointMake(p1.x + offset.x, p1.y + offset.y)
        var point2 = CGPointMake(p2.x + offset.x, p2.y + offset.y)
        
        //upright or
        if((p1.x < p2.x && p1.y > p2.y) || (p1.x > p2.x && p1.y < p2.y))
        {
            point1 = CGPointMake(p1.x - offset.x, p1.y + offset.y)
            point2 = CGPointMake(p2.x - offset.x, p2.y + offset.y)
        }
        
        var xVal = (point1.x + point2.x ) / 2
        var yVal = (point1.y + point2.y) / 2
        
        return CGPointMake(xVal, yVal)
        
    }
    
    //TODO: is used both in drawview and here .....  implement a separate class for drawing helper methods
    func pointPairToBearingDegrees(startingPoint:CGPoint, endingPoint:CGPoint) -> CGFloat
    {
        var originPoint = CGPointMake(endingPoint.x - startingPoint.x, endingPoint.y - startingPoint.y); // get origin point to origin by subtracting end from start
        var bearingRadians = atan2f(Float(originPoint.y), Float(originPoint.x)); // get bearing in radians
        var bearingDegrees = bearingRadians * (180.0 / Float(M_PI)); // convert to degrees
        bearingDegrees = (bearingDegrees > 0.0 ? bearingDegrees : (360.0 + bearingDegrees)); // correct discontinuity
        return CGFloat(bearingDegrees);
    }

    
}