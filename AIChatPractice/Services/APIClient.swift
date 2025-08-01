import Foundation

class APIClient {
    static let shared = APIClient()
    private init() {}

    func streamChatResponse(message: String, onReceive: @escaping (String) -> Void, onComplete: @escaping () -> Void, onError: @escaping (Error) -> Void) {
        guard let url = URL(string: "http://localhost:3000/api/stream") else {
            onError(NSError(domain: "Invalid URL", code: -1))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let json: [String: String] = ["message": message]
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    onError(error)
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    onError(NSError(domain: "No data", code: -1))
                }
                return
            }

            let string = String(decoding: data, as: UTF8.self)
            DispatchQueue.main.async {
                onReceive(string)
                onComplete()
            }
        }

        task.resume()
    }
}
