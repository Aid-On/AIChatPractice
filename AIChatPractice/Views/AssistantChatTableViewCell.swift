//
//  ChatTableViewCell.swift
//  AIChatPractice
//
//  Created by 香村彩奈 on 2025/07/22.
//

import UIKit

class AssistantChatTableViewCell: UITableViewCell {

//    static func nib() -> UINib{
//        return UINib(nibName: "ChatTableViewCell", bundle: nil)
//    }
    @IBOutlet var roundedView: UIView!
    
    @IBOutlet weak var Textlabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        roundedView = UIView()
//        roundedView.backgroundColor = UIColor.gray
        // 角を丸める
        roundedView.layer.cornerRadius = 10
        Textlabel.numberOfLines = 0
        Textlabel.sizeToFit()
        Textlabel.widthAnchor.constraint(lessThanOrEqualToConstant: 270).isActive = true
    }

    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    
}
