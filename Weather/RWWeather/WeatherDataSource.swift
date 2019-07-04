/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation

public enum MeasurementSystem {
    case Metric
    case USCustomary
}

public enum WeatherDataInterval {
    case Instant
    case Day(day: Date)
    case Hour(time: Date)
}

public enum WeatherCondition: String {
    case Sunny
    case Cloudy
    case Rain
    case Snow
}

private func ctof(temp: Int) -> Int {
    return Int(Double(temp) * 9 / 5 + 32)
}
private func ftoc(temp: Int) -> Int {
    return Int((Double(temp) - 32) * 5.0 / 9.0)
}
private func identity(temp: Int) -> Int {
    return temp
}
private func mitokm(dist: Int) -> Int {
    return Int(Double(dist) * 1.60934)
}
private func kmtomi(dist: Int) -> Int {
    return Int(Double(dist) / 1.60934)
}
private var shortHourFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "ha"
    return f
}()
private var shortDayFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "ccc d"
    return f
}()

public struct WeatherData {
    let measurementSystem: MeasurementSystem
    let outputConversion: (Int) -> Int

    let interval: WeatherDataInterval

    private let _temperature: Int
    var temperature: Int {
        return outputConversion(_temperature)
    }

    private let _feelTemperature: Int
    var feelTemperature: Int {
        return outputConversion(_feelTemperature)
    }

    private let _highTemperature: Int
    var highTemperature: Int {
        return outputConversion(_highTemperature)
    }

    private let _lowTemperature: Int
    var lowTemperature: Int {
        return outputConversion(_lowTemperature)
    }

    private let _windSpeed: Int
    var windSpeed: Int {
        return measurementSystem == .Metric ? _windSpeed : kmtomi(dist: _windSpeed)
    }

    let windDirection: String

    let weatherCondition: WeatherCondition

    var intervalString: String {
        switch interval {
        case .Instant:
            return "Now"
        case .Hour(let time):
            return shortHourFormatter.string(from: time as Date)
        case .Day(let day):
            return shortDayFormatter.string(from: day as Date)
        }
    }
    var temperatureString: String {
        return "\(temperature)°"
    }
    var feelTemperatureString: String {
        return "Feels like \(feelTemperature)°"
    }
    var weatherConditionString: String {
        return weatherCondition.rawValue
    }
    var weatherConditionImageName: String {
        return weatherCondition.rawValue
    }
    var windString: String {
        return "\(windSpeed)\(measurementSystem == .Metric ? "km/h" : "MPH") \(windDirection)"
    }

    init(measurementSystem: MeasurementSystem, interval: WeatherDataInterval, temperature: Int, feelTemperature: Int, highTemperature: Int, lowTemperature: Int, windSpeed: Int, windDirection: String, weatherCondition: WeatherCondition) {
        self.outputConversion = measurementSystem == .Metric ? identity : ctof

        self.measurementSystem = measurementSystem
        self.interval = interval
        self._temperature = temperature
        self._feelTemperature = feelTemperature
        self._highTemperature = highTemperature
        self._lowTemperature = lowTemperature
        self._windSpeed = windSpeed

        self.windDirection = windDirection
        self.weatherCondition = weatherCondition
    }
}

public class WeatherDataSource {
    private(set) var measurementSystem: MeasurementSystem
    private(set) var currentWeather: WeatherData
    private(set) var shortTermWeather: [WeatherData] = []
    private(set) var longTermWeather: [WeatherData] = []

