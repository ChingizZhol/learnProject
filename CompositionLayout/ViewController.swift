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
    @IBOutlet weak var shareOutlet: UIBarButtonItem!
    
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
        shareOutlet.tintColor = .white
        
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
        print("download document")
        
        let someText:String = "Hello want to share text also"
            let objectsToShare:URL = URL(string: "http://www.google.com")!
            let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
            let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view

        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail]

            self.present(activityViewController, animated: true, completion: nil)
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
                    let myInt1 = Int(lessonType.realHours)
                    let myInt2 = Int(lessonType.hours)
                    //cell.label.text = "\(lessonType.realHours) / \(lessonType.hours)"
                    if (myInt1 ?? 0 >= myInt2 ?? 0) {
                        let text = NSMutableAttributedString()
                        text.append(NSAttributedString(string: "\(myInt1 ?? 0)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.green]));
                        text.append(NSAttributedString(string: " / ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]));
                        text.append(NSAttributedString(string: "\(myInt2 ?? 0)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.green]));
                        cell.label.attributedText = text
                    } else {
                        let text = NSMutableAttributedString()
                        text.append(NSAttributedString(string: "\(myInt1 ?? 0)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.green]));
                        text.append(NSAttributedString(string: " / ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]));
                        text.append(NSAttributedString(string: "\(myInt2 ?? 0)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]));
                        cell.label.attributedText = text
                    }
                    
                    //cell.label.text = "\(myInt1 ?? 0) / \(myInt2 ?? 0)"
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










/*Tasks
 
 
 */
