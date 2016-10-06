//
//  ViewController.swift
//  TestScroll2
//
//  Created by Jose Miguel Benedicto Ruiz on 5/10/16.
//  Copyright © 2016 FinanceFox. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let separatorSpace = CGFloat(1.0)
    let layoutConstraintVerticalSpaceTop = CGFloat(5.0)
    let layoutConstraintVerticalSpaceBottom = CGFloat(5.0)
    let maximumStrings = 200
    let maximumStringLength = 300
    let initialNumberOfMessages = 10
    var numberOfMessages = 0
    var messages: [String] = []
    var visibleMessages: [String] = []
    var visibleMessageSizes: [CGFloat] = []
    var oldContentSize = CGSize(width: 0, height: 0)
    var fetching = false
    
    // MARK: - Helpers
    
    func randomStringWithLength(len : Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ        "
        var randomString = ""
        
        for _ in 0..<len {
            let length = UInt32(letters.characters.count)
            let rand = Int(arc4random_uniform(length))
            let letter = String(letters[letters.index(letters.startIndex, offsetBy: rand)])
            randomString.append(letter)
        }
        
        return randomString
    }
    
    func randomNumberOfStrings() -> [String] {
        var strings: [String] = []
        let numberOfStrings = 50 + Int(arc4random_uniform(UInt32(maximumStrings)))
        for str in 0..<numberOfStrings {
            let lengthOfString = Int(arc4random_uniform(UInt32(maximumStringLength)))
            let string = randomStringWithLength(len: lengthOfString)
            strings.append("String \(str):\n\(string)")
        }
        return strings
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        messages = randomNumberOfStrings()
        start()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("New: \(self.tableView.contentSize)")
        UIView.animate(withDuration: 0) { 
            if self.fetching {
                self.tableView.contentOffset.y = nearbyint(self.tableView.contentOffset.y + self.tableView.contentSize.height - self.oldContentSize.height)
                print("Offset changed: \(self.tableView.contentSize.height) (new) - \(self.oldContentSize.height) (old) = \(self.tableView.contentOffset.y)")
                self.fetching = false
            }
        }
    }
    
    // MARK: - Basic Functions
    
    func start() {
        numberOfMessages = 0
        visibleMessages = []
        visibleMessageSizes = []
        oldContentSize = CGSize(width: 0, height: 0)
        fetching = false
        fetchMoreItems()
        DispatchQueue.main.async {
            self.tableView.contentOffset.y = self.tableView.contentSize.height - self.tableView.frame.size.height
        }
    }
    
    func fetchMoreItems() {
        numberOfMessages += initialNumberOfMessages
        visibleMessages = Array(messages.suffix(numberOfMessages))
        
        oldContentSize = self.tableView.contentSize
        print("Old: \(oldContentSize)")
        self.tableView.reloadData()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    // MARK: - Reload
    
    @IBAction func buttonReloadPressed(_ sender: AnyObject) {
        start()
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = visibleMessages[indexPath.row]
        let constraintRect = CGSize(width: tableView.frame.width, height: .greatestFiniteMagnitude)
        let boundingBox = message.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17.0)], context: nil)
        return nearbyint(boundingBox.height + layoutConstraintVerticalSpaceTop + layoutConstraintVerticalSpaceBottom + separatorSpace)
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: Cell.self)) as? Cell else {
            return UITableViewCell()
        }
        
        cell.label.text = visibleMessages[indexPath.row]
        return cell
    }
}

// MARK: - UIScrollViewDelegate

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 1 && scrollView.isDragging && visibleMessages.count < messages.count && !fetching {
            fetching = true
            fetchMoreItems()
        }
    }
}

