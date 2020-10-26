//
//  DepartmentDAO.swift
//  Chapter06-HR
//
//  Created by Choi SeungHyuk on 2020/10/26.
//  Copyright © 2020 test. All rights reserved.
//

import Foundation

class DepartmentDAO {
    typealias DepartRecord = (Int, String, String)
    
    lazy var fmdb: FMDatabase! = {
        let fileMgr = FileManager.default
        let docPath = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first
        let dbPath = docPath!.appendingPathComponent("hr.sqlite").path
        if fileMgr.fileExists(atPath: dbPath) == false {
            let dbSource = Bundle.main.path(forResource: "hr", ofType: "sqlite")
            try! fileMgr.copyItem(atPath: dbSource!, toPath: dbPath)
        }
        
        let db = FMDatabase(path: dbPath)
        return db
    }()
    
    init() {
        self.fmdb.open()
    }
    
    deinit {
        self.fmdb.close()
    }
    
    func find() -> [DepartRecord] {
        var departList = [DepartRecord]()
        
        do {
            let sql = """
SELECT depart_cd, depart_title, depart_addr
FROM department
ORDER BY depart_cd ASC
"""
            let rs = try self.fmdb.executeQuery(sql, values: nil)
            while rs.next() {
                let departCd = rs.int(forColumn: "depart_cd")
                let departTitle = rs.string(forColumn: "depart_title")
                let departAddr = rs.string(forColumn: "depart_addr")
                
                departList.append((Int(departCd), departTitle!, departAddr!))
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        return departList
    }
    
    func get(departCd: Int) -> DepartRecord? {
            do {
                let sql = """
    SELECT depart_cd, depart_title, depart_addr
    FROM department
    WHERE depart_cd = ?
    """
                let rs = self.fmdb.executeQuery(sql, withArgumentsIn: [departCd])
                if let _rs = rs {
                    _rs.next()
                    let departId = _rs.int(forColumn: "depart_cd")
                    let departTitle = _rs.string(forColumn: "depart_title")
                    let departAddr = _rs.string(forColumn: "depart_addr")
                    
                    return (Int(departId), departTitle!, departAddr!)
                } else {
                    return nil
                }
        }
    }
    
    func create(title: String!, addr: String!) -> Bool {
        do {
            let sql = """
INSERT INTO department (depart_title, depart_addr)
VALUES ( ?, ? )
"""
            try self.fmdb.executeUpdate(sql, values: [title!, addr!])
            return true
        } catch let error as NSError {
            print("Insert Error : \(error.localizedDescription)")
            return false
        }
    }
    
    func remove(departCd: Int) -> Bool {
      do {
        let sql = "DELETE FROM department WHERE depart_cd= ? "
        try self.fmdb.executeUpdate(sql, values: [departCd])
        return true
      } catch let error as NSError {
        print("DELETE Error : \(error.localizedDescription)")
        return false
      }
    }
}
