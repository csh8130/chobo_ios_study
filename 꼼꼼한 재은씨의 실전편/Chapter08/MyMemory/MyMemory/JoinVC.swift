//
//  JoinVC.swift
//  MyMemory
//
//  Created by Choi SeungHyuk on 2020/11/09.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit

class JoinVC: UIViewController {
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var fieldAccount: UITextField!
    var fieldPassword: UITextField!
    var fieldName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func submit(_ sender: Any) {
    }
}

extension JoinVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        // 각 테이블 뷰 셀 모두에 공통으로 적용될 프레임 객체
        let tfFrame = CGRect(x: 20, y: 0, width: cell.bounds.width - 20, height: 37)
        switch indexPath.row {
        case 0 :
          self.fieldAccount = UITextField(frame: tfFrame)
          self.fieldAccount.placeholder = "계정(이메일)"
          self.fieldAccount.borderStyle = .none
          self.fieldAccount.autocapitalizationType = .none
          self.fieldAccount.font = UIFont.systemFont(ofSize: 14)
          cell.addSubview(self.fieldAccount)
        case 1 :
          self.fieldPassword = UITextField(frame: tfFrame)
          self.fieldPassword.placeholder = "비밀번호"
          self.fieldPassword.borderStyle = .none
          self.fieldPassword.isSecureTextEntry = true
          self.fieldPassword.font = UIFont.systemFont(ofSize: 14)
          cell.addSubview(self.fieldPassword)
        case 2 :
          self.fieldName = UITextField(frame: tfFrame)
          self.fieldName.placeholder = "이름"
          self.fieldName.borderStyle = .none
          self.fieldName.font = UIFont.systemFont(ofSize: 14)
          cell.addSubview(self.fieldName)
        default :
          ()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 40
    }
    
}
