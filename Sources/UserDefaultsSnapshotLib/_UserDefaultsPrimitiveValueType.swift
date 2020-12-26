/**
 Copyright 2020 Hiroshi Kimura

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

public protocol _UserDefaultsPrimitiveValueType {

}

extension String: _UserDefaultsPrimitiveValueType {}
extension Bool: _UserDefaultsPrimitiveValueType {}
extension Int: _UserDefaultsPrimitiveValueType {}
extension Date: _UserDefaultsPrimitiveValueType {}
extension Int8: _UserDefaultsPrimitiveValueType {}
extension Int16: _UserDefaultsPrimitiveValueType {}
extension Int32: _UserDefaultsPrimitiveValueType {}
extension Int64: _UserDefaultsPrimitiveValueType {}
extension UInt: _UserDefaultsPrimitiveValueType {}
extension UInt8: _UserDefaultsPrimitiveValueType {}
extension UInt16: _UserDefaultsPrimitiveValueType {}
extension UInt32: _UserDefaultsPrimitiveValueType {}
extension UInt64: _UserDefaultsPrimitiveValueType {}
extension Float: _UserDefaultsPrimitiveValueType {}
extension Double: _UserDefaultsPrimitiveValueType {}
extension Data: _UserDefaultsPrimitiveValueType {}

extension Dictionary: _UserDefaultsPrimitiveValueType where Key == String, Value : _UserDefaultsPrimitiveValueType {}
extension Array: _UserDefaultsPrimitiveValueType where Element : _UserDefaultsPrimitiveValueType {}

