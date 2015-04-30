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
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    
    var projectItems = [Project]()

    
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
        let fetchRequest = NSFetchRequest(entityName: "Project")
        
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Project] {
            projectItems = fetchResults
        }
    }

    
    func populateProject()
    {
        Project.createInManagedObjectContext(self.managedObjectContext!, title: "a title", lat: -23.3453, long: 12.2323)
        
        save()
    }


    
    func save() {
        var error : NSError?
        if(managedObjectContext!.save(&error) ) {
            println(error?.localizedDescription)
        }
    }

   
    
}
