//
//  SearchViewController.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 01/09/26.
//

import UIKit

@MainActor
final class SearchViewController: UIViewController {
    
    private let backButton = UIButton(type: .system)
    private let searchTextField = UITextField()
    private let clearButton = UIButton(type: .system)
    
    private let viewmodel = SearchViewModel()
    private var searchResults: [HomeItem] = []
    private let collectionView: UICollectionView
    
    private let noResultsImageview = UIImageView()
    private let noResultsTitlelabel = UILabel()
    private let noResultsMessagelabel = UILabel()
    private let noResultsClearButton = UIButton(type: .system)
  
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        
        viewmodel.delegate = self
        view.backgroundColor = .black
        collectionView.backgroundColor = .black
        
        backButton.setImage(UIImage(systemName: "arrow.left",
                                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)), for: .normal)
        
        backButton.tintColor = .white
        
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search for movies, songs & more...",
            attributes: [
                .foregroundColor: UIColor.lightGray
            ]
        )

        searchTextField.textColor = .white
        searchTextField.tintColor = .white

        searchTextField.backgroundColor = UIColor(
            red: 0.12,
            green: 0.11,
            blue: 0.09,
            alpha: 1
        )

        searchTextField.font = UIFont.systemFont(
            ofSize: 16
        )

        searchTextField.leftView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 15,
                height: 1
            )
        )

        searchTextField.leftViewMode = .always
        
        clearButton.setImage(
            UIImage(
                systemName: "xmark",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 20,
                    weight: .regular
                )
            ),
            for: .normal
        )
        clearButton.tintColor = .white
        
        noResultsImageview.image = UIImage(systemName: "shippingbox")
        noResultsImageview.contentMode = .scaleAspectFit
        
        noResultsTitlelabel.text = "Sorry!"
        noResultsTitlelabel.textColor = .white
        noResultsTitlelabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        noResultsTitlelabel.textAlignment = .center
        
        noResultsMessagelabel.text = "We couldn't find anything that matches your search"
        noResultsMessagelabel.textColor = .lightGray
        noResultsMessagelabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        noResultsMessagelabel.textAlignment = .center
        noResultsMessagelabel.numberOfLines = 0
        
        noResultsClearButton.setTitle("CLEAR SEARCH", for: .normal)
        noResultsClearButton.setTitleColor(.black, for: .normal)
        
        
        noResultsClearButton.backgroundColor = UIColor(red: 0.65, green: 0.85, blue: 0.05, alpha: 1)
        noResultsClearButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        noResultsClearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        
        noResultsImageview.isHidden = true
        noResultsTitlelabel.isHidden = true
        noResultsMessagelabel.isHidden = true
        noResultsClearButton.isHidden = true
        
        setupUI()

        collectionView.dataSource = self
        collectionView.delegate =  self
        
        collectionView.register(SearchCollectionViewcell.self, forCellWithReuseIdentifier: "SearchCollectionViewCell")
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        
    }
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func clearButtonTapped() {
        searchTextField.text = ""
        searchResults.removeAll()
        collectionView.reloadData()
        
        viewmodel.searchTextChanged("")
    }
    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(searchTextField)
        view.addSubview(clearButton)
        view.addSubview(collectionView)
        
        view.addSubview(noResultsImageview)
        view.addSubview(noResultsTitlelabel)
        view.addSubview(noResultsMessagelabel)
        view.addSubview(noResultsClearButton)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        noResultsImageview.translatesAutoresizingMaskIntoConstraints = false
        noResultsTitlelabel.translatesAutoresizingMaskIntoConstraints = false
        noResultsMessagelabel.translatesAutoresizingMaskIntoConstraints = false
        noResultsClearButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            backButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 20
            ),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            searchTextField.leadingAnchor.constraint(
                equalTo: backButton.trailingAnchor,
                constant: 10
            ),
            searchTextField.topAnchor.constraint(
                equalTo: backButton.topAnchor
            ),
            searchTextField.heightAnchor.constraint(equalToConstant: 44),

            clearButton.leadingAnchor.constraint(
                equalTo: searchTextField.trailingAnchor,
                constant: 5
            ),
            clearButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            clearButton.centerYAnchor.constraint(
                equalTo: searchTextField.centerYAnchor
            ),
            clearButton.widthAnchor.constraint(equalToConstant: 44),
            clearButton.heightAnchor.constraint(equalToConstant: 44),
            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),

            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),

            collectionView.topAnchor.constraint(
                equalTo: searchTextField.bottomAnchor,
                constant: 20
            ),

            collectionView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
            noResultsImageview.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            noResultsImageview.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: -100
            ),
            noResultsImageview.widthAnchor.constraint(
                equalToConstant: 180
            ),
            noResultsImageview.heightAnchor.constraint(
                equalToConstant: 180
            ),

            noResultsTitlelabel.topAnchor.constraint(
                equalTo: noResultsImageview.bottomAnchor,
                constant: 20
            ),
            noResultsTitlelabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            noResultsTitlelabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),

            noResultsMessagelabel.topAnchor.constraint(
                equalTo: noResultsTitlelabel.bottomAnchor,
                constant: 20
            ),
            noResultsMessagelabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 30
            ),
            noResultsMessagelabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -30
            ),

            noResultsClearButton.topAnchor.constraint(
                equalTo: noResultsMessagelabel.bottomAnchor,
                constant: 30
            ),
            noResultsClearButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            noResultsClearButton.widthAnchor.constraint(
                equalToConstant: 220
            ),
            noResultsClearButton.heightAnchor.constraint(
                equalToConstant: 55
            )
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchTextField.becomeFirstResponder()// UITextField becomes active Cursor appears
    }

}
extension SearchViewController: searchviewModelDelegate {
    func searchViewModel(
        _ viewModel: SearchViewModel,
        didUpdate state: SearchState
    ) {

        switch state {

        case .idle:
            searchResults.removeAll()
            collectionView.isHidden = true

            noResultsImageview.isHidden = true
            noResultsTitlelabel.isHidden = true
            noResultsMessagelabel.isHidden = true
            noResultsClearButton.isHidden = true

        case .results(let results):
            searchResults = results

            collectionView.isHidden = false

            noResultsImageview.isHidden = true
            noResultsTitlelabel.isHidden = true
            noResultsMessagelabel.isHidden = true
            noResultsClearButton.isHidden = true

            collectionView.reloadData()

        case .noResults:
            searchResults.removeAll()

            collectionView.isHidden = true

            noResultsImageview.isHidden = false
            noResultsTitlelabel.isHidden = false
            noResultsMessagelabel.isHidden = false
            noResultsClearButton.isHidden = false
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 100 { //100 threshold
            viewmodel.loadNetPage()
        }
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCollectionViewCell", for: indexPath) as? SearchCollectionViewcell else {
            return UICollectionViewCell()
        }
        let item = searchResults[indexPath.item]
        cell.configure(with: item, viewModel: viewmodel)
        return cell
    }
}
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let item = searchResults[indexPath.item]

        let spacing = (collectionViewLayout as? UICollectionViewFlowLayout)?
            .minimumInteritemSpacing ?? 0

        let aspectRatio: CGFloat

        if item.catalogObject?.layoutType?.contains("2_3") == true {
            aspectRatio = 2.0 / 3.0
        } else {
            aspectRatio = 16.0 / 9.0
        }

        let itemWidth: CGFloat

        if aspectRatio == 2.0 / 3.0 {
            itemWidth = (collectionView.bounds.width - (spacing * 2)) / 3
        } else {
            itemWidth = (collectionView.bounds.width - spacing) / 2
        }

        let itemHeight = itemWidth / aspectRatio

        return CGSize(
            width: itemWidth,
            height: itemHeight
        )
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        print("updated text:", updatedText)
        
        viewmodel.searchTextChanged(updatedText)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
