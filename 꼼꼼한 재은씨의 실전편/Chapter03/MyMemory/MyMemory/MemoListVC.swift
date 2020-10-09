//
//  MemoListVC.swift
//  MyMemory
//
//  Created by Choi SeungHyuk on 2020/09/17.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit

class MemoListVC: UITableViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.appDelegate.memolist.count
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.appDelegate.memolist[indexPath.row]
        let cellId = row.image == nil ? "memoCell" : "memoCellWithImage"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? MemoCell else {
            return UITableViewCell()
        }
        
        cell.subject?.text = row.title
        cell.contents?.text = row.contents
        cell.img?.image = row.image
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        cell.regdate?.text = formatter.string(from: row.regdate!)
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "memoCellWithImageSegue" || segue.identifier == "memoCellSegue" {
            let vc = segue.destination as? MemoReadVC
            let selectedIndex = tableView.indexPathForSelectedRow!.row
            vc?.param = self.appDelegate.memolist[selectedIndex]
        }
    }
}
