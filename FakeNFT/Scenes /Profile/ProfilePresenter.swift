import Foundation

// MARK: - Protocol

protocol ProfilePresenter {
    func viewDidLoad()
    func didTapEditProfile()
    func didTapMyNFTs()
    func didTapFavoriteNFTs()
    func didTapWebsite()
}

// MARK: - State

enum ProfileState {
    case initial, loading, failed(Error), data(User)
}

// MARK: - View Protocol

protocol ProfileView: AnyObject, ErrorView, LoadingView {
    func displayProfile(_ user: User)
    func showEmptyState()
    func showWebView(with url: URL)
}

// MARK: - Presenter Implementation

final class ProfilePresenterImpl: ProfilePresenter {
    
    // MARK: - Properties
    
    weak var view: ProfileView?
    private let input: ProfileInput
    private let service: ProfileService
    private var state = ProfileState.initial {
        didSet {
            stateDidChanged()
        }
    }
    
    // MARK: - Init
    
    init(input: ProfileInput, service: ProfileService) {
        self.input = input
        self.service = service
    }
    
    // MARK: - Functions
    
    func viewDidLoad() {
        state = .loading
    }
    
    func didTapEditProfile() {
        // TODO: Navigate to edit profile screen
    }
    
    func didTapMyNFTs() {
        // TODO: Navigate to My NFTs screen
    }
    
    func didTapFavoriteNFTs() {
        // TODO: Navigate to Favorite NFTs screen
    }
    
    func didTapWebsite() {
        guard case .data(let user) = state,
              let website = user.website else { return }
        view?.showWebView(with: website)
    }
    
    // MARK: - Private Functions
    
    private func stateDidChanged() {
        switch state {
        case .initial:
            assertionFailure("can't move to initial state")
        case .loading:
            view?.showLoading()
            loadProfile()
        case .data(let user):
            view?.hideLoading()
            view?.displayProfile(user)
        case .failed(let error):
            let errorModel = makeErrorModel(error)
            view?.hideLoading()
            view?.showError(errorModel)
        }
    }
    
    private func loadProfile() {
        service.loadProfile { [weak self] result in
            switch result {
            case .success(let user):
                self?.state = .data(user)
            case .failure(let error):
                self?.state = .failed(error)
            }
        }
    }
    
    private func makeErrorModel(_ error: Error) -> ErrorModel {
        ErrorModel(
            message: error.localizedDescription,
            actionText: "Повторить",
            action: { [weak self] in
                self?.state = .loading
            }
        )
    }
}
