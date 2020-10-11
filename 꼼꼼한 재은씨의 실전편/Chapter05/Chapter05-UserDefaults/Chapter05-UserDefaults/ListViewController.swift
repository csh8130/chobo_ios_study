//
//  ListViewController.swift
//  Chapter05-UserDefaults
//
//  Created by Choi SeungHyuk on 2020/10/11.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var gender: UISegmentedControl!
    @IBOutlet weak var married: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let plist = UserDefaults.standard
        self.name.text = plist.string(forKey: "name")
        self.married.isOn = plist.bool(forKey: "married")
        self.gender.selectedSegmentIndex = plist.integer(forKey: "gender")
    }
    @IBAction func changeGender(_ sender: UISegmentedControl) {
        let value = sender.selectedSegmentIndex
        let plist = UserDefaults.standard
        plist.set(value, forKey: "gender")
        plist.synchronize()
    }
    @IBAction func changeMarried(_ sender: UISwitch) {
        let value = sender.isOn
        let plist = UserDefaults.standard
        plist.set(value, forKey: "married")
        plist.synchronize()
    }
    
    @IBAction func edit(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "이름을 입력하세요", preferredStyle: .alert)
        alert.addTextField {
            $0.text = self.name.text
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            let value = alert.textFields?[0].text
            let plist = UserDefaults.standard
            plist.setValue(value, forKey: "name")
            plist.synchronize()
            self.name.text = value
        }))
        self.present(alert, animated: false, completion: nil)
    }
}
