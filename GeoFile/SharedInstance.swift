//
//  SharedInstance.swift
//  GeoFile
//
//  Created by knut on 28/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

class Singleton {
    var pdfImages:[UIImage] = []
    class var sharedInstance: Singleton {
        struct Static {
            static var instance: Singleton?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = Singleton()
        }
        
        return Static.instance!
    }

}
