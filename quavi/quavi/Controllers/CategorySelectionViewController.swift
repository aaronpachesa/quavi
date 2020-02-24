//
//  CategorySelectionViewController.swift
//  quavi
//
//  Created by Mr Wonderful on 2/24/20.
//  Copyright © 2020 Sunni Tang. All rights reserved.
//

import UIKit

class CategorySelectionViewController: UIViewController {
    
    //MARK: -- Properties
    var layout = UICollectionViewFlowLayout.init()
    
    //MARK: -- Objects
    lazy var categoryCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        collectionView.register(CatergoryCollectionViewCell.self, forCellWithReuseIdentifier: Identifier.categoryCell.rawValue)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    //MARK: -- LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    //MARK: -- private func
    private func addSubviews(){
        view.addSubview(categoryCollectionView)
    }
    
    private func setupNavBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.topItem?.title = "Tour Categories"
    }
}
//MARK: -- Extension
extension CategorySelectionViewController: UICollectionViewDelegate{}

extension CategorySelectionViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.categoryCell.rawValue, for: indexPath) as? CatergoryCollectionViewCell else {return UICollectionViewCell()}
        
        cell.layer.borderWidth = 1
        cell.layer.borderColor = #colorLiteral(red: 0.2843827307, green: 0.6391303539, blue: 0.8293711543, alpha: 1)
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        return cell
    }
}

extension CategorySelectionViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5)
        layout.minimumInteritemSpacing = 5
        let virticalCellCGSize = CGSize(width: (collectionView.frame.size.width - 20), height: collectionView.frame.size.height / 6)
        return virticalCellCGSize
    }
}

