//
//  ShortsViewController.swift
//  HelloMeghalaya
//
//  Created by SaranyuMac1 on 25/09/26.
//

import UIKit

final class ShortsViewController: UIViewController {
    
    private let viewModel = ShortsViewModel()
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let selectedContentID: String
    
    private var previousTableViewHeight: CGFloat = 0
    init(selectedContentID: String?) {
        self.selectedContentID = selectedContentID ?? ""
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("ShortsViewController loaded")
        
        setupTableView()
        loadShorts()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(ShortsTableViewCell.self, forCellReuseIdentifier: ShortsTableViewCell.reuseIdentifier)
        tableView.estimatedRowHeight = 0
        
        tableView.isPagingEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.bounces = false //At the first Short, scrolling down won't pull the content beyond the beginning.
       // At the last Short, scrolling up won't pull the content beyond the end.
        tableView.contentInsetAdjustmentBehavior = .never
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        ])
    }
    
    private func loadShorts() {
        
        print("Starting to load Shorts")
        
        Task {
            await viewModel.fetchShorts()
            
            print("Shorts count:", viewModel.shorts.count)
            
            tableView.reloadData()
            tableView.layoutIfNeeded()
            
            guard let selectedIndex = viewModel.shorts.firstIndex(where: { $0.contentID == selectedContentID}
            ) else {
                print("Selected Short not found:", selectedContentID)
                return
            }
            
            let indexPath = IndexPath(row: selectedIndex, section: 0)
            
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            
            tableView.layoutIfNeeded()
            playVisibleShort()
            
            print("Shorts loaded:", viewModel.shorts.count)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let currentHeight = tableView.bounds.height
        
        guard currentHeight > 0,
              currentHeight != previousTableViewHeight else {
            return
        }
        
        previousTableViewHeight = currentHeight
        
        tableView.rowHeight = currentHeight
        tableView.reloadData()
    }
    private func playVisibleShort() {
        // 1. Pause all visible videos
        for cell in tableView.visibleCells {
            (cell as? ShortsTableViewCell)?.pauseVideo()
        }

        // 2. Find the row closest to the center
        let centerY = tableView.contentOffset.y
            + tableView.bounds.height / 2

        guard let indexPath = tableView.indexPathsForVisibleRows?
            .min(by: {
                abs(tableView.rectForRow(at: $0).midY - centerY)
                    <
                abs(tableView.rectForRow(at: $1).midY - centerY)
            }),
            let currentCell = tableView.cellForRow(at: indexPath)
                as? ShortsTableViewCell
        else {
            return
        }

        // 3. Play only that video
        currentCell.playVideo()
    }
}

extension ShortsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.shorts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShortsTableViewCell.reuseIdentifier, for: indexPath) as? ShortsTableViewCell else {
            return UITableViewCell()
        }
        
        let short = viewModel.shorts[indexPath.row]
        cell.configure(with: short)
        
        return cell
    }
    
}

extension ShortsViewController: UITableViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        for cell in tableView.visibleCells {
            guard let shortsCell = cell as? ShortsTableViewCell else {
                continue
            }

            shortsCell.pauseVideo()
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        playVisibleShort()
    }

    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        if !decelerate {
            playVisibleShort()
        }
    }
}
