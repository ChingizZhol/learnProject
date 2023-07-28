//
//  ViewController.swift
//  CompositionLayout
//
//  Created by User on 27.07.2023.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var disciplineCollectionView: UICollectionView!
    @IBOutlet weak var semesterCollectionView: UICollectionView!
    
    @IBOutlet weak var learnYearLabel: UILabel!
    
    var learnPlanOfYear: LearnPlanOfYear? = nil
    var disciplines: [Discipline]? = nil
    var disciplineCount = 0
    
    var semesterIndex = 0
    
    let columnName = ["Лекция", "Семинар", "Лаборат."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        disciplineCollectionView.delegate = self
        disciplineCollectionView.dataSource = self
        
        semesterCollectionView.delegate = self
        semesterCollectionView.dataSource = self
        
        //collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        
        navigationItem.title = "Индивидуальный учебный план"
        
        disciplineCollectionView.collectionViewLayout = layout()
        
        disciplineCollectionView.register(StickColumnView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader/*"SectionHeaderElementKind"*/, withReuseIdentifier: StickColumnView.reuseIdentifier)
        
        loadJson(filename: "learnPlan2000")
        
    }
    
    func loadJson(filename fileName: String) {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode([LearnPlanOfYear].self, from: data)
                learnPlanOfYear = jsonData[0]
                
                if let temp = learnPlanOfYear {
                    learnYearLabel.text = "на \(temp.academicYear)"
                    disciplines = temp.semesters[semesterIndex].disciplines
                    for discipline in disciplines! {
                        disciplineCount += discipline.lesson.count
                        //print("disciplineCount: \(disciplineCount)")
                        
                    }
                    disciplineCollectionView.reloadData()
                    semesterCollectionView.reloadData()
                }
                
            } catch {
                print("error:\(error)")
            }
        }
        //return nil
    }
    
    @IBAction func downloadDocument(_ sender: Any) {
        
    }
    
    func layout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(100), heightDimension: .absolute(80))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(100), heightDimension: .absolute(CGFloat((80 * ((self.disciplines?.count ?? 0) + 1))))) // widthDimension: .absolute(100)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: (self.disciplines?.count ?? 0) + 1)
                //let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .absolute(self.view.bounds.width * 0.35),
                heightDimension: .absolute(CGFloat((80 * ((self.disciplines?.count ?? 0) + 1))))
            )
                
            let stickyColumn = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .leading,
                absoluteOffset: CGPoint(x: -self.view.bounds.width * 0.35, y: 0)
            )
            
            stickyColumn.pinToVisibleBounds = true
            stickyColumn.zIndex = 2
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = [stickyColumn]
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: self.view.bounds.width * 0.35, bottom: 0, trailing: 0)
            
            return section
            
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        //config.scrollDirection = .horizontal
        //config.contentInsetsReference
        //config.interSectionSpacing = 50
        //layout.collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        //collectionViewHighlights.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        layout.configuration = config
        
        return layout
    }
    
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == semesterCollectionView {
            return CGSize(width: view.bounds.width * 0.4, height: 50)
        } else {
            return CGSize(width: 100, height: 80)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: StickColumnView.reuseIdentifier, for: indexPath) as! StickColumnView
        
        headerView.configure(stickyColumnDatas: disciplines!, stickyColumnWidth: view.bounds.width * 0.35, stickyCellHeight: 80, stickyCellBackgroundColor: UIColor(named: "TableColor")!, stickyCellBorderWidth: 1, stickyCellBorderColor: .lightGray)
        
        return headerView
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == semesterCollectionView {
            return learnPlanOfYear?.semesters.count ?? 0
        } else {
            var count = 0
            for discipline in disciplines! {
                count += discipline.lesson.count + 1
                //print("disciplineCount: \(disciplineCount)")
            }
            return count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == semesterCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SemesterCell
            
            cell.semesterNumberLabel.text = "Семестр (\(learnPlanOfYear?.semesters[indexPath.item].number ?? ""))"
            if semesterIndex == indexPath.item {
                cell.semesterNumberLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
                cell.chooseView.backgroundColor = .orange
            } else {
                cell.semesterNumberLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
                cell.chooseView.backgroundColor = .clear
            }
            
            return cell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1
            let index = indexPath.item % (disciplines!.count + 1)
            let columnIndex: Int = indexPath.item / (disciplines!.count + 1)
            if index == 0 {
                cell.label.text = columnName[columnIndex]
                cell.backgroundColor = UIColor(named: "TableColor")
            } else {
                cell.backgroundColor = .white
                if let lessonType = disciplines?[index - 1].lesson[columnIndex]{
                    cell.label.text = "\(lessonType.realHours) / \(lessonType.hours)"
                } else {
                    cell.label.text = "\(index) / column: \(columnIndex)"
                }
            }
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == semesterCollectionView {
            semesterIndex = indexPath.item
            disciplines = learnPlanOfYear?.semesters[semesterIndex].disciplines
            disciplineCount = 0
            for discipline in disciplines! {
                disciplineCount += discipline.lesson.count
                
            }
            semesterCollectionView.reloadData()
            disciplineCollectionView.reloadData()
        } else {
            
        }
    }
    
    
}


class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
}

class SemesterCell: UICollectionViewCell {
    @IBOutlet weak var semesterNumberLabel: UILabel!
    @IBOutlet weak var chooseView: UIView!
}

class StickyCellView: UIView {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    func configure(
        text: String,
        backgroundColor: UIColor,
        borderWith: CGFloat,
        borderColor: UIColor
    ) {
        self.backgroundColor = backgroundColor
        layer.borderWidth = borderWith
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 14)
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        label.text = text
        label.textAlignment = .center
    }
}

class StickColumnView: UICollectionReusableView {

    static let reuseIdentifier = "sticky-column-reuse-identifier"
    static let reuseElementKind = "sticky-column-element-kind"

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    func configure(
        stickyColumnDatas: [Discipline],
        stickyColumnWidth: CGFloat,
        stickyCellHeight: CGFloat,
        stickyCellBackgroundColor: UIColor,
        stickyCellBorderWidth: CGFloat,
        stickyCellBorderColor: UIColor
    ) {
        for index in 0...stickyColumnDatas.count {
            let frame = CGRect(
                x: 0,
                y: CGFloat(index) * stickyCellHeight,
                width: stickyColumnWidth,
                height: stickyCellHeight
            )
            let stickyCell = StickyCellView(frame: frame)
            stickyCell.configure(
                text: index == 0 ? "Наименование дисциплины" : stickyColumnDatas[index-1].disciplineName.nameRu,
                backgroundColor: stickyCellBackgroundColor,
                borderWith: stickyCellBorderWidth,
                borderColor: stickyCellBorderColor
            )
            addSubview(stickyCell)
        }
    }
}
