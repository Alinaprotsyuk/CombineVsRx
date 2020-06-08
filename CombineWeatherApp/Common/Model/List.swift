/* 
Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct List : Codable {
    
	let dt : Int?
	let sunrise : Int?
	let sunset : Int?
	let temp : Temp?
//	let feels_like : Feels_like?
	let pressure : Int?
	let humidity : Int?
	let weather : [Weather]?
	let speed : Double?
	let deg : Int?
	let clouds : Int?

	enum CodingKeys: String, CodingKey {

		case dt = "dt"
		case sunrise = "sunrise"
		case sunset = "sunset"
		case temp = "temp"
//		case feels_like = "feels_like"
		case pressure = "pressure"
		case humidity = "humidity"
		case weather = "weather"
		case speed = "speed"
		case deg = "deg"
		case clouds = "clouds"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		dt = try values.decodeIfPresent(Int.self, forKey: .dt)
		sunrise = try values.decodeIfPresent(Int.self, forKey: .sunrise)
		sunset = try values.decodeIfPresent(Int.self, forKey: .sunset)
		temp = try values.decodeIfPresent(Temp.self, forKey: .temp)
//		feels_like = try values.decodeIfPresent(Feels_like.self, forKey: .feels_like)
		pressure = try values.decodeIfPresent(Int.self, forKey: .pressure)
		humidity = try values.decodeIfPresent(Int.self, forKey: .humidity)
		weather = try values.decodeIfPresent([Weather].self, forKey: .weather)
		speed = try values.decodeIfPresent(Double.self, forKey: .speed)
		deg = try values.decodeIfPresent(Int.self, forKey: .deg)
		clouds = try values.decodeIfPresent(Int.self, forKey: .clouds)
	}

}
