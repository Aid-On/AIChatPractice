//
//  ChatViewController.swift
//  AIChatPractice
//
//  Created by 香村彩奈 on 2025/07/22.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var messageField: UITextField!
//    @IBOutlet weak var outputView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var messages: [Message] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        outputView.text = "ここに返答が表示されます..."
//        outputView.isEditable = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none // セルの枠線をなしに設定
        //AIのチャットセル
        tableView.register(UINib(nibName: "AssistantChatTableViewCell", bundle: nil), forCellReuseIdentifier: "AssistantChatTableViewCell")
        //ユーザーのチャットセル
        tableView.register(UINib(nibName: "UserChatTableViewCell", bundle: nil), forCellReuseIdentifier: "UserChatTableViewCell")
//        tableView.estimatedRowHeight = 20 //セルの高さ
//        tableView.rowHeight = UITableView.automaticDimension //自動設定
//        messages.append(Message(role: .assistant, content: "サンプルテキスト"))
        messages.append(Message(role: Message.Role.assistant, content: "こんにちは！メッセージをどうぞ！"))
        tableView.reloadData()
    
    }

    @IBAction func sendTapped(_ sender: UIButton) {
            guard let text = messageField.text, !text.isEmpty else { return }

            // ユーザーメッセージを追加
//            messages.append(Message(role: .user, content: text))
        messages.append(Message(role: Message.Role.user, content: text))
            tableView.reloadData()
//            scrollToBottom()

            messageField.text = ""
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
//                    self?.scrollToBottom()
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
    
//    func scrollToBottom() {
//        guard messages.count > 0 else { return }
//        
//        let indexPath = IndexPath(row: messages.count - 1, section: 0)
//        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//    }
    
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
    //            cell.label.text = "考え中です..."
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
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        tableView.estimatedRowHeight = 100 //セルの高さ
//        return UITableView.automaticDimension //自動設定
//     }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // セルの選択スタイルを.noneにする
        cell.selectionStyle = .none
    }
    
}
