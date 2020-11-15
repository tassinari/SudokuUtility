//
//  main.swift
//  SudokuMaker
//
//  Created by Mark Tassinari on 11/11/20.
//  Copyright © 2020 Tassinari. All rights reserved.
//

import Foundation
import SudukoUtility
import ArgumentParser
import CoreData


let defaultPuzzleNumber = 100

struct Repeat: ParsableCommand {
    @Flag(name: [.customLong("verbose"), .customShort("v")],help: "Verbose mode")
    var includeCounter = false
    
    @Option(name: [.customLong("max-puzzles"), .customShort("m")], help: "Number of puzzles to add (default is \(defaultPuzzleNumber))")
    var maxPuzzles: Int?
    
    @Argument(help: "Path to exsisting SQLite Database, a new one will be created here if not found")
    var sqlPath: String
    
    mutating func run() throws {
        do {
            try addPuzzles(count: 10)
        } catch  {
            
        }
        
        
    }
}

Repeat.main()

func addPuzzles( count : Int) throws{
    
    let _ = persistentContainer { per in
        let moc : NSManagedObjectContext = per.viewContext
        
        do{
            for _ in 0..<count{
                let p = try SudokuPuzzle.creatPuzzle()
                let r = try p.rate()
                let puzzle = Puzzle(context: moc)
                puzzle.puzzleHash = p.base64Hash
                puzzle.rating = r.rawValue
                puzzle.used = false
                moc.insert(puzzle)
                
            }
            try moc.save()
            let url = URL(fileURLWithPath: "/Users/tassinari/Developer/SuperDoku/test.sqlite")
            let d = per.persistentStoreDescriptions
            
            let store = per.persistentStoreCoordinator.persistentStores.first!
            print(d)
            try per.persistentStoreCoordinator.migratePersistentStore(store, to: url , options: nil, withType: NSSQLiteStoreType)
        }catch{
            
        }
        
    }
    
    
}


// MARK: - Core Data stack
func persistentContainer( completion : @escaping ( NSPersistentContainer)->Void) -> NSPersistentContainer {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    let container = NSPersistentContainer(name: "Puzzle")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error as NSError? {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            /*
             Typical reasons for an error here include:
             * The parent directory does not exist, cannot be created, or disallows writing.
             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
             * The device is out of space.
             * The store could not be migrated to the current model version.
             Check the error message to determine what the actual problem was.
             */
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
        completion(container)
        
    })
    return container
}
