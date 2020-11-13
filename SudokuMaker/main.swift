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
import SQLite


let defaultPuzzleNumber = 100

struct Repeat: ParsableCommand {
    @Flag(name: [.customLong("verbose"), .customShort("v")],help: "Verbose mode")
    var includeCounter = false

    @Option(name: [.customLong("max-puzzles"), .customShort("m")], help: "Number of puzzles to add (default is \(defaultPuzzleNumber))")
    var maxPuzzles: Int?

    @Argument(help: "Path to exsisting SQLite Database, a new one will be created here if not found")
    var sqlPath: String

    mutating func run() throws {
        
        do{
            let db = try createDB(path: sqlPath)
            try addPuzzles(db: db, count: 10)
        }catch let e{
            print("DB creation failure -- \(e.localizedDescription)")
        }
        
    }
}

Repeat.main()


//let tableName = "games"
//let idCol = "id"
//let hashCol = "gameHash"
//let ratingCol = "rating"

func createDB(path : String) throws -> Connection{
    let db = try Connection(path)
    let games = Table("games")
    let id = Expression<Int64>("id")
    let hash = Expression<String?>("hash")
    let rating = Expression<Int>("rating")

    try db.run(games.create { t in
        t.column(id, primaryKey: true)
        t.column(hash)
        t.column(rating)
    })
    return db
}

func addPuzzles( db : Connection, count : Int) throws{
    do{
        for _ in 0..<count{
            let p = try SudokuPuzzle.creatPuzzle()
            let r = try p.rate()
            let insert = Table("games").insert(Expression<String?>("hash") <- p.base64Hash, Expression<Int>("rating") <- Int(r.rawValue))
            let rowid = try db.run(insert)
            print("row inserted \(rowid)")
        }
        
        // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
//        for user in try db.prepare(games) {
//            print("id: \(user[id]), name: \(user[name]), email: \(user[email])")
//            // id: 1, name: Optional("Alice"), email: alice@mac.com
//        }
    }catch let e{
        
    }
   
}
