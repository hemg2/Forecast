//
//  ViewController.swift
//  Forecast
//
//  Created by 1 on 2022/08/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var topInset = CGFloat(0.0)
    // 뷰에 배치가 완료 될때 나타나는 메소드
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if topInset == 0.0 {
            let firstIndexPath = IndexPath(row: 0, section: 0)
            if let cell = listTableView.cellForRow(at: firstIndexPath) {
                topInset = listTableView.frame.height - cell.frame.height
                
                var inset = listTableView.contentInset
                inset.top = topInset
                listTableView.contentInset = inset
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //시작할때 테이블뷰를 숨기고  로더를 표시한다
        listTableView.alpha = 0.0
        loader.alpha = 1.0
        
        
        // 스토리 보드에서도 해도 되지만 그렇게하면 이미지,레이블 전부 흰색으로 바꿔야해서 스토리보드가 이상하다 그래서 코드로한다.
        listTableView.backgroundColor = .clear
        listTableView.separatorStyle = .none  // 세퍼레이퍼 표시 안하고 싶으면 none
        listTableView.showsVerticalScrollIndicator = false // 스크롤바를 표시하고 싶지 않다면 
        // 고정된 좌표값이였다.
//        let location = CLLocation(latitude: 37.498206, longitude: 127.02761)
//        WeatherDataSource.shared.fetch(location: location) {
//            self.listTableView.reloadData()
//        }
        
        LocationManager.shared.updateLocation()
        
        
        //새로운 옵저버 추가한다
        NotificationCenter.default.addObserver(forName: WeatherDataSource.weatherInfoDidUpdate, object: nil, queue: .main) { (noti) in
            self.listTableView.reloadData()
            self.locationLabel.text = LocationManager.shared.currentLocationTitle// 레이블에 노티값입력
            
            //날씨 정보가 업데이트되면 테이블뷰를 표시하고 로더를없애&&숨겨야한다.
            UIView.animate(withDuration: 0.3) {
                self.listTableView
                    .alpha = 1.0
                self.loader.alpha = 0.0
            }
            
        }
    }


}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return WeatherDataSource.shared.forecastList.count //예보의 수만큼 셀이표시된다.
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //첫번ㅉ ㅐ썸머릿셋 리던
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryTableViewCell", for: indexPath) as! SummaryTableViewCell
            
            if let weather = WeatherDataSource.shared.summary?.weather.first, let main = WeatherDataSource.shared.summary?.main {
                cell.weatherImageView.image = UIImage(named: weather.icon)
                cell.statusLabel.text = weather.description
                cell.minMaxLabel.text = "최고\(main.temp_max.temperatureString) 최소 \(main.temp_min.temperatureString)"
                cell.currentTemperatureLabel.text = "\(main.temp.temperatureString)"
            }
            
            return cell
        }
        
        // 여기서 포어리스테셀 리턴
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastTableViewCell", for: indexPath) as! ForecastTableViewCell
        //스위치 케이스1번 예보의 수만큼 나타나니 그걸 채운다/
        let target = WeatherDataSource.shared.forecastList[indexPath.row]
        cell.dateLabel.text = target.date.dateString
        cell.timeLabel.text = target.date.timeString
        cell.weatherImageView.image = UIImage(named: target.icon)
        cell.statusLabel.text = target.weather
        cell.temperatureLabel.text = target.temperature.temperatureString
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // 1번색션 현재 날씨  2번색션 날씨 예보
    }
}

