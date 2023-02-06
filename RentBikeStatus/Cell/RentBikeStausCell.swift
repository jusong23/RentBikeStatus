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

        stationName.text = cellList?.stationName
        stationName.font = .systemFont(ofSize: 20, weight: .bold)

        parkingBikeTotCnt.text = cellList?.parkingBikeTotCnt
        parkingBikeTotCnt.font = .systemFont(ofSize: 16)
        rackTotCnt.text = cellList?.rackTotCnt
        rackTotCnt.font = .systemFont(ofSize: 16)

        nowTemp.text = String(weatherInfo?.current.temp ?? 0)
        nowTemp.font = .systemFont(ofSize: 14)
        nowTemp.textColor = .blue
        
//            titleLabel.snp.makeConstraints {
//                $0.top.leading.trailing.equalToSuperview().inset(18)
//                // superView의 안쪽 set을 18로 !
//            }
//
//            descriptionLabel.snp.makeConstraints {
//                $0.top.equalTo(titleLabel.snp.bottom).offset(10)
//                $0.leading.equalTo(titleLabel.snp.leading)
//                $0.trailing.equalTo(titleLabel.snp.trailing)
//            }


    }

}
