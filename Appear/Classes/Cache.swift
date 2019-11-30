//
//  Cache.swift
//  Appear
//
//  Created by Magnus Tviberg on 30/11/2019.
//

import Foundation

protocol Cache: class {
    func put<C: Codable>(_ cachable: C, withKey key: String, expires expiration: CacheExpiration) throws
    func get<C: Codable>(_ type: C.Type, forKey key: String) -> C?
    func has<C: Codable>(_ type: C.Type, forKey key: String) -> Bool
    func remove<C: Codable>(_ type: C.Type, forKey key: String) throws
    func clear() throws
}

enum CacheExpiration {
    case `in`(TimePeriod)
    case at(date: Date)
    case never

    var expirationDate: Date? {
        switch self {
        case .`in`(let timePeriod):
            return Date(timeInterval: timePeriod.timeInterval, since: Date())
        case .at(let date):
            return date
        case .never:
            return nil
        }
    }

    var timestamp: TimeInterval? {
        return expirationDate?.timeIntervalSince1970
    }

    enum TimePeriod {
        case seconds(Int)
        case minutes(Int)
        case hours(Int)
        case days(Int)
        case months(Int)

        var timeInterval: TimeInterval {
            switch self {
            case .seconds(let n):
                return TimeInterval(n)
            case .minutes(let n):
                return TimePeriod.seconds(n * 60).timeInterval
            case .hours(let n):
                return TimePeriod.minutes(n * 60).timeInterval
            case .days(let n):
                return TimePeriod.hours(n * 24).timeInterval
            case .months(let n):
                return TimePeriod.days(n * 31).timeInterval
            }
        }
    }
}
