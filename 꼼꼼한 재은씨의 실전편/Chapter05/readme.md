# 챕터5 - 프로퍼티 리스트, 데이터 저장

### 프로퍼티 리스트(Property List)란?

객체 직렬화를 위한 XML형식의 파일이다. `.plist`라는 확장자 명을 사용하며 XML 포맷에 맞추어 `Key-Value` 형식의 `Dictionary` 타입으로 데이터를 저장한다.



프로젝트를 처음 만들면 `Info.plist` 파일이 자동으로 생성되는데 앱의 환경 설정값을 저장하는 대표적인 프로퍼티 리스트 파일이다.



 프로퍼티 리스트는 데이터의 타입을 추상화하여 저장합니다. 타입의 추상화란 예를들어 `String`, `NSString`, `CFString` 같은 다양한 구체적 타입을 단순히 문자열 이라는 요소만 추출하여  `<string>` 이라는 타입으로 저장한다는 의미입니다. 



### 프로퍼티 리스트와 데이터 타입

| 타입     | XML                   | Swift         | 파운데이션        | 코어파운데이션      |
| ------ | --------------------- | ------------- | ------------ | ------------ |
| 배열     | `<array>`             | Array         | NSArray      | CFArray      |
| 딕셔너리   | `<dict>`              | Dictionary    | NSDictionary | CFDictionary |
| 문자열    | `<string>`            | String        | NSString     | CFString     |
| 날짜     | `<date>`              | -             | NSDate       | CFDate       |
| Base64 | `<data>`              | -             | NSData       | CFData       |
| 정수     | `<integer>`           | Int, UInt     | NSNumber     | CFNumber     |
| 실수     | `<reak>`              | Float, Double | NSNumber     | CFNumber     |
| 논리형    | `<true/>`, `<false/>` | Bool          | NSNumber     | CFNumber     |

위 표처럼 `plist`에 저장할 수 있는 타입 `<integer>`은 `Int`, `UInt`, `NSNumber`, `CFNumber` 네가지 타입이 저장 될 수 있다. 다른 타입도 마찬가지로 하나의 타입에 여러 자료형이 대응 될 수 있다.



### 프로퍼티 리스트 작성 실습


