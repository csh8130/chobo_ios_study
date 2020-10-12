//
//  ListViewController.swift
//  Chapter05-CustomPlist
//
//  Created by Choi SeungHyuk on 2020/10/11.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var accountlist = [String]()
    
    @IBOutlet weak var account: UITextField!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var gender: UISegmentedControl!
    @IBOutlet weak var married: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let picker = UIPickerView()
        picker.delegate = self
        self.account.inputView = picker
        
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 35)
        toolbar.barTintColor = .lightGray
        self.account.inputAccessoryView = toolbar
        
        let done = UIBarButtonItem()
        done.title = "Done"
        done.target = self
        done.action = #selector(pickerDone)
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let new = UIBarButtonItem()
        new.title = "New"
        new.target = self
        new.action = #selector(newAccount(_:))
        
        toolbar.setItems([new, flexSpace, done], animated: true)
        
        let plist = UserDefaults.standard
        
        let accountlist = plist.array(forKey: "accountlist") as? [String] ?? [String]()
        self.accountlist = accountlist
        if let account = plist.string(forKey: "selectedAccount") {
            self.account.text = account
            
            let customPlist = "\(account).plist"
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let path = paths[0] as NSString
            let clist = path.strings(byAppendingPaths: [customPlist]).first!
            let data = NSDictionary(contentsOfFile: clist) ?? NSDictionary()
            
            self.name.text = data["name"] as? String
            self.gender.selectedSegmentIndex = data["gender"] as? Int ?? 0
            self.married.isOn = data["married"] as? Bool ?? false
        }
        
        if (self.account.text?.isEmpty)! {
            self.account.placeholder = "등록된 계정이 없습니다."
            self.gender.isEnabled = false
            self.married.isEnabled = false
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.accountlist.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.accountlist[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let account = self.accountlist[row]
        self.account.text = account
        
        let plist = UserDefaults.standard
        plist.set(account, forKey: "selectedAccount")
        plist.synchronize()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 && !(self.account.text?.isEmpty)! {
            let alert = UIAlertController(title: nil, message: "이름을 입력하세요", preferredStyle: .alert)
            alert.addTextField {
                $0.text = self.name.text
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                let value = alert.textFields?[0].text
                
                let customPlist = "\(self.account.text!).plist"
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                let path = paths[0] as NSString
                let plist = path.strings(byAppendingPaths: [customPlist]).first!
                let data = NSMutableDictionary(contentsOfFile: plist) ?? NSMutableDictionary()
                data.setValue(value, forKey: "name")
                data.write(toFile: plist, atomically: true)
                
                self.name.text = value
            }))
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    @objc func pickerDone(_ sender: Any) {
        self.view.endEditing(true)
        
        if let account = self.account.text {
            self.account.text = account
            
            let customPlist = "\(account).plist"
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let path = paths[0] as NSString
            let clist = path.strings(byAppendingPaths: [customPlist]).first!
            let data = NSDictionary(contentsOfFile: clist) ?? NSDictionary()
            
            self.name.text = data["name"] as? String
            self.gender.selectedSegmentIndex = data["gender"] as? Int ?? 0
            self.married.isOn = data["married"] as? Bool ?? false
        }
    }
    
    @objc func newAccount(_ sender: Any) {
        self.view.endEditing(true)
        let alert = UIAlertController(title: "새 계정을 입력하세요", message: nil, preferredStyle: .alert)
        alert.addTextField {
            $0.placeholder = "ex) abc@gmail.com"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if let account = alert.textFields?[0].text {
                self.accountlist.append(account)
                self.account.text = account
                
                self.name.text = ""
                self.gender.selectedSegmentIndex = 0
                self.married.isOn = false
                
                let plist = UserDefaults.standard
                plist.set(self.accountlist, forKey: "accountlist")
                plist.set(account, forKey: "selectedAccount")
                plist.synchronize()
                
                self.gender.isEnabled = true
                self.married.isEnabled = true
            }
        }))
        self.present(alert, animated: false, completion: nil)
    }
    
    @IBAction func changeGender(_ sender: UISegmentedControl) {
        let value = sender.selectedSegmentIndex
        
        let customPlist = "\(self.account.text!).plist"
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0] as NSString
        let plist = path.strings(byAppendingPaths: [customPlist]).first!
        let data = NSMutableDictionary(contentsOfFile: plist) ?? NSMutableDictionary()
        data.setValue(value, forKey: "gender")
        data.write(toFile: plist, atomically: true)
    }
    
    @IBAction func changeMarried(_ sender: UISwitch) {
        let value = sender.isOn
        
        let customPlist = "\(self.account.text!).plist"
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0] as NSString
        let plist = path.strings(byAppendingPaths: [customPlist]).first!
        let data = NSMutableDictionary(contentsOfFile: plist) ?? NSMutableDictionary()
        data.setValue(value, forKey: "married")
        data.write(toFile: plist, atomically: true)
    }

}
