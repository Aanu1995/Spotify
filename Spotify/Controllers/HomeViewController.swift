//
//  ViewController.swift
//  Spotify
//
//  Created by user on 22/03/2021.
//

import UIKit

enum BrowseSectionType {
    case newReleases
    case featurePlaylists
    case recommendedTracks
}

class HomeViewController: UIViewController {
    
    // MARK: Properties
    
    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { (section, _ ) -> NSCollectionLayoutSection? in
        return HomeViewController.createSectionLayout(section: section)
      }
    )
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .done, target: self, action: #selector(didTapSettings))
    }
    
    private func configureCollectionView(){
        view.addSubview(collectionView)
        view.addSubview(spinner)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        
    }
    
    
    @objc func didTapSettings(){
        let vc = SettingsViewController()
        vc.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

// MARK: Composition Layout methods

extension HomeViewController {
    
    private static func sectionLayout() -> NSCollectionLayoutSection {
        // Item
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 2.0, leading: 2.0, bottom: 2.0, trailing: 2.0)
        
        // Vertical Group in Horizontal Group
        let height: CGFloat = 390.0
        let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height)), subitem: item, count: 3)
            
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(height)), subitem: verticalGroup, count: 1)
        
        // Section
        let layoutSection = NSCollectionLayoutSection(group: horizontalGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPaging
        
        return layoutSection
    }
    
    private static func sectionLayout1() -> NSCollectionLayoutSection {
        // Item
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 2.0, leading: 2.0, bottom: 2.0, trailing: 2.0)
        
        // Vertical Group in Horizontal Group
        let height: CGFloat = 372.0
        let width: CGFloat = 186.0
        
        let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(width), heightDimension: .absolute(height)), subitem: item, count: 2)
        
        let horizontalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(width), heightDimension: .absolute(height)), subitem: verticalGroup, count: 1)
        
        
        // Section
        let layoutSection = NSCollectionLayoutSection(group: horizontalGroup)
        layoutSection.orthogonalScrollingBehavior = .continuous
        
        return layoutSection
    }
    
    private static func sectionLayout2() -> NSCollectionLayoutSection {
        // Item
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 2.0, leading: 2.0, bottom: 2.0, trailing: 2.0)
        
        // Vertical Group in Horizontal Group
        let height: CGFloat = 80.0
      
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height)), subitem: item, count: 1)
        
        // Section
        let layoutSection = NSCollectionLayoutSection(group: group)
        
        return layoutSection
    }
    
    

    private static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        switch section {
        case 0:
            return sectionLayout()
        case 1:
            return sectionLayout1()
        case 2:
            return sectionLayout2()
        default:
            return sectionLayout2()
        }
    }

}

// MARK: UICollection methods override

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .systemGreen
        return cell
    }
    
    
}

