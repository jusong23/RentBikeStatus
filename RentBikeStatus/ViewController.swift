//
//  ViewController.swift
//  RentBikeStatus
//
//  Created by mobile on 2023/02/06.
//

import UIKit
import RxSwift
import RxCocoa

public class SimpleError: Error {
    public init() { }
}

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(plusBikeInfo))
        self.navigationItem.rightBarButtonItem = button
        title = "공공자전거 실시간 대여정보"

        cellConfiguration()
    }

    @objc func plusBikeInfo() {
        let getStation = UIAlertController(title: "가져오기", message: "대여소 범위를 입력해주세요.", preferredStyle: .alert)

        let Action = UIAlertAction(title: "확인", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("확인")
        })
        getStation.addAction(Action)
        self.present(getStation, animated: true, completion: nil)
    }


    func cellConfiguration() {
        tableView.register(RentBikeStatusCell.self, forCellReuseIdentifier: "RentBikeStatusCell")
        tableView.rowHeight = 160
    }

    @objc func refresh() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            print("it work")
//            self.fetchBookList(of: "books")
        }
    }

}

