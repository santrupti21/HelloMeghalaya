//
//  webViewController.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 08/09/26.
//

import UIKit
import WebKit

final class webViewController: UIViewController {
    private let webView = WKWebView()
    
    private let pageTitle: String //privacy policy, terms of use
    private let pageURL: URL
    
    init(pageTitle: String, pageURL: URL) {
        self.pageTitle = pageTitle
        self.pageURL = pageURL
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupNavigationBar()
        setupWebView()
        loadWebPage()
    }
    
    private func setupNavigationBar() {
        title = pageTitle
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
    }
    
    private func setupWebView() {
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webView.backgroundColor = .black
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadWebPage() {
        let request = URLRequest(url: pageURL)
        webView.load(request)
    }
    
    @objc private func backButtonTapped() {

        if let navigationController = navigationController {

            if navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: true)
            } else {
                navigationController.dismiss(animated: true)
            }

        } else {
            dismiss(animated: true)
        }
    }
    
    
}
