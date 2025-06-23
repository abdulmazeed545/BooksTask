//
//  PDFViewController.swift
//  MyBooks
//
//  Created by SK ABDUL MAZEED on 22/06/25.
//

import UIKit
import PDFKit

class PDFViewerViewController: UIViewController {
    var pdfURL: String = "https://fssservices.bookxpert.co/GeneratedPDF/Companies/nadc/2024-2025/BalanceSheet.pdf"
    @IBOutlet weak var vwPdf: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadPdfUrl()
        
    }
    
    private func loadPdfUrl(){
        let pdfView = PDFView(frame: vwPdf.bounds)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.autoScales = true
        vwPdf.addSubview(pdfView)

        if let url = URL(string: pdfURL) {
            let document = PDFDocument(url: url)
            pdfView.document = document
        }
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}
