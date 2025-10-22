import Foundation
import UIKit

protocol ProfilePresenter {
    func viewDidLoad()
    func didTapEditProfile()
    func didTapMyNFTs()
    func didTapFavoriteNFTs()
    func didTapWebsite()
}

enum ProfileState {
    case initial, loading, failed(Error), data(User)
}

protocol ProfileView: AnyObject, ErrorView, LoadingView {
    func displayProfile(_ user: User)
    func showEmptyState()
    func showWebView(with url: URL)
    func presentEditProfile(_ viewController: UIViewController)
    func dismissEditProfile()
    func updateAvatar(_ image: UIImage?)
    func navigateToMyNFTs()
    func navigateToFavoriteNFTs()
}

final class ProfilePresenterImpl: ProfilePresenter {
    
    weak var view: ProfileView?
    private let input: ProfileInput
    private let service: ProfileService
    private var state = ProfileState.initial {
        didSet {
            stateDidChanged()
        }
    }
    
    init(input: ProfileInput, service: ProfileService) {
        self.input = input
        self.service = service
    }
    
    func viewDidLoad() {
        state = .loading
    }
    
    func didTapEditProfile() {
        guard case .data(let user) = state else { return }
        
        let editViewController = EditProfileViewController(
            user: user,
            currentAvatarImage: (view as? ProfileViewController)?.currentAvatarImage,
            onSave: { [weak self] updatedUser in
                self?.updateProfile(updatedUser)
            },
            onCancel: { [weak self] in
                self?.view?.dismissEditProfile()
            }
        )
        
        view?.presentEditProfile(editViewController)
    }
    
    func didTapMyNFTs() {
        view?.navigateToMyNFTs()
    }
    
    func didTapFavoriteNFTs() {
        view?.navigateToFavoriteNFTs()
    }
    
    func didTapWebsite() {
        guard case .data(let user) = state,
              let website = user.website else { return }
        view?.showWebView(with: website)
    }
    
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
    
    private func updateProfile(_ user: User) {
        service.updateProfile(
            name: user.name,
            description: user.description,
            website: user.website?.absoluteString
        ) { [weak self] result in
            switch result {
            case .success(let updatedUser):
                self?.state = .data(updatedUser)
                self?.view?.dismissEditProfile()
            case .failure(let error):
                self?.view?.showError(ErrorModel(
                    message: error.localizedDescription,
                    actionText: "OK",
                    action: {}
                ))
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