    public init(measurementSystem: MeasurementSystem) {
        self.measurementSystem = measurementSystem

        currentWeather = WeatherData(measurementSystem: measurementSystem, interval: .Instant, temperature: 16, feelTemperature: 15, highTemperature: 16, lowTemperature: 16, windSpeed: 8, windDirection: "NE", weatherCondition: .Cloudy)

        shortTermWeather = [
            WeatherData(measurementSystem: measurementSystem, interval: .Hour(time: Date().dateByAddingsHours(hours: 1)), temperature: 16, feelTemperature: 15, highTemperature: 16, lowTemperature: 16, windSpeed: 8, windDirection: "NE", weatherCondition: .Cloudy),
            WeatherData(measurementSystem: measurementSystem, interval: .Hour(time: Date().dateByAddingsHours(hours: 2)), temperature: 19, feelTemperature: 15, highTemperature: 16, lowTemperature: 16, windSpeed: 8, windDirection: "NE", weatherCondition: .Cloudy),
            WeatherData(measurementSystem: measurementSystem, interval: .Hour(time: Date().dateByAddingsHours(hours: 3)), temperature: 21, feelTemperature: 15, highTemperature: 16, lowTemperature: 16, windSpeed: 8, windDirection: "NE", weatherCondition: .Rain),
            WeatherData(measurementSystem: measurementSystem, interval: .Hour(time: Date().dateByAddingsHours(hours: 4)), temperature: 22, feelTemperature: 15, highTemperature: 16, lowTemperature: 16, windSpeed: 8, windDirection: "NE", weatherCondition: .Cloudy),
            WeatherData(measurementSystem: measurementSystem, interval: .Hour(time: Date().dateByAddingsHours(hours: 5)), temperature: 20, feelTemperature: 15, highTemperature: 16, lowTemperature: 16, windSpeed: 8, windDirection: "NE", weatherCondition: .Snow),
            WeatherData(measurementSystem: measurementSystem, interval: .Hour(time: Date().dateByAddingsHours(hours: 6)), temperature: 21, feelTemperature: 15, highTemperature: 16, lowTemperature: 16, windSpeed: 8, windDirection: "NE", weatherCondition: .Snow),
            WeatherData(measurementSystem: measurementSystem, interval: .Hour(time: Date().dateByAddingsHours(hours: 7)), temperature: 18, feelTemperature: 15, highTemperature: 16, lowTemperature: 16, windSpeed: 8, windDirection: "NE", weatherCondition: .Snow)
        ]

        longTermWeather = [
            WeatherData(measurementSystem: measurementSystem, interval: .Day(day: Date().dateByAddingsDays(days: 1)), temperature: 16, feelTemperature: 15, highTemperature: 16, lowTemperature: 16, windSpeed: 8, windDirection: "NE", weatherCondition: .Cloudy),
            WeatherData(measurementSystem: measurementSystem, interval: .Day(day: Date().dateByAddingsDays(days: 2)), temperature: 16, feelTemperature: 15, highTemperature: 16, lowTemperature: 16, windSpeed: 8, windDirection: "NE", weatherCondition: .Rain),
            WeatherData(measurementSystem: measurementSystem, interval: .Day(day: Date().dateByAddingsDays(days: 3)), temperature: 16, feelTemperature: 15, highTemperature: 16, lowTemperature: 16, windSpeed: 8, windDirection: "NE", weatherCondition: .Sunny),
            WeatherData(measurementSystem: measurementSystem, interval: .Day(day: Date().dateByAddingsDays(days: 4)), temperature: 16, feelTemperature: 15, highTemperature: 16, lowTemperature: 16, windSpeed: 8, windDirection: "NE", weatherCondition: .Sunny),
            WeatherData(measurementSystem: measurementSystem, interval: .Day(day: Date().dateByAddingsDays(days: 5)), temperature: 16, feelTemperature: 15, highTemperature: 16, lowTemperature: 16, windSpeed: 8, windDirection: "NE", weatherCondition: .Snow)
        ]
    }
}

private extension Date {
    static func calendar() -> Calendar {
        return Calendar.autoupdatingCurrent
    }

    func dateByAddingsDays(days: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.day = days

        return Date.calendar().date(byAdding: dateComponents, to: self)!
    }

    func dateByAddingsHours(hours: Int) -> Date {
        return self.addingTimeInterval(Double(hours) * 60 * 60)
    }
}
