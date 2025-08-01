//
//  ViewController.swift
//  AIChatPractice
//
//  Created by 香村彩奈 on 2025/07/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var outputView: UITextView!
    @IBOutlet weak var sendButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        outputView.text = "ここに返答が表示されます..."
        outputView.isEditable = false
    }

    @IBAction func sendTapped(_ sender: UIButton) {
        guard let message = messageField.text, !message.isEmpty else { return }

        sendButton.isEnabled = false
        outputView.text = "考え中..."

        APIClient.shared.streamChatResponse(
            message: message,
            onReceive: { [weak self] chunk in
                self?.outputView.text.append(chunk)
            },
            onComplete: { [weak self] in
                self?.outputView.text.append("\n\n✅ 完了！")
                self?.sendButton.isEnabled = true
            },
            onError: { [weak self] error in
                self?.outputView.text = "❌ エラー: \(error.localizedDescription)"
                self?.sendButton.isEnabled = true
            }
        )
    }
}

