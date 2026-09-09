//
//  ContentLanguageViewController.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 08/09/26.
//

import UIKit

final class ContentLanguageViewController: UIViewController {

    private let headerView = UIView()
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    private let saveButton = UIButton()
    private let tableView = UITableView()

    private let languages = [
        "Select all",
        "English",
        "Hindi",
        "Khasi",
        "Garo",
        "Phar-Jaintia"
    ]

    private var selectedLanguages: Set<String> = [] // stores the currently sellcted
    private var isAllSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        loadSavedLanguages()
        setupHeader()
        setupTableView()
    }

    private func setupHeader() {

        view.addSubview(headerView)

        headerView.backgroundColor = UIColor(white: 0.12, alpha: 1.0)
        headerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100)
        ])

        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)

        backButton.tintColor = .systemGreen

        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        backButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        titleLabel.text = "Content Language"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1

        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.backgroundColor = .systemGreen
        saveButton.layer.cornerRadius = 12

        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)

        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            saveButton.widthAnchor.constraint(equalToConstant: 90),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        let headerStack = UIStackView(arrangedSubviews: [
                backButton,
                titleLabel,
                saveButton
            ]
        )

        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 10
        headerStack.distribution = .fill

        headerView.addSubview(headerStack)

        headerStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            headerStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            headerStack.topAnchor.constraint(equalTo: headerView.topAnchor),
            headerStack.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])

        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private func setupTableView() {

        tableView.backgroundColor = .black
        tableView.separatorColor = .darkGray
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60

        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadSavedLanguages() {

        if let savedLanguages = UserDefaults.standard.array(
            forKey: "selectedLanguages"
        ) as? [String] {

            selectedLanguages = Set(savedLanguages) //array to set
            isAllSelected = selectedLanguages.count == languages.count - 1 //select all not lang
        }
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func saveButtonTapped() {

        guard !selectedLanguages.isEmpty else {
            print("No language selected")
            return
        }

        UserDefaults.standard.set(Array(selectedLanguages),forKey: "selectedLanguages")

        print("Saved languages:", selectedLanguages)
    }
}

extension ContentLanguageViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return languages.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = UITableViewCell(style: .default, reuseIdentifier: nil) //table cell

        let language = languages[indexPath.row]

        cell.textLabel?.text = language
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .black

        if indexPath.row == 0 {
            cell.accessoryType = isAllSelected ? .checkmark : .none
        } else {
            cell.accessoryType = selectedLanguages.contains(language)
                ? .checkmark
                : .none
        }

        return cell
    }
}

extension ContentLanguageViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        if indexPath.row == 0 {

            isAllSelected.toggle()
//if true
            if isAllSelected {
                selectedLanguages = Set(languages.dropFirst())//removes the select all
            } else {
                selectedLanguages.removeAll()
            }

        } else {

            let language = languages[indexPath.row]

            //deselcting a lang n selcting a lang
            if selectedLanguages.contains(language) {
                selectedLanguages.remove(language)
            } else {
                selectedLanguages.insert(language)
            }

            isAllSelected = selectedLanguages.count == languages.count - 1
        }

        tableView.reloadData()

        tableView.deselectRow(
            at: indexPath,
            animated: true
        )
    }
}
