//
//  ViewController.swift
//  CompositionalLayouts
//
//  Created by Will McGinty on 10/15/21.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate {

    // MARK: - Subtypes
    enum Section: Int, Hashable {
        case horizontalRow
        case grid
        case list
        case carousel

        var shouldRoundCorners: Bool {
            switch self {
            case .horizontalRow, .carousel, .grid: return true
            default: return false
            }
        }

        var shouldStrokeCell: Bool {
            switch self {
            case .horizontalRow, .grid: return true
            default: return false
            }
        }

        var shouldColorBackground: Bool {
            switch self {
            case .carousel: return true
            default: return false
            }
        }

        var shouldCenterText: Bool {
            switch self {
            case .horizontalRow, .carousel, .grid: return true
            default: return false
            }
        }
    }

    struct Item: Hashable {
        let index: Int
    }

    // MARK: - Properties
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: makeLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        return collectionView
    }()

    private let defaultHeader: UICollectionView.SupplementaryRegistration<UICollectionViewListCell> = .init(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
        var contentConfiguration = supplementaryView.defaultContentConfiguration()
        contentConfiguration.text = String(describing: indexPath)
        contentConfiguration.textProperties.color = .white
        supplementaryView.contentConfiguration = contentConfiguration
    }

    private let defaultCell: UICollectionView.CellRegistration<UICollectionViewListCell, Item> = .init { cell, indexPath, item in
        let section = Section(rawValue: indexPath.section)

        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = String(describing: item.index)
        contentConfiguration.textProperties.alignment = section?.shouldCenterText == true ? .center : .natural
        cell.contentConfiguration = contentConfiguration
        
        var backgroundConfiguration = UIBackgroundConfiguration.listPlainCell()
        backgroundConfiguration.strokeColor = section?.shouldStrokeCell == true ? UIColor.random : backgroundConfiguration.strokeColor
        backgroundConfiguration.backgroundColor = section?.shouldColorBackground == true ? UIColor.random : backgroundConfiguration.backgroundColor
        backgroundConfiguration.strokeWidth = 2
        backgroundConfiguration.cornerRadius = section?.shouldRoundCorners == true ? 12 : 0
        cell.backgroundConfiguration = backgroundConfiguration
    }

    private lazy var diffableDataSource: UICollectionViewDiffableDataSource<Section, Item> = {
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: cell)
        dataSource.supplementaryViewProvider = supplementaryView
        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        collectionView.register(BadgeView.self, forSupplementaryViewOfKind: BadgeView.elementKind, withReuseIdentifier: BadgeView.elementKind)
        view.addSubview(collectionView)

        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.horizontalRow, .grid, .list, .carousel])
        snapshot.appendItems((0..<15).map { Item(index: $0) }, toSection: .horizontalRow)
        snapshot.appendItems((15..<30).map { Item(index: $0) }, toSection: .list)
        snapshot.appendItems((30..<45).map { Item(index: $0) }, toSection: .carousel)
        snapshot.appendItems((45..<53).map { Item(index: $0) }, toSection: .grid)

        diffableDataSource.apply(snapshot, animatingDifferences: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        collectionView.scrollToItem(at: IndexPath(item: 4, section: 3), at: .centeredHorizontally, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }

}

// MARK: - Content Providers
extension ViewController {

    func cell(in collectionView: UICollectionView, for indexPath: IndexPath, item: Item) -> UICollectionViewCell? {
        return collectionView.dequeueConfiguredReusableCell(using: defaultCell, for: indexPath, item: item)
    }

    func supplementaryView(in collectionView: UICollectionView, for kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        switch kind {
        case BadgeView.elementKind:
            let badgeView =  collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: BadgeView.elementKind,
                                                                             for: indexPath) as! BadgeView
            badgeView.text = String(Int.random(in: 0..<10))
            return badgeView
        default: return collectionView.dequeueConfiguredReusableSupplementary(using: defaultHeader, for: indexPath)
        }
    }
}

// MARK: - Layout Providers
extension ViewController {

    func makeLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            guard let section = Section(rawValue: sectionIndex) else { return nil }

