//
//  Test.swift
//  GeoFile
//
//  Created by knut on 05/04/15.
//  Copyright (c) 2015 knut. All rights reserved.
//

import UIKit
import CoreData

class TestViewController: UIViewController {
    
    @IBOutlet weak var testImageView: UIImageView!
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var projectItems = [MapPoint]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchProjects()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchProjects()
    {
        let fetchRequest = NSFetchRequest(entityName: "MapPoint")
        
        
        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [MapPoint] {
            projectItems = fetchResults
        }
    }

    
    func populateProject()
    {
        MapPoint.createInManagedObjectContext(self.managedObjectContext!, title: "a title", lat: -23.3453, long: 12.2323, tags: "")
        
        save()
    }

    func save() {
        do{
            try managedObjectContext!.save()
        } catch {
            print(error)
        }
    }

   
    
}
