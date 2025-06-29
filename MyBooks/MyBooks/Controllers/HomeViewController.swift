import UIKit
import Combine
import FirebaseAuth
import GoogleSignIn

class HomeViewController: UIViewController {
    @IBOutlet weak var productsListTV:UITableView!
    private let viewModel = ProductListViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - viewlifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindViewModel()
        loadData()
        
    }
    
    private func setupTableView() {
        
        productsListTV.dataSource = self
        productsListTV.delegate = self
        productsListTV.register(UINib(nibName: ProductListTVC.identifier, bundle: nil), forCellReuseIdentifier: ProductListTVC.identifier)
    }
    
    @IBAction func openPDFButtonTapped(_ sender: UIButton) {
        guard let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PDFViewerViewController") as? PDFViewerViewController else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnImageTapped(_ sender: UIButton){
        let imagePickerController = ImagePickerSwiftController() // Instantiate your controller
        
        // Present it modally
        // .fullScreen ensures it covers the entire screen, which is common for image pickers
        imagePickerController.modalPresentationStyle = .popover
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func btnSettingsTapped(_ sender: UIButton){
        let settingsVC = SettingsViewController()
        let navController = UINavigationController(rootViewController: settingsVC)
        navController.modalPresentationStyle = .formSheet // or .fullScreen
        present(navController, animated: true)
    }
    
    @IBAction func btnProfileTapped(_ sender: UIButton){
        guard let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func bindViewModel() {
        viewModel.$products
            .receive(on: DispatchQueue.main)
            .sink { [weak self]  productsList in
                self?.productsListTV.reloadData()
            }
            .store(in: &cancellables)
    }
    // MARK: - Data Loading
       private func loadData() {
           viewModel.loadProducts()
       }
}

//MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductListTVC.identifier, for: indexPath) as? ProductListTVC else {return UITableViewCell()}
        let product = viewModel.products[indexPath.row]
        cell.updateData(obj: product)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Handle selection if needed
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            guard let self = self else {
                completion(false)
                return
            }
            
            let product = self.viewModel.products[indexPath.row]
            self.showDeleteConfirmation(for: product, at: indexPath, completion: completion)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func showDeleteConfirmation(for product: Product, at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(
            title: "Delete Product",
            message: "Are you sure you want to delete '\(product.name ?? "this product")'?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        })
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteProductWithAnimation(product, at: indexPath, completion: completion)
        })
        
        present(alert, animated: true)
    }
    
    private func deleteProductWithAnimation(_ product: Product, at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        guard let id = product.id, let name = product.name else {
            completion(false)
            return
        }
        
        // Optimistically remove the row
        viewModel.products.remove(at: indexPath.row)
        productsListTV.deleteRows(at: [indexPath], with: .left)
        
        // Perform actual deletion
        viewModel.deleteProduct(withId: id, name: name)
               .receive(on: DispatchQueue.main)
               .sink(receiveCompletion: { [weak self] completion in
                   if case .failure(let error) = completion {
                       self?.showErrorAlert(error: error)
                       self?.productsListTV.reloadData() // Revert if failed
                   }
               }, receiveValue: { _ in
                   // Success handled by binding
               })
               .store(in: &cancellables)
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}
