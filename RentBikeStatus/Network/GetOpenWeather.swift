//
//  GetOpenWeather.swift
//  RentBikeStatus
//
//  Created by mobile on 2023/02/06.
//

import Foundation
import RxSwift
import RxCocoa

class GetOpenWeather {
    
    func getWeatherInfo(lat:Double, lon:Double, completion: @escaping (Result<OpenWeather,NetworkError>) -> Void ) { // π© model struct name
        let weatherUrlStr = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&exclude=hourly&appid=70712209ed38b3c9995cdcdd87bda250&units=metric" // π© url

        // [1st] URL instance μμ±
        guard let url = URL(string: weatherUrlStr) else {
            fatalError("Invaild URL")

        }

        // [2nd] Task μμ±(.resume)
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            // error: μλ¬μ²λ¦¬
            if let error = error { return }
            // response: μλ² μλ΅ μ λ³΄
            guard let httpResponse = response as? HTTPURLResponse else { return }
            guard (200 ... 299).contains(httpResponse.statusCode) else { return }

            // data: μλ²κ° μ½μ μ μλ Binary λ°μ΄ν°
            guard let data = data else { fatalError("Invalid Data") }

            do {
                
//                let dic = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                print("here2 \(dic)")
                
                let decoder = JSONDecoder()

                let weatherInfo = try decoder.decode(OpenWeather.self, from: data) // π© model struct name

                completion(.success(weatherInfo))

            } catch {
                completion(.failure(.networkError))
//                        self.showErrorAlert(with: error.localizedDescription)
            }
        }
        task.resume() // suspend μνμ task κΉ¨μ°κΈ°
    }
    
    func getWeatherInfo2(lat:Double, lon:Double) -> Observable<OpenWeather> { // π© model struct name
        return Observable.create { (emitter) in
            let weatherUrlStr = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&exclude=hourly&appid=70712209ed38b3c9995cdcdd87bda250&units=metric" // π© url
            print(lat)
            print(lon)
            // [1st] URL instance μμ±
            guard let url = URL(string: weatherUrlStr) else {
                emitter.onError(SimpleError())
                return Disposables.create()
                
            }

            // [2nd] Task μμ±(.resume)
            let session = URLSession.shared
            let task = session.dataTask(with: url) { data, response, error in
                // error: μλ¬μ²λ¦¬
                if let error = error { return }
                // response: μλ² μλ΅ μ λ³΄
                guard let httpResponse = response as? HTTPURLResponse else { return }
                guard (200 ... 299).contains(httpResponse.statusCode) else { return }

                // data: μλ²κ° μ½μ μ μλ Binary λ°μ΄ν°
                guard let data = data else { fatalError("Invalid Data") }
                print(data)
                do {
//                    let dic = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                    print("here2 \(dic)")
                    
                    let decoder = JSONDecoder()
                    
                    let weatherInfo = try decoder.decode(OpenWeather.self, from: data) // π© model struct name
                    print(weatherInfo)
//                    completion(.success(weatherInfo))
                    emitter.onNext(weatherInfo)
                    emitter.onCompleted()
                } catch {
//                    completion(.failure(.networkError))
    //                        self.showErrorAlert(with: error.localizedDescription)
                    emitter.onError(SimpleError())
                }
            }
            task.resume() // suspend μνμ task κΉ¨μ°κΈ°
            
            return Disposables.create()
        }
        
        
    }
}
