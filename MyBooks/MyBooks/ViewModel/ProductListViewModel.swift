import Foundation
import Combine

class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    private var cancellables = Set<AnyCancellable>()
    private let productsManager = ProductsListManager.shared
    
    func loadProducts() {
            isLoading = true
        errorMessage = nil
            
            fetchProducts()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        print("Error: \(error.localizedDescription)")
                    }
                }, receiveValue: { [weak self] products in
                    self?.products = products
                    print("Loaded \(products.count) products")
                })
                .store(in: &cancellables)
        }
    
    //MARK: - Storage related functions
    //Saving the data
    func saveProductsData(products: [Product]){
        for product in products{
            self.productsManager.insertProductsList(productsData: product)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to save product: \(error.localizedDescription)")
                    }
                }, receiveValue: { _ in
                    print("value received")
                })
                .store(in: &self.cancellables)
        }
    }
    
    func fetchProducts() -> AnyPublisher<[Product], Error> {
        // 1. First check local storage
        return ProductsListManager.getProductRecords()
            .flatMap { localRecords -> AnyPublisher<[Product], Error> in
                // 2. Check if local records exist
                if !localRecords.isEmpty {
                    // 3. If local records exist, convert and return them
                    return self.convertToProducts(localRecords)
                } else {
                    // 4. If no local records, fetch from API
                    guard let apiURL = URL(string: "https://api.restful-api.dev/objects") else {
                        return Fail(error: NSError(domain: "", code: -1,
                                                userInfo: [NSLocalizedDescriptionKey: "Invalid API URL"]))
                            .eraseToAnyPublisher()
                    }
                    return self.fetchFromAPI(url: apiURL)
                        .flatMap { apiProducts in
                            // 5. Save API products to local storage
                            self.saveProductsToLocal(apiProducts)
                            // 6. Return the API products
                            return Just(apiProducts)
                                .setFailureType(to: Error.self)
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    // Helper to convert Core Data entities to Products
    private func convertToProducts(_ records: [ProductsEntity]) -> AnyPublisher<[Product], Error> {
        return Future<[Product], Error> { promise in
            var products = [Product]()
            let decoder = JSONDecoder()
            
            for record in records {
                var product = Product()
                product.id = record.id
                product.name = record.name ?? ""
                
                if let dataStr = record.myData,
                   let data = dataStr.data(using: .utf8) {
                    product.data = try? decoder.decode(ProductData.self, from: data)
                }
                
                products.append(product)
            }
            
            promise(.success(products))
        }
        .eraseToAnyPublisher()
    }
    
    // Helper to fetch from API
    private func fetchFromAPI(url: URL) -> AnyPublisher<[Product], Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Product].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    // Helper to save products to local storage
    private func saveProductsToLocal(_ products: [Product]) -> AnyPublisher<Void, Error> {
        let publishers = products.map { product in
            ProductsListManager.shared.insertProductsList(productsData: product)
        }
        
        return Publishers.MergeMany(publishers)
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    // In ProductsViewModel.swift
    func deleteProduct(withId id: String, name: String) -> AnyPublisher<Bool, Error> {
        return ProductsListManager.shared.deleteProduct(byId: id, productName: name)
            .flatMap { [weak self] _ -> AnyPublisher<Bool, Error> in
                // After successful deletion, refresh the products list
                guard let self = self else {
                    return Just(false)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return self.fetchProducts()
                    .map { _ in true }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
