//
//  DetailViewController.swift
//  accountBook
//
//  Created by Choi SeungHyuk on 2021/01/12.
//

import UIKit

class DetailViewController: UIViewController {

    var closeHandler: (Int, Bool)->(Void) = { _, _ in }
    
    var date: Date?
    @IBOutlet weak var dayTitle: UILabel!
    @IBOutlet weak var input: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dayTitle.text = "\(date)"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func pay(_ sender: Any) {
        closeHandler(-Int(input.text!)!, true)
        dismiss(animated: true)
    }
    
    @IBAction func payMoney(_ sender: Any) {
        closeHandler(-Int(input.text!)!, false)
        dismiss(animated: true)
    }
    
    @IBAction func plus(_ sender: Any) {
        closeHandler(Int(input.text!)!, true)
        dismiss(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
