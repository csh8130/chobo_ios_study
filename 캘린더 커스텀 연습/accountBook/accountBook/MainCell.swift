//
//  MainCell.swift
//  accountBook
//
//  Created by Choi SeungHyuk on 2021/01/12.
//

import UIKit

class MainCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var won: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setLayout() {
        let value: Int = Int(won.text!)!
        if value > 0 {
            title.text = "용돈"
            won.textColor = .init(red: 71/255, green: 155/255, blue: 95/255, alpha: 1)
        } else {
            title.text = "지출"
            won.textColor = .init(red: 222/255, green: 139/255, blue: 159/255, alpha: 1)
        }
        won.text = "\(value.currencyKR())원"
    }

}
