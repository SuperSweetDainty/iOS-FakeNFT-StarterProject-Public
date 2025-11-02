import Foundation

enum NetworkClientError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case parsingError
}

protocol NetworkClient {
    @discardableResult
    func send(request: NetworkRequest,
              completionQueue: DispatchQueue,
              onResponse: @escaping (Result<Data, Error>) -> Void) -> NetworkTask?

    @discardableResult
    func send<T: Decodable>(request: NetworkRequest,
                            type: T.Type,
                            completionQueue: DispatchQueue,
                            onResponse: @escaping (Result<T, Error>) -> Void) -> NetworkTask?
}

extension NetworkClient {

    @discardableResult
    func send(request: NetworkRequest,
              onResponse: @escaping (Result<Data, Error>) -> Void) -> NetworkTask? {
        send(request: request, completionQueue: .main, onResponse: onResponse)
    }

    @discardableResult
    func send<T: Decodable>(request: NetworkRequest,
                            type: T.Type,
                            onResponse: @escaping (Result<T, Error>) -> Void) -> NetworkTask? {
        send(request: request, type: type, completionQueue: .main, onResponse: onResponse)
    }
}

struct DefaultNetworkClient: NetworkClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(session: URLSession = URLSession.shared,
         decoder: JSONDecoder = JSONDecoder(),
         encoder: JSONEncoder = JSONEncoder()) {
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }

    @discardableResult
    func send(
        request: NetworkRequest,
        completionQueue: DispatchQueue,
        onResponse: @escaping (Result<Data, Error>) -> Void
    ) -> NetworkTask? {
        let onResponse: (Result<Data, Error>) -> Void = { result in
            completionQueue.async {
                onResponse(result)
            }
        }
        guard let urlRequest = create(request: request) else { return nil }

        let task = session.dataTask(with: urlRequest) { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                print("❌ NetworkClient: No HTTP response received")
                if let error = error {
                    print("   Error: \(error)")
                }
                onResponse(.failure(NetworkClientError.urlSessionError))
                return
            }

            print("📥 NetworkClient: Received response:")
            print("   Status code: \(response.statusCode)")

            guard 200 ..< 300 ~= response.statusCode else {
                print("❌ NetworkClient: HTTP error \(response.statusCode)")
                onResponse(.failure(NetworkClientError.httpStatusCode(response.statusCode)))
                return
            }

            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("✅ NetworkClient: Success response:")
                print("   Data: \(dataString)")
            }

            if let data = data {
                onResponse(.success(data))
                return
            } else if let error = error {
                print("❌ NetworkClient: Request error: \(error)")
                onResponse(.failure(NetworkClientError.urlRequestError(error)))
                return
            } else {
                print("❌ NetworkClient: Unknown error")
                onResponse(.failure(NetworkClientError.urlSessionError))
                return
            }
        }

        task.resume()

        return DefaultNetworkTask(dataTask: task)
    }

    @discardableResult
    func send<T: Decodable>(
        request: NetworkRequest,
        type: T.Type,
        completionQueue: DispatchQueue,
        onResponse: @escaping (Result<T, Error>) -> Void
    ) -> NetworkTask? {
        return send(request: request, completionQueue: completionQueue) { result in
            switch result {
            case let .success(data):
                self.parse(data: data, type: type, onResponse: onResponse)
            case let .failure(error):
                onResponse(.failure(error))
            }
        }
    }

    private func create(request: NetworkRequest) -> URLRequest? {
        guard let endpoint = request.endpoint else {
            assertionFailure("Empty endpoint")
            return nil
        }

        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = request.httpMethod.rawValue

        urlRequest.addValue(RequestConstants.token, forHTTPHeaderField: "X-Practicum-Mobile-Token")

        if let dtoDictionary = request.dto?.asDictionary() {
            print("📤 NetworkClient: Sending request with body:")
            print("   Method: \(request.httpMethod.rawValue)")
            print("   URL: \(endpoint.absoluteString)")
            print("   Body dictionary: \(dtoDictionary)")
            
            var urlComponents = URLComponents()
            let queryItems = dtoDictionary.map { field in
                URLQueryItem(
                    name: field.key,
                    value: field.value
                    )
            }
            urlComponents.queryItems = queryItems
            urlRequest.httpBody = urlComponents.query?.data(using: .utf8)
            
            if let httpBody = urlRequest.httpBody, let bodyString = String(data: httpBody, encoding: .utf8) {
                print("   Body string: \(bodyString)")
            }
        }

        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        return urlRequest
    }

    private func parse<T: Decodable>(data: Data, type _: T.Type, onResponse: @escaping (Result<T, Error>) -> Void) {
        do {
            let response = try decoder.decode(T.self, from: data)
            onResponse(.success(response))
        } catch {
            onResponse(.failure(NetworkClientError.parsingError))
        }
    }
}
