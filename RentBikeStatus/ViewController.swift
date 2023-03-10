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
    private let rentBikeStatus = PublishSubject<RentBikeStatus>()
    private let row = BehaviorSubject<[Row]>(value: [])

    private let openWeather = PublishSubject<OpenWeather>()

    private let disposeBag = DisposeBag()

    var getOpenWeather = GetOpenWeather()

    override func viewDidLoad() {
        super.viewDidLoad()
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(plusBikeInfo))
        self.navigationItem.rightBarButtonItem = rightButton
        
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "sun.max.fill"), style: .plain, target: self, action: #selector(test))
        self.navigationItem.leftBarButtonItem = leftButton
        
        title = "공공자전거 실시간 대여정보"

        refreshControlConfiguration()
        cellConfiguration()
    }
    
    @objc func test() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            self.getOpenWeather.getWeatherInfo(lat: 37.6215, lon: 127.0598, completion: { [weak self] result in
                guard let self = self else { return }

                switch result {
                case let .success(result):
                    print("\(result.current.temp)°C")

                case let .failure(NetworkError):
                    print(NetworkError)
                }
            })
        }
    }

    func refreshControlConfiguration() {
        self.refreshControl = UIRefreshControl()
        let refreshControl = self.refreshControl!
        refreshControl.backgroundColor = .white
        refreshControl.tintColor = .black

        refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }

    @objc func refresh() {
        self.fetchRentBikeStatus(of: "10/13")

//        getData()
//
//        DispatchQueue.global(qos: .background).async {
//            print("새로고침")
////            self.fetchRentBikeStatus(of: "10/400")
//            // 저장된 변수값으로 고정해서 사용
//        }
    }

    func getData() {
        self.fetchRentBikeStatus(of: "10/13")
    }

    func returnURL(form fetchedRentBikeStatus: String) -> URL {
        // 타입을 변경할 때도 map이 유용하다. (Array -> URL)
        return URL(string: "http://openapi.seoul.go.kr:8088/4c55476d556a75733638574e646456/JSON/bikeList/\(fetchedRentBikeStatus)")!
    }
    
//    func returnRequest(how method:String) -> URLRequest {
//
//    }
    
    func fetchRentBikeStatus(of fetchedRentBikeStatus: String) {
        Observable.from([fetchedRentBikeStatus])
        // 배열의 인덱스를 하나하나 방출
        .map { fetchedRentBikeStatus -> URL in self.returnURL(form: fetchedRentBikeStatus) }
        //MARK: - Request
        .map { url -> URLRequest in
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            return request
        }
        // URL -> URLRequest
        .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
            return URLSession.shared.rx.response(request: request)
        }
        // Tuple의 형태의 Observable 시퀀스로 변환 Observable<(response,data)>.  ... Observable<Int> 처럼
        //MARK: - Response
        .filter { response, _ in
            // Tuple 내에서 response만 받기 위해 _ 표시
            return 200..<300 ~= response.statusCode
            // responds.statusCode가 해당범위에 해당하면 true
        }
        .map { _, data -> RentBikeStatus in
            let decoder = JSONDecoder()
            if let json = try? decoder.decode(RentBikeStatus.self, from: data) {
                return json
            }
            throw SimpleError()
        } // MARK: - 배열만 뽑아내는 Tric
        .map { objects -> [Row] in // compactMap: 1차원 배열에서 nil을 제거하고 옵셔널 바인딩 stationLatitude
            //throw SimpleError() //MARK: map안에서의 에러 표현
            
            return objects.rentBikeStatus.row.compactMap { dic -> Row? in

                print("each row's locaiton Info: \(dic.stationLatitude),\(dic.stationLongitude)")

                return Row(rackTotCnt: dic.rackTotCnt, stationName: dic.stationName, parkingBikeTotCnt: dic.parkingBikeTotCnt, shared: dic.shared, stationLatitude: dic.stationLatitude, stationLongitude: dic.stationLongitude, stationID: dic.stationID)
            }
        }
        .flatMap { arrRow -> Observable<([Row], OpenWeather)> in
            let lat = Double(arrRow.first!.stationLatitude)!
            let len = Double(arrRow.first!.stationLongitude)!
            print("here \(lat) \(len)")
            return self.getOpenWeather.getWeatherInfo2(lat: lat, lon: len)
                .map { openWeather -> ([Row], OpenWeather) in
                    return (arrRow, openWeather)
                }
        }
        .retry(3)
        .subscribe(on: ConcurrentDispatchQueueScheduler(queue: .global())) // Observable 자체 Thread 변경
        .observe(on: MainScheduler.instance) // 이후 subsribe의 Thread 변경
        .subscribe { event in // MARK: 에러처리에 용이한 subscribe 트릭
            switch event {
            case .next(let (newList,openWeather)):
                self.row.onNext(newList)
                self.openWeather.onNext(openWeather)
//                print("여기 \(newList)")
                print("여기 \(openWeather.current.temp)")
                self.refreshControl?.endRefreshing()
                // BehaviorSubject에 이벤트 발생
                self.tableView.reloadData()
            case .error(let error):
                print("error: \(error), thread: \(Thread.isMainThread)")
                self.refreshControl?.endRefreshing()
            case .completed:
                print("completed")
            }
        }
            .disposed(by: disposeBag)
    }

    @objc func plusBikeInfo() {
        let getStation = UIAlertController(title: "가져오기", message: "대여소 범위를 입력해주세요.", preferredStyle: .alert)

        getStation.addTextField { firstField in
            firstField.placeholder = "ex. 10"
        }
        getStation.addTextField { secondField in
            secondField.placeholder = "ex. 20"
        }
        let Action = UIAlertAction(title: "확인", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print(getStation.textFields?[0].text)
            print(getStation.textFields?[1].text)
        })
        getStation.addAction(Action)
        self.present(getStation, animated: true, completion: nil)
    }


    func cellConfiguration() {
        tableView.register(RentBikeStatusCell.self, forCellReuseIdentifier: "RentBikeStatusCell")
        tableView.rowHeight = 160
    }

}

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        do {
            return try row.value().count
        } catch {
            return 0
        } // BehaviorSubject의 특징 이용하여 값만 가져오기(.count와 동일)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RentBikeStatusCell", for: indexPath) as? RentBikeStatusCell else { return UITableViewCell() }

        var currentBikeList: Row? {
            do {
                return try row.value()[indexPath.row]
            } catch {
                return nil
            }
        }

        cell.cellList = currentBikeList

        return cell
    }
}