            switch section {
            case .horizontalRow: return self.makeHorizontalRow(in: layoutEnvironment)
            case .grid: return self.makeGridLayout(in: layoutEnvironment)
            case .list: return self.makeListLayout(for: layoutEnvironment)
            case .carousel: return self.makeCarouselLayout(in: layoutEnvironment)
            }
        }
    }

    // Horizontal Row of 3
    func makeHorizontalRow(in environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), // Will be ignored
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize,
                                          supplementaryItems: [badgeItem(with: .init(edges: [.top, .leading],
                                                                                     fractionalOffset: .init(x: -0.5, y: -0.5)))])

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
        group.interItemSpacing = .fixed(10)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        section.contentInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
        return section
    }

    // 1-2-1 Grid
    func makeGridLayout(in environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalWidth(0.30))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let middleItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                    heightDimension: .fractionalHeight(1))
        let middleItem = NSCollectionLayoutItem(layoutSize: middleItemSize)

        let middleGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), // Will be ignored
                                                     heightDimension: .fractionalWidth(0.5))
        let middleGroup = NSCollectionLayoutGroup.horizontal(layoutSize: middleGroupSize, subitem: middleItem, count: 2)
        middleGroup.interItemSpacing = NSCollectionLayoutSpacing.fixed(10)

        let finalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                    heightDimension: .estimated(400))
        let finalGroup = NSCollectionLayoutGroup.vertical(layoutSize: finalGroupSize, subitems: [item, middleGroup, item])
        finalGroup.interItemSpacing = .fixed(10)

        let layoutSection = NSCollectionLayoutSection(group: finalGroup)
        layoutSection.interGroupSpacing = 40
        layoutSection.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)

        return layoutSection
    }

    // List
    func makeListLayout(for layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .supplementary
        configuration.backgroundColor = .black

        configuration.leadingSwipeActionsConfigurationProvider = { indexPath in
            guard indexPath.item % 2 == 0 else { return nil }
            let action = UIContextualAction(style: .normal, title: "Favorite", handler: { _, _, completion in completion(true) })
            action.backgroundColor = .cyan
            action.image = UIImage(systemName: "star.fill")

            return .init(actions: [action])
        }

        configuration.trailingSwipeActionsConfigurationProvider = { indexPath in
            guard indexPath.item % 2 == 1 else { return nil }
            let action = UIContextualAction(style: .normal, title: "Delete", handler: { _, _, completion in completion(true) })
            action.backgroundColor = .red
            action.image = UIImage(systemName: "trash.fill")

            return .init(actions: [action])
        }

        configuration.itemSeparatorHandler = { indexPath, configuration in
            var newConfiguration = configuration
            newConfiguration.bottomSeparatorVisibility = indexPath.item % 2 == 0 ? .visible : .hidden
            newConfiguration.color = .black
            newConfiguration.bottomSeparatorInsets = .zero
            
            return newConfiguration
        }

        let layoutSection = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
        layoutSection.contentInsets = .init(top: 25, leading: 25, bottom: 25, trailing: 25)

        return layoutSection
    }

    // Carousel
    func makeCarouselLayout(in layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                               heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .init(top: 10, leading: 0, bottom: 10, trailing: 0)

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.visibleItemsInvalidationHandler = { visibleItems, offset, layoutEnvironment in
            for item in visibleItems {
                let offsetCenterX = offset.x + (layoutEnvironment.container.effectiveContentSize.width * 0.5)
                let distance = abs(item.center.x - offsetCenterX)
                let scale = distance / layoutEnvironment.container.effectiveContentSize.width * 0.5 * 0.5 /* scale factor */
                let transform = CGAffineTransform(scaleX: 1 - scale, y: 1 - scale)
                item.transform = transform
            }
        }
        
        return section
    }

    func badgeItem(with containerAnchor: NSCollectionLayoutAnchor) -> NSCollectionLayoutSupplementaryItem {
        return .init(layoutSize: .init(widthDimension: .absolute(20),
                                       heightDimension: .absolute(20)),
                     elementKind: BadgeView.elementKind,
                     containerAnchor:  containerAnchor)
    }
}
