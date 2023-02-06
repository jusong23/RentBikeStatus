//
//  RentBikeStausCell.swift
//  RentBikeStatus
//
//  Created by mobile on 2023/02/06.
//

import UIKit
import SnapKit

class RentBikeStatusCell: UITableViewCell {
    var cellList: Row?
    var weatherInfo: OpenWeather?

    var stationName = UILabel() // 대여소 이름
    var parkingBikeTotCnt = UILabel() // 이용가능한 자전거 대수
    var rackTotCnt = UILabel() // 거치대 개수
    var stationLatitude = UILabel() // 위도
    var stationLongitude = UILabel() // 경도

    var nowTemp = UILabel() // 현재기온

    override func layoutSubviews() {
        super.layoutSubviews()
        [
            stationName, parkingBikeTotCnt, rackTotCnt
        ].forEach {
            contentView.addSubview($0)
        }

        guard let cellList = cellList else { return }
        //MARK: - Row
        stationName.text = cellList.stationName
        stationName.font = .systemFont(ofSize: 20, weight: .bold)
        stationName.textColor = .black
        
        parkingBikeTotCnt.text = "이용가능한 자전거 수: " + cellList.parkingBikeTotCnt + "대"
        parkingBikeTotCnt.font = .systemFont(ofSize: 16)
        stationName.textColor = .black
        
        rackTotCnt.text = "거치대 개수: " + cellList.rackTotCnt + "대"
        rackTotCnt.font = .systemFont(ofSize: 16)
        rackTotCnt.textColor = .black

        //MARK: - OpenWeather
        nowTemp.text = String(weatherInfo?.current.temp ?? 0)
        nowTemp.font = .systemFont(ofSize: 14)
        nowTemp.textColor = .blue
        
        stationName.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(18)
        }

        parkingBikeTotCnt.snp.makeConstraints {
            $0.top.equalTo(stationName.snp.bottom).offset(10)
            $0.leading.equalTo(stationName.snp.leading)
        }
        
        rackTotCnt.snp.makeConstraints {
            $0.top.equalTo(parkingBikeTotCnt.snp.bottom).offset(10)
            $0.leading.equalTo(parkingBikeTotCnt.snp.leading)
        }

    }

}
