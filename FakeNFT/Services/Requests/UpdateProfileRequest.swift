import Foundation

struct UpdateProfileDto: Dto {
    let name: String?
    let description: String?
    let website: String?
    let likes: [String]?
    
    func asDictionary() -> [String: String] {
        var dict: [String: String] = [:]
        
        if let name = name {
            dict["name"] = name
        }
        
        if let description = description {
            dict["description"] = description
        }
        
        if let website = website {
            dict["website"] = website
        }
        
        if let likes = likes {
            dict["likes"] = likes.joined(separator: ",")
        }
        
        return dict
    }
}

struct UpdateProfileRequest: NetworkRequest {
    let profileId: String
    let profileDto: UpdateProfileDto
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/\(profileId)")
    }
    
    var httpMethod: HttpMethod {
        .put
    }
    
    var dto: Dto? {
        profileDto
    }
}

