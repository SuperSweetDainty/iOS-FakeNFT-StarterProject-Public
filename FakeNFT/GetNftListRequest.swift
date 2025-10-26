import Foundation

struct GetNftListRequest: NetworkRequest {
    let ids: [String]?
    
    var endpoint: URL? {
        var urlString = "\(RequestConstants.baseURL)/api/v1/nft"
        
        if let ids = ids, !ids.isEmpty {
            let idsParam = ids.map { "id=\($0)" }.joined(separator: "&")
            urlString += "?\(idsParam)"
        }
        
        return URL(string: urlString)
    }
    
    var httpMethod: HttpMethod {
        .get
    }
    
    var dto: Dto? {
        nil
    }
}

