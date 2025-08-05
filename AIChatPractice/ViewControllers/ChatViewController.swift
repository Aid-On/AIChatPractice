//
//  ChatViewController.swift
//  AIChatPractice
//
//  Created by 香村彩奈 on 2025/07/22.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!

    var messages: [Message] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none // セルの境界線をなしに設定
        //AIのチャットセル
        tableView.register(UINib(nibName: "AssistantChatTableViewCell", bundle: nil), forCellReuseIdentifier: "AssistantChatTableViewCell")
        //ユーザーのチャットセル
        tableView.register(UINib(nibName: "UserChatTableViewCell", bundle: nil), forCellReuseIdentifier: "UserChatTableViewCell")
        //初期メッセージ
        messages.append(Message(role: Message.Role.assistant, content: "こんにちは！メッセージをどうぞ！"))
        tableView.reloadData()
        messageView.applyInputStyle() //入力欄のUI
    }

    @IBAction func sendTapped(_ sender: UIButton) {
            guard let text = messageView.text, !text.isEmpty else { return }

            // ユーザーメッセージを追加
        messages.append(Message(role: Message.Role.user, content: text))
            tableView.reloadData()
//        tableView.beginUpdates()
//        tableView.endUpdates()
            scrollToBottom() //自動スクロール

            messageView.text = ""
            sendButton.isEnabled = false

        messages.append(Message(role: Message.Role.assistant, content: ""))
        tableView.reloadData()
        
            APIClient.shared.streamChatResponse(
                message: text,
                onReceive: { [weak self] chunk in
                    // アシスタントの返答がまだ無ければ作成
//                    if self?.messages.last?.role != .assistant {
//                        self?.messages.append(Message(role: .assistant, content: ""))
//                    }

                    // chunkを追加
                    self?.messages[self!.messages.count - 1].content += chunk
                    self?.tableView.reloadData()
                    self?.view.setNeedsLayout()
                    self?.scrollToBottom()
                },
                onComplete: { [weak self] in
                    self?.sendButton.isEnabled = true
                },
                onError: { [weak self] error in
//                    self?.messages.append(Message(role: .assistant, content: "❌ エラー: \(error.localizedDescription)"))
                    self?.tableView.reloadData()
//                    self?.scrollToBottom()
                    self?.sendButton.isEnabled = true
                }
            )
        }
    
    //自動で会話の最後までスクロールする
//    func scrollToBottom() {
//        guard messages.count > 0 else { return }
//        
//        let indexPath = IndexPath(row: messages.count - 1, section: 0)
//        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//    }
    
    func scrollToBottom(animated: Bool = false) {
        guard messages.count > 0 else { return }

        let indexPath = IndexPath(row: messages.count - 1, section: 0)

        DispatchQueue.main.async {
            if self.tableView.numberOfRows(inSection: 0) > indexPath.row {
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell: UITableViewCell
        
        if message.role == .assistant{
            guard let assistantCell = tableView.dequeueReusableCell(withIdentifier: "AssistantChatTableViewCell", for: indexPath)as? AssistantChatTableViewCell else {
                fatalError("Dequeue failed: AnimalTableViewCell.")
            }
            
            if message.content == ""{
                assistantCell.Textlabel.text = "考え中です..."
            }else{
                assistantCell.Textlabel.text = message.content
            }
            assistantCell.updateConstraintsIfNeeded()
            assistantCell.setNeedsLayout()
            
            cell = assistantCell
        } else if message.role == .user{
            guard let userCell = tableView.dequeueReusableCell(withIdentifier: "UserChatTableViewCell", for: indexPath)as? UserChatTableViewCell else {
                fatalError("Dequeue failed: AnimalTableViewCell.")
            }
            userCell.Textlabel.text = message.content
            cell = userCell
        } else {
            fatalError("想定外のセルです")
        }
        return cell

        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // セルの選択スタイルを.noneにする
        cell.selectionStyle = .none
    }
    

    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: .greatestFiniteMagnitude))
        textViewHeightConstraint.constant = newSize.height
        view.layoutIfNeeded()
    }

    
}
//テキスト入力欄
extension UITextView {
    func applyInputStyle() {
//        self.isScrollEnabled = false
//        self.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
//        self.font = UIFont.systemFont(ofSize: 16)
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.systemGray5.cgColor
    }
}
