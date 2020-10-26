//
//  ViewController.swift
//  Chapter06-SQLite3
//
//  Created by Choi SeungHyuk on 2020/10/20.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit
import SQLite3

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dbPath = getDBPath()
        self.dbExecute(dbPath: dbPath)
    }

    func getDBPath() -> String {
        let fileMgr = FileManager()
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docPathURL.appendingPathComponent("db.sqlite").path
        
        if fileMgr.fileExists(atPath: dbPath) == false {
            let dbSource = Bundle.main.path(forResource: "db", ofType: "sqlite")
            try! fileMgr.copyItem(atPath: dbSource!, toPath: dbPath)
        }
        return dbPath
    }
    
//    func dbExecute(dbPath: String) {
//        var db: OpaquePointer? = nil
//        var stmt: OpaquePointer? = nil
//        let sql = "CREATE TABLE IF NOT EXISTS sequence (num INTEGER)"
//
//
//        if sqlite3_open(dbPath, &db) == SQLITE_OK { //데이터 베이스가 연결 되었다면
//            if sqlite3_prepare(db, sql, -1, &stmt, nil) == SQLITE_OK { //SQL 컴파일이 잘 끝났다면
//                if sqlite3_step(stmt) == SQLITE_DONE {
//                    print("Create Table Success!")
//                }
//                sqlite3_finalize(stmt)
//            } else {
//                print("Prepare Statement Fail")
//            }
//            sqlite3_close(db) //db연결을 해제한다
//        } else {
//            print("Database Connect Fail")
//        }
//    }
    
    func dbExecute(dbPath: String) {
        var db: OpaquePointer? = nil
        guard sqlite3_open(dbPath, &db) == SQLITE_OK else {
            print("Database Connect Fail")
            return
        }
        
        defer {
            print("Close Database Connection")
            sqlite3_close(db)
        }
        
        var stmt: OpaquePointer? = nil
        let sql = "CREATE TABLE IF NOT EXISTS sequence (num INTEGER)"
        guard sqlite3_prepare(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            print("Prepare Statement Fail")
            return
        }
        
        defer {
            print("Finalize Statement")
            sqlite3_finalize(stmt)
        }
        
        if sqlite3_step(stmt) == SQLITE_DONE {
            print("Create Table Success!")
        }
    }
}

