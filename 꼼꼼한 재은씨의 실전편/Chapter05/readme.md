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

 .swift 파일 추가하는것과 마찬가지로 `command + n` 으로 plist 파일을 추가 할 수 있다.

xcode의 plist 편집기능으로 편집 할 수 있고, 텍스트 편집기로 편집하고 싶다면 `Open As > Source` 를 선택 하면 된다.

이렇게 추가된 plist 파일은 앱스토어로 배포되고 사용자에게 설치될 때 `App Bundle` 이라는 영역에 저장된다.

### UserDefaults

 iOS앱은 기본적인 데이터를 저장하기위한 공간을 가지고있습니다. 앱이 처음 실행될 때`<앱 아이디>.plist` 형태로 생성되며 비교적 간단한 데이터를 편리하게 저장 할 수 있습니다.

 UserDefaults는 싱글톤으로 앱 전체에서 단 하나를 공유해서 사용합니다. 그리고 UserDefaults를 다루기 위한 프로퍼티와 함수들을 제공합니다.

##### 동시성 문제

 하나의 자원에 여럿이 동시에 접근하면 동시성 문제가 발생 할 수 있습니다. 다행히 UserDefaults는 동시성 문제로부터 안전하게 설계 되어있습니다. 먼저 들어온 요청을 처리하는 동안 다른 요청에 대해 잠금을 걸고 접근을 차단합니다. 이와 같은것을 `Thread-safe` 하다고 합니다.

#### UserDefaults 객체를 통한 데이터 처리

`UserDefaults.standard` 를 통해 `표준 사용자 기본 저장소`에 접근 가능, 이를 통해 읽어들인 데이터는 nil 값이 반환 될 수 있다.

 UserDefaults 객체는 인메모리 캐싱 메커니즘을 사용하기 때문에 저장소와 메모리 간에 데이터가 일치하지 않을 가능성이 존재한다. 동기화가 필요한 순간에는 `synchronize()` 메소드를 사용합니다.

### 커스텀 프로퍼티 리스트

UserDefaults 대신 직접 생성한 Plist 파일에 데이터를 저장 할 수 있으며 이를 `커스텀 Plist`라고 합니다.

커스텀 프로퍼티 리스트를 다루는 과정은 크게 세 단계로 이루어집니다.

1. plist 파일을 읽어와 딕셔너리 객체에 담는다.

2. 딕셔너리 객체에 필요한 값을 추가하거나 수정한다.

3. 딕셔너리 객체를 파일에 기록한다.

```swift
//1단계 파일을 읽어온다
let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
let path = paths[0] as NSString
let plist = path.strings(byAppendingPaths: ["파일멍.plist"]).first!
let data = NSMutableDictionary(contentsOfFile: plist)

//2단계 데이터를 수정한다
data.setValue(true, forKey: "married")

//3단계 plist 파일에 저장
data.write(toFile: plist, atomically: true)
```

 iOS는 보안을 이유로 애플리케이션마다 파일에 접근할 수 있는 공간이 나뉘어 있고 이를 `샌드박스`라고 한다.

plist 경로를 찾을때 사용한  `.documentDirectory`는 샌드박스의 문서전용 디렉토리 경로를 찾아내기 위함이다.

시뮬레이터에서 실행하는경우 해당 경로로 직접 접근이 가능하다. `print(path)` 로 경로를 확인해서 시뮬레이터 저장소의 App 경로로 들어가면 `Documents` 라는 폴더가 있음.

### UserDefaults VS custom plist

 두 방식은 동일하게 plist를 사용해서 동작합니다. 비교적 간단한 데이터를 저장하기 위한 용도라는 점 도 비슷합니다. 코드 작성은 UserDefaults가 훨씬 편합니다.

하지만 UserDefaults는 앱에서 하나만 사용할 수 있기도 해서 일반적으로 그룹 단위로 묶어서 저장해야하는 데이터이거나 데이터가 너무 많은경우는 각각의 custom plist로 분리하여 작성합니다.

CustomPlist 실습에서 사용자 계정 정보는 각각의 계정마다 plist를 생성하여 저장하고, 전체 계정 목록은 UserDefaults에 저장하는 방식을 사용합니다.



### 기타

이번 장에서 해본 기타 작업 목록

- 스토리보드에서 테이블 뷰를 static cell 타입으로 사용하기 - cell 항목이 고정된 화면인 경우

- UILabel에 액션 메소드 추가하기 - 탭 제스처 사용

- 경로를 만들때 `strings(byAppendingPaths:)` 사용 - 문자열 마지막에 '/' 문자가 여부에 따라 오류가 발생 하는것을 방지

- `BarButtonItem`에 가변 폭 버튼을 사용하여 버튼을 정렬


