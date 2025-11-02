import UIKit

private var imageLoadTaskKey: UInt8 = 0
private var imageLoadRequestKey: UInt8 = 1

extension UIImageView {
    
    private var currentLoadTaskId: UUID? {
        get {
            return objc_getAssociatedObject(self, &imageLoadTaskKey) as? UUID
        }
        set {
            objc_setAssociatedObject(self, &imageLoadTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var currentRequestId: UUID? {
        get {
            return objc_getAssociatedObject(self, &imageLoadRequestKey) as? UUID
        }
        set {
            objc_setAssociatedObject(self, &imageLoadRequestKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func loadImage(from url: URL?, placeholder: UIImage? = nil, cacheService: ImageCacheService) {
        // Cancel any existing load task
        if let taskId = currentLoadTaskId {
            cacheService.cancelLoad(taskId)
        }
        
        // Generate unique ID for this load request
        let requestId = UUID()
        currentRequestId = requestId
        
        // Set placeholder
        self.image = placeholder
        
        guard let url = url else {
            currentLoadTaskId = nil
            return
        }
        
        // Load image
        let taskId = cacheService.loadImage(from: url) { [weak self] result in
            guard let self = self else { return }
            
            // Check if this is still the current request
            guard self.currentRequestId == requestId else {
                return
            }
            
            switch result {
            case .success(let image):
                self.image = image
            case .failure(let error):
                // Keep placeholder on error
                if let nsError = error as NSError?, nsError.code == -1003 {
                    print("⚠️ DNS error - возможно, проблемы с сетью или блокировка домена")
                } else {
                    print("⚠️ Failed to load image: \(error.localizedDescription)")
                }
                // Placeholder уже установлен, ничего не делаем
            }
        }
        
        // Store the task ID for cancellation (can be nil if image was cached)
        currentLoadTaskId = taskId
    }
    
    func cancelImageLoad(cacheService: ImageCacheService) {
        // Invalidate current request
        currentRequestId = nil
        
        // Cancel active task if any
        if let taskId = currentLoadTaskId {
            cacheService.cancelLoad(taskId)
            currentLoadTaskId = nil
        }
    }
}

