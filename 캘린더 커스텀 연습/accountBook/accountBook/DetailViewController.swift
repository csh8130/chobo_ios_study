//
//  DetailViewController.swift
//  accountBook
//
//  Created by Choi SeungHyuk on 2021/01/12.
//

import UIKit

class DetailViewController: UIViewController {

    var date: Date?
    @IBOutlet weak var dayTitle: UILabel!
    @IBOutlet weak var input: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func pay(_ sender: Any) {
        
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
