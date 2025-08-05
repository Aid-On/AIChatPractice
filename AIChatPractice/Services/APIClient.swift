//import Foundation
//
//class APIClient: NSObject,URLSessionDelegate {
//    static let shared = APIClient()
//    private override init() {}
//    
//    private var onReceive: ((String) -> Void)?
//    private var onComplete: (() -> Void)?
//    private var onError: ((Error) -> Void)?
//
//    func streamChatResponse(message: String, onReceive: @escaping (String) -> Void, onComplete: @escaping () -> Void, onError: @escaping (Error) -> Void) {
//        guard let url = URL(string: "http://localhost:3000/api/stream") else {
//            onError(NSError(domain: "Invalid URL", code: -1))
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let json: [String: String] = ["message": message]
//        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
//        
//        // ハンドラ保持
//        self.onReceive = onReceive
//        self.onComplete = onComplete
//        self.onError = onError
//
//        // URLSessionをdelegate付きで作成
//        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
//
//        let task = session.dataTask(with: request)
//        task.resume()
//
////        let task = URLSession.shared.dataTask(with: request) { data, response, error in
////            if let error = error {
////                DispatchQueue.main.async {
////                    onError(error)
////                }
////                return
////            }
////
////            guard let data = data else {
////                DispatchQueue.main.async {
////                    onError(NSError(domain: "No data", code: -1))
////                }
////                return
////            }
////
////            let string = String(decoding: data, as: UTF8.self)
////            DispatchQueue.main.async {
////                onReceive(string)
////                onComplete()
////            }
////        }
////
////        task.resume()
//    }
//    
//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
//        if let chunk = String(data: data, encoding: .utf8) {
//            DispatchQueue.main.async {
//                self.onReceive?(chunk)
//            }
//        }
//    }
//
//    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        DispatchQueue.main.async {
//            if let error = error {
//                self.onError?(error)
//            } else {
//                self.onComplete?()
//            }
//        }
//    }
//    
//}

import Foundation

class APIClient: NSObject, URLSessionDataDelegate {
    static let shared = APIClient()
    private override init() {}

    private var onReceive: ((String) -> Void)?
    private var onComplete: (() -> Void)?
    private var onError: ((Error) -> Void)?

    func streamChatResponse(
        message: String,
        onReceive: @escaping (String) -> Void,
        onComplete: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) {
        guard let url = URL(string: "http://localhost:3000/api/stream") else {
            onError(NSError(domain: "Invalid URL", code: -1))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let json: [String: String] = ["message": message]
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)

        // ハンドラ保持
        self.onReceive = onReceive
        self.onComplete = onComplete
        self.onError = onError

        // URLSessionをdelegate付きで作成
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

        let task = session.dataTask(with: request)
        task.resume()
    }

    // MARK: - URLSessionDataDelegate（←これでストリーミングを受け取る）

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let chunk = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                self.onReceive?(chunk)
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                self.onError?(error)
            } else {
                self.onComplete?()
            }
        }
    }
}
