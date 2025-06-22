import Foundation
import Combine

class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    
    func fetchProducts(from url: URL) {
        NetworkManager.shared.request(url: url)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] (products: [Product]) in
                print("products in view model are:", products)
                self?.products = products
            })
            .store(in: &cancellables)
    }
} 
