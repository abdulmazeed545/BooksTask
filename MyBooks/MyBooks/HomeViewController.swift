import UIKit
import Combine

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var productsListTV:UITableView!
    private let viewModel = ProductListViewModel()
    private var cancellables = Set<AnyCancellable>()
    var products:[Product] = []{
        didSet{
            DispatchQueue.main.async{
                self.productsListTV.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupPDFButton()
        bindViewModel()
        
        if let url = URL(string: "https://api.restful-api.dev/objects") {
            viewModel.fetchProducts(from: url)
        }
    }
    
    private func setupTableView() {
        
        productsListTV.dataSource = self
        productsListTV.delegate = self
        productsListTV.register(UINib(nibName: ProductListTVC.identifier, bundle: nil), forCellReuseIdentifier: ProductListTVC.identifier)
    }
    
    private func setupPDFButton() {
        let pdfButton = UIButton(type: .system)
        pdfButton.setTitle("Open PDF", for: .normal)
        pdfButton.translatesAutoresizingMaskIntoConstraints = false
        pdfButton.addTarget(self, action: #selector(openPDFButtonTapped), for: .touchUpInside)
        view.addSubview(pdfButton)
        NSLayoutConstraint.activate([
            pdfButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            pdfButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @IBAction func openPDFButtonTapped(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "PDFViewerViewController") as? PDFViewerViewController else {return}
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func bindViewModel() {
        viewModel.$products
            .receive(on: DispatchQueue.main)
            .sink { [weak self]  productsList in
//                self?.products = productsList
                self?.productsListTV.reloadData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductListTVC.identifier, for: indexPath) as? ProductListTVC else {return UITableViewCell()}
        let product = viewModel.products[indexPath.row]
        cell.updateData(obj: product)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Handle selection if needed
    }
} 
