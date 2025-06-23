//
//  ProductsList.swift
//  MyBooks
//
//  Created by Mazeed on 23/06/25.
//

import UIKit
import Foundation
import CoreData
import Combine


class ProductsListManager: NSObject {
    static let shared = ProductsListManager()
    
    private var coreDataManager = CoreDataManger.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Insert Products
    func insertProductsList(productsData: Product) -> AnyPublisher<Bool, Error> {
        Future<Bool, Error> { [weak self] promise in
            guard let self = self else { return }
            
            let moc = self.coreDataManager.context
            moc.performAndWait {
                guard let productsEntity = NSEntityDescription.entity(forEntityName: EntityName.ProductsEntity, in: moc) else {
                    promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Entity not found"])))
                    return
                }
                
                let productsInfo = NSManagedObject(entity: productsEntity, insertInto: moc)
                
                productsInfo.setValue(productsData.id, forKeyPath: ProductwsEntityKeys.id)
                productsInfo.setValue(productsData.name, forKey: ProductwsEntityKeys.name)
                
                if let products = productsData.data, let productsDetails = products.toJsonString {
                    productsInfo.setValue(productsDetails, forKeyPath: ProductwsEntityKeys.info)
                } else {
                    productsInfo.setValue("", forKeyPath: ProductwsEntityKeys.info)
                }
                
                do {
                    try moc.save()
                    promise(.success(true))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Fetch Products
    static func getProductRecords() -> AnyPublisher<[ProductsEntity], Error> {
        Future<[ProductsEntity], Error> { promise in
            let fetchRequest: NSFetchRequest<ProductsEntity> = ProductsEntity.fetchRequest()
            do {
                let records = try CoreDataManger.shared.context.fetch(fetchRequest)
                promise(.success(records))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchOfflineProducts() -> AnyPublisher<[Product], Error> {
        ProductsListManager.getProductRecords()
            .tryMap { records in
                try records.map { record in
                    var productData = Product()
                    productData.id = record.id
                    productData.name = record.name ?? ""
                    
                    if let strUserData = record.myData, !strUserData.isEmptyString,
                       let data = strUserData.data(using: .utf8) {
                        let decoder = JSONDecoder()
                        productData.data = try decoder.decode(ProductData.self, from: data)
                    }
                    
                    return productData
                }
            }
            .eraseToAnyPublisher()
    }
   
    // Deleting a specific Record in coredata
    func deleteProduct(byId id: String, productName: String?) -> AnyPublisher<Bool, Error> {
        let context = coreDataManager.context
        let fetchRequest: NSFetchRequest<ProductsEntity> = ProductsEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        return Future<Bool, Error> { promise in
            context.performAndWait {
                do {
                    let results = try context.fetch(fetchRequest)
                    guard let productToDelete = results.first else {
                        promise(.failure(NSError(domain: "", code: -1,
                                              userInfo: [NSLocalizedDescriptionKey: "Product not found"])))
                        return
                    }
                    
                    context.delete(productToDelete)
                    try context.save()
                    
                    // Schedule notification
                    // After successful deletion:
                        if let name = productName {
                            DispatchQueue.main.async {
                                // This will now check the setting before sending
                                NotificationManager.shared.scheduleDeletionNotification(for: name)
                            }
                        }
                    
                    promise(.success(true))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
