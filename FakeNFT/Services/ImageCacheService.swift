import UIKit

protocol ImageCacheService {
    func loadImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID?
    func cancelLoad(_ id: UUID)
    func prefetchImages(urls: [URL])
    func clearCache()
}

final class ImageCacheServiceImpl: ImageCacheService {
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCacheURL: URL
    private let session: URLSession
    private var activeTasks: [UUID: URLSessionDataTask] = [:]
    private let queue = DispatchQueue(label: "com.fakenft.imagecache", attributes: .concurrent)
    
    init(session: URLSession = .shared) {
        self.session = session
        memoryCache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
        memoryCache.countLimit = 100
        guard let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            fatalError("Unable to access caches directory")
        }
        diskCacheURL = cacheDirectory.appendingPathComponent("ImageCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }
    
    func loadImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {
        let taskId = UUID()
        if let cachedImage = getImageFromMemoryCache(for: url) {
            DispatchQueue.main.async {
                completion(.success(cachedImage))
            }
            return nil
        }
        if let cachedImage = getImageFromDiskCache(for: url) {
            saveImageToMemoryCache(cachedImage, for: url)
            DispatchQueue.main.async {
                completion(.success(cachedImage))
            }
            return nil
        }
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            defer {
                self?.queue.async(flags: .barrier) {
                    self?.activeTasks.removeValue(forKey: taskId)
                }
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(.failure(ImageCacheError.invalidImageData))
                }
                return
            }
            self?.saveImageToMemoryCache(image, for: url)
            self?.saveImageToDiskCache(data, for: url)
            
            DispatchQueue.main.async {
                completion(.success(image))
            }
        }
        
        queue.async(flags: .barrier) { [weak self] in
            self?.activeTasks[taskId] = task
        }
        
        task.resume()
        return taskId
    }
    
    func cancelLoad(_ id: UUID) {
        queue.async(flags: .barrier) { [weak self] in
            if let task = self?.activeTasks[id] {
                task.cancel()
                self?.activeTasks.removeValue(forKey: id)
            }
        }
    }
    
    func prefetchImages(urls: [URL]) {
        for url in urls {
            if getImageFromMemoryCache(for: url) != nil {
                continue
            }
            _ = loadImage(from: url) { _ in
            }
        }
    }
    
    func clearCache() {
        memoryCache.removeAllObjects()
        
        try? FileManager.default.removeItem(at: diskCacheURL)
        try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }
    
    private func getImageFromMemoryCache(for url: URL) -> UIImage? {
        let key = cacheKey(for: url)
        return memoryCache.object(forKey: key as NSString)
    }
    
    private func saveImageToMemoryCache(_ image: UIImage, for url: URL) {
        let key = cacheKey(for: url)
        memoryCache.setObject(image, forKey: key as NSString)
    }
    
    private func getImageFromDiskCache(for url: URL) -> UIImage? {
        let fileURL = diskCacheFileURL(for: url)
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }
    
    private func saveImageToDiskCache(_ data: Data, for url: URL) {
        let fileURL = diskCacheFileURL(for: url)
        try? data.write(to: fileURL)
    }
    
    private func cacheKey(for url: URL) -> String {
        return url.absoluteString
    }
    
    private func diskCacheFileURL(for url: URL) -> URL {
        let fileName = url.absoluteString
            .addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
        return diskCacheURL.appendingPathComponent(fileName)
    }
}

enum ImageCacheError: Error {
    case invalidImageData
    case downloadFailed
}

