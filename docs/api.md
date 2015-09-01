# I"s

* [Roomについて](#room_section)
* [REST_API](#rest_api)
* [SOCKET_API](#socket_api)

- - -
<a name="room_section"></a>
## Roomについて
### 概要

- Room にはユーザーが任意に作成するManual Room と自動生成されるAutomatic Roomがある
- 起動画面のform Join Space IDから送信されたRoomID（数字6桁）を元にSocketサーバーにRoomを生成する
- formからの送信された値のRoomがすでに存在すればそのRoomに接続する
- Random Joinから接続するとRoomIDをランダムに生成して接続する
- ひとつのRoomの最大接続数は6

### RoomIDの取り回し方
1. 新規起動時
  - `join`をid無し、またはRandom Joinでemitするとサーバー側で新規RoomIDが割り当てられる
  - ~~割り当てられたRoomIDを`localStorage.roomId`に保存する~~

2. ~~2回め以降の起動時~~
  - ~~localStorageに保存したRoomIDをパラメータとして`join`をemit~~
  - ~~当該idが期限切れになっていたら場合は新規RoomIDが返されるのでlocalStorageに保存する~~
  - ~~Room（Space）からログアウトするとlocalStorageに保存してあるRoomIDを破棄する~~
  - ~~Roomが期限切れになるとRoomIDを破棄する~~

***

## Memoryについて
### 概要

- Memory の保存は1秒24コマ。最大6秒。

***

#### Day Object 
```js
/**
 * @param {Object}
 * @prop {string} _id - 登録されているMongo ID
 * @prop {string} dayId - Roomが作成された日付を元に割り振られるID、数値からなる文字列8桁
 * @prop {[Manual Room]} manualRooms - このDay Objectが持つdayIdを持つMemory Room _idの配列
 * @prop {[Automatic Room]} automatic - このDay Objectが持つdayIdを持つAutomatic Room _idの配列
 * @prop {[Memory]} memorys - このDay Objectが持つdayIdを持つMemory _idの配列
 * @prop {string} createAt - 登録時の時間
 */
{
  _id: "1234567890abcdfegh",
  dayId: "20150712",
  manualRooms: [
    (Manual Room ObjectId),
    (Manual Room ObjectId),
    ...
  ],
  automaticRooms: [
    (Automatic Room ObjectId),
    (Automatic Room ObjectId),
    ...
  ],
  memorys: [
    (Memory ObjectId),
    (Memory ObjectId),
    ...
  ]
  createAt: "2015-07-07T12:00:00.024Z"
}
```


#### Manual Room Object
```js
/**
 * @param {Object}
 * @prop {string} _id - 登録されているMongo ID
 * @prop {string} dayId - Roomが作成された日付を元に割り振られるID、数値からなる文字列8桁
 * @prop {string} roomId - RoomのID、任意の数値からなる文字列6桁
 * @prop {number} capacity - このRoom Objectに入室できるユーザーの数
 * @prop {string} createAt - 登録時の時間
 */
{
  _id: "1234567890abcdfegh",
  dayId: "20150713", 
  roomId: "123456",
  capacity: 6,
  createAt: "2015-07-07T12:00:00.024Z"
}
```


#### Automatic Room Object
```js
/**
 * @param {Object}
 * @prop {string} _id - 登録されているMongo ID
 * @prop {string} dayId - Roomが作成された日付を元に割り振られるID、数値からなる文字列8桁
 * @prop {string} roomId - RoomのID、ランダムな数値からなる文字列6桁
 * @prop {number} capacity - このRoom Objectに入室できるユーザーの数
 * @prop {string} createAt - 登録時の時間
 */
{
  _id: "1234567890abcdfegh",
  dayId: "20150713", 
  roomId: "123456",
  capacity: 6,
  createAt: "2015-07-07T12:00:00.024Z"
}
```

#### Memory Object

  APIから取得する場合のMemory Object
```js
/**
 * @param {Object}
 * @prop {string} _id - 登録されているMongo ID
 * @prop {string} dayId - 登録時のDayID
 * @prop {string} url - 個別のリンク
 * @prop {string} link - 登録時に閲覧していたサイトのURL
 * @prop {Object} window
 * @prop {number} window.width - 登録時のWindow幅
 * @prop {number} window.height - 登録時のWindow高さ
 * @prop {string} ext - 登録時閲覧していたサイトのスクリーンショットの拡張子
 * @prop {string} landscape - 登録時閲覧していたサイトのスクリーンショットまでのパス
 * @prop {[Object]} positions
 * @prop {number} positions[n].x - x座標
 * @prop {number} positions[n].y - y座標
 * @prop {[number]} random[n] - ランダム取得時に使う数値、長さは2。[0]は0.0〜1.0の乱数
 * @prop {string} createAt - 登録時の時間
 */
{
  _id: "1234567890abcdfegh",
  dayId: "20150712",
  url: "//is-eternal.me/memorys/1234567890abcdfegh", (virtual)
  link: "https://www.google.co.jp/",
  window: {
    width: 1920,
    height: 1080
  },
  ext: ".jpeg",
  landscape: "//is-eternal.me/memorys/20150712/1234567890abcdfegh.jpeg", (virtual)
  positions: [
    { x: 0, y: 0 },
    { x: 0, y: 0 },
    ...
  ],
  random: [0.1, 0],
  createAt: "2015-07-07T12:00:00.024Z"
}
```



<a name="rest_api"></a>
# REST API

* [【GET】- memory](#get-memory)
* [【GET】- memory/:day](#get-memory-day)
* [【GET】- memory/random](#get-memory-random)
* [【GET】- memory/rooms/:id](#get-memory-rooms)
* [【GET】- memory/search/:id](#get-memory-search)
* [【GET】- rooms/](#put-)
* [【PUT】- rooms/:id](#put-)
* [【DELETE】- memory/:day](#delete-)
* [【DELETE】- memory/rooms/:id](#delete-)
* [【DELETE】- memory/search/:id](#delete-)
* [error 定義](#error)

## 各 API の URL
下記のルールでアクセス可能とする

    http://api.is-eternal.me/{API名}

## 各 API 解説

<a name="get-memory"></a>
### 【memory】
登録済みの軌跡を取得する

#### ■ リクエストメソッド
GET

#### ■ リクエストパラメータ
##### - limit (int) (required)
取得する件数

#### ■ 成功時戻り値
    {
      "results": [
        (Memory Object),
        (Memory Object),
        ...
      ]
    }


#### エラーパターン
* 500: Internal Server Error
* 400: Bad Request
* 404: Not Found（アイテムが見つからない場合）


***
<a name="get-memory-day"></a>
### 【memory/:day】
特定の日付に登録されて軌跡を取得する

#### ■ リクエストメソッド
GET

#### ■ リクエストパラメータ
##### - year (int) (required)
取得対象の年
##### - month (int) (required)
取得対象の月
##### - year (int) (required)
取得対象の日付

#### ■ 成功時戻り値
    {
    "status": 1,
    "data": [
        {
          "id": 0,
          "uri": "http://xxxxxx",
          "image": "http://is-eternal.me/images/screen/xxxxx.jpg",
          "date": "Sunday 30 November 2014 13:59:56",
          "positions": [
            {
              x: 0,
              y: 0
            },
            {
              x: 0,
              y: 0
            }
          ]
        },
        {
          "id": 1,
          "uri": "http://xxxxxx",
          "date": "Sunday 30 November 2014 13:59:56",
          "image": "http://is-eternal.me/images/screen/xxxxx.jpg",
          "positions": [
            {
              x: 0,
              y: 0
            },
            {
              x: 0,
              y: 0
            }
          ]
        }
      ]
    }

data[0].id (int): 登録されている軌跡のID  
data[0].uri (string): 登録時に閲覧していたサイトのURI  
data[0].image (string): 登録時に閲覧していたサイトのスクリーンショット  
data[0].date (string): 登録時の時間  
date[0].positions.x: 軌跡の x座標  
date[0].positions.y: 軌跡の y座標

#### エラーパターン
* 500: Internal Server Error
* 400: Bad Request
* 404: Not Found（アイテムが見つからない場合）


***
<a name="get_search_is"></a>
### 【get_search_is】
特定IDの軌跡を取得する

#### ■ リクエストメソッド
GET

#### ■ リクエストパラメータ
##### - id (int) (required)
取得対象のID

#### ■ 成功時戻り値
    {
    "status": 1,
    "data": 
      {
        "id": 0
        "uri": "http://xxxxxx",
        "image" "http://is-eternal.me/images/screen/xxxxx.jpg",
        "date": "Sunday 30 November 2014 13:59:56",
        "positions": [
          {
            x: 0,
            y: 0
          },
          {
            x: 0,
            y: 0
          }
        ]
      }       
    }

data[0].id (int): 登録されている軌跡のID  
data[0].uri (string): 登録時に閲覧していたサイトのURI  
data[0].image (string): 登録時に閲覧していたサイトのスクリーンショット  
data[0].date (string): 登録時の時間  
date[0].positions.x: 軌跡の x座標  
date[0].positions.y: 軌跡の y座標

#### エラーパターン
* 500: Internal Server Error
* 400: Bad Request
* 404: Not Found（アイテムが見つからない場合）


***
<a name="add_is"></a>
### 【add_is】
軌跡のデータをMemoryとして保存する  

#### ■ リクエストメソッド
POST

#### ■ リクエストパラメータ

##### - uri (string) (required)
登録時に閲覧していたサイトのURI  

##### - image (string) (required)
JPEG画像を base64 エンコードした文字列  

##### - positions (object) (required)
軌跡の座標 `{ [x: (int), y: (int)] }`

#### ■ 成功時戻り値（ログイン）
```js
{
  status: 1
}
```

#### エラーパターン
* 500: Internal Server Error
* 400: Bad Request


***
<a name="error"></a>
### 【error 定義】

#### ■ エラーコード定義

400: Bad Request  
404: Not Found  
500: Internal Server Error  
999: その他原因不明なエラー  

#### ■ エラーレスポンス定義
```js
/**
 * @param {Object}
 * @prop {number} status       - 0 or 1
 * @prop {number} errorCode    - エラーコード  
 * @prop {string} errorMessage - エラーメッセージ  
 */
{
  status: 0,
  errorCode: 400,
  errorMessage: "Error."
}
``` 



- - -
<a name="socket_api"></a>
# socket.io 系

### Namespace `Extension` : port `80`
下記のルールでアクセス可能とする  
エクステンション用 Name Space  
http://api.is-eternal.me/extension

#### `Client -> API`  
* [connect](#io-connect)
* [disconnect](#io-disconnect)
* [join](#io-join)
* [initializeUser](#io-initializeUser)
* [initializeResident](#io-initializeResident)
* [changeLocation](#io-changeLocation)
* [windowResize](#io-windowResize)
* [pointerMove](#io-pointerMove)
* [shootLandscape](#io-shootLandscape)
* [addMemory](#io-addMemory)
* [getMemorys](#io-getMemorys)

#### `API -> Client`  
* [addUser](#io-addUser)
* [addResident](#io-addResident)
* [checkOut](#io-checkOut)
* [updateLocation](#io-updateLocation)
* [updateWindowSize](#io-updateWindowSize)
* [updatePointer](#io-updatePointer)
* [updateLandscape](#io-updateLandscape)



***



<a name="io-connect"></a>
### 【connect】

#### Overview
`Client -> API`  
新規ユーザーがWebSocketサーバーとの接続が成功した時に通知される  
Socket通信を開始する

##### Parameters
```js
```

##### Response (Emit Callback) 
```js
```

###### Server
```js
socketIo.on( 'connection', function( socket ){});
```

###### Client
```js
var socket = io.connect( 'http://api.is-eternal.me/extension' );
```



***



<a name="io-disconnect"></a>
### 【disconnect】

#### Overview
`Client -> API`  
ユーザーがWebSocketサーバーとの接続を切断した時に受信する    
Socket通信を終了し、それまで所属していたroomのcapacityをインクリメントする  
[checkOut](#io-checkOut) を発信する

##### Request Parameters
```js
```

##### Response (Emit Callback) 
```js
```

###### Server
```js
```

###### Client
```js
```



***



<a name="io-join"></a>
### 【join】
新規ユーザーのRoomへの追加依頼を受信する    
Manual Roomへの入室処理をする場合はRequest ParametersにroomIdを指定する。  
roomIdが指定されていなければAutomatic Roomへの入室処理をする。

#### Overview
`Client -> API`  

##### Request Parameters
```js
/**
 * @param {Object}
 * @prop {string} [roomId] - 接続するRoomID
 */
{
  roomId: "000000"
}
```

##### Response (Emit Callback) 
```js
/**
 * @callback Function
 */
```

###### Server
```js
```

###### Client
```js
```



***



<a name="io-initializeUser"></a>
### 【initializeUser】
Roomにjoinした新規ユーザーの初期値を受信する  
先に同じ空間に入室していたユーザーに[addUser](#io-addUser)を発信する

#### Overview
`Client -> API`  

##### Request Parameters
```js
/**
 * @param {Object}
 * @prop {number} position.x - 接続ユーザーのポインター x座標
 * @prop {number} position.y - 接続ユーザーのポインター y座標
 * @prop {number} window.width - 接続ユーザーのwindow の幅
 * @prop {number} window.height - 接続ユーザーのwindow の高さ
 * @prop {string} link - 接続ユーザーが閲覧していたページのURL
 * @prop {string} landscape - スクリーンショット（base64）
 */
{
  position: {
    x: 265,
    y: 246
  },
  window: {
    width: 1920,
    height: 1080
  },
  link: "https://www.google.co.jp/",
  landscape: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAACFCAYAAACt……"
}
```

##### Response (Emit Callback) 
```js
```

###### Server
```js
```

###### Client
```js
```



***



<a name="io-initializeResident"></a>
### 【initializeResident】
Roomにjoinした新規ユーザーに対して先に入室していたユーザーの初期化に必要な値を受信する  
新規ユーザーに対して[addResident](#io-addResident)を発信する

#### Overview
`Client -> API`  

##### Request Parameters
```js
/**
 * @param {Object}
 * @prop {string} toSoketId - 送信先のsocketID
 * @prop {number} position.x - 接続ユーザーのポインター x座標
 * @prop {number} position.y - 接続ユーザーのポインター y座標
 * @prop {number} window.width - 接続ユーザーのwindow の幅
 * @prop {number} window.height - 接続ユーザーのwindow の高さ
 * @prop {string} link - 接続ユーザーが閲覧していたページのURL
 * @prop {string} landscape - スクリーンショット（base64）
 */
{
  toSoketId: "T16ontoFZG1fx7OpAAAH",
  position: {
    x: 265,
    y: 246
  },
  window: {
    width: 1920,
    height: 1080
  },
  link: "https://www.google.co.jp/",
  landscape: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAACFCAYAAACt……"
}
```

##### Response (Emit Callback) 
```js
```

###### Server
```js
```

###### Client
```js
```



***



<a name="io-changeLocation"></a>
### 【changeLocation】
Roomにjoinしているユーザーの閲覧しているURLを受信する  
受信した値を元に同じRoomにjoinしているユーザーに[updateLocation](#io-updateLocation)を発信する

#### Overview
`Client -> API`  

##### Request Parameters
```js
/**
 * @param {Object}
 * @prop {string} link - 接続ユーザーの閲覧しているURL
 */
{
  link: "https://www.google.co.jp/"
}
```

##### Response (Emit Callback) 
```js
```

###### Server
```js
```

###### Client
```js
```



***



<a name="io-windowResize"></a>
### 【windowResize】
Roomにjoinしているユーザーのwindowサイズを受信する  
受信した値を元に同じRoomにjoinしているユーザーに[updateWindowSize](#io-updateWindowSize)を発信する

#### Overview
`Client -> API`  

##### Request Parameters
```js
/**
 * @param {Object}
 * @prop {number} width - 接続ユーザーのwindow の幅
 * @prop {number} height - 接続ユーザーのwindow の高さ
 */
{
  width: 1920,
  height: 1080
}
```

##### Response (Emit Callback) 
```js
```

###### Server
```js
```

###### Client
```js
```



***



<a name="io-pointerMove"></a>
### 【pointerMove】
Roomにjoinしているユーザーのポインターが移動した時に通知される  
受信した値を元に同じRoomにjoinしているユーザーに[updatePointer](#io-updatePointer)を発信する

#### Overview
`Client -> API`  

##### Request Parameters
```js
/**
 * @param {Object}
 * @prop {number} x - 発信者のポインターのx座標
 * @prop {number} y - 発信者のポインターのy座標
 */
{
  x: 265,
  y: 246
}
```

##### Response (Emit Callback) 
```js
```

###### Server
```js
```

###### Client
```js
```



***



<a name="io-shootLandscape"></a>
### 【shootLandscape】
スクリーンショットが撮影されたタイミングで通知される  
受信した値を元に同じRoomにjoinしているユーザーに[updateLandscape](#io-updateLandscape)を発信する

#### Overview
`Client -> API`  

##### Request Parameters
```js
/**
 * @param {Object}
 * @prop {string} dataUrl - スクリーンショット（base64）
 */
{
  landscape: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAACFCAYAAACt……"
}
```

##### Response (Emit Callback) 
```js
```

###### Server
```js
```

###### Client
```js
```



***



<a name="io-addMemory"></a>
### 【addMemory】
Client側でデータベースにMemoryとして保存するデータが生成されたタイミングで通知される  
受信した値をデータベースに保存し、保存に成功したらクライアント側にコールバックを通知する  

#### Overview
`Client -> API`  

##### Request Parameters
```js
/**
 * @param {Object}
 */
{
  link: "https://www.google.co.jp/",
  window: {
    width: 1920,
    height: 1080
  },
  landscape: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAACFCAYAAACt……"
  positions: [
    { x: 0, y: 0 },
    { x: 0, y: 0 },
    ...
  ]
}
```

##### Response (Emit Callback) 
```js
/**
 * @callback Function
 */
```

###### Server
```js
```

###### Client
```js
```



***



<a name="io-getMemorys"></a>
### 【getMemorys】
データベースのMemorys CollectionからランダムにMemory Documentを取得してクライアントに返す  

#### Overview
`API -> Client `  

##### Request Parameters
```js
```

##### Response 
```js
```

##### Response (Emit Callback) 
```js
/**
 * @callback Function
 * 下記のイベントオブジェクトをクライアント側に返す
 * @param {Object}
 * @prop {[Memory]} memorys - Memory Documentの配列
 */
{
  memorys: {
    [
      {
        _id: "1234567890abcdfegh",
        dayId: "20150712",
        roomId: "000001",
        roomType: 0,
        url: "//is-eternal.me/memorys/1234567890abcdfegh", (virtual)
        link: "https://www.google.co.jp/",
        window: {
          width: 1920,
          height: 1080
        },
        ext: ".jpeg",
        landscape: "//is-eternal.me/memorys/20150712/1234567890abcdfegh.jpeg", (virtual)
        positions: [
          { x: 0, y: 0 },
          { x: 0, y: 0 },
          ...
        ],
        random: [0.1, 0],
        createAt: "2015-07-07T12:00:00.024Z"
      },
      ...
    ]
  }
}

```

###### Server
```js
```

###### Client
```js
```


***



# socket.io event
以下のように受信可能  
```js
socket.on('addUser', function(data) {
  console.log(data);
});
```
***


<a name="io-addUser"></a>
### 【addUser】
新規にjoinしたユーザーの情報をそれまでログインしていたユーザーにを通知する  

#### Overview
`API -> Client (送信先: roomId | 送信方法: broadcast)`

##### Request Parameters
```js
```

##### Response 
```js
/**
 * @param {Object}
 * @prop {string} id - 新規ユーザーのsocket.id
 * @prop {number} position.x - 新規ユーザーのポインター x座標
 * @prop {number} position.y - 新規ユーザーのポインター y座標
 * @prop {number} window.width - 新規ユーザーのwindow の幅
 * @prop {number} window.height - 新規ユーザーのwindow の高さ
 * @prop {string} link - 新規ユーザーが閲覧していたページのURL
 * @prop {string} landscape - スクリーンショット（base64）
 */
{
  id: "T16ontoFZG1fx7OpAAAH",
  position: {
    x: 265,
    y: 246
  },
  window: {
    width: 1920,
    height: 1080
  },
  link: "https://www.google.co.jp/",
  landscape: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAACFCAYAAACt……"
}
```

###### Server
```js
```

###### Client
```js
```


***


<a name="io-addResident"></a>
### 【addResident】
新規にjoinしたユーザーに対してそれまでに入室していたユーザーの情報を通知する  

#### Overview
`API -> Client (送信先: toSocketId)`    

##### Request Parameters
```js
```

##### Response 
```js
/**
 * @param {Object}
 * @prop {string} id - 接続済ユーザーのsocket.id
 * @prop {number} position.x - 接続済ユーザーのポインター x座標
 * @prop {number} position.y - 接続済ユーザーのポインター y座標
 * @prop {number} window.width - 接続済ユーザーのwindow の幅
 * @prop {number} window.height - 接続済ユーザーのwindow の高さ
 * @prop {string} link - 接続済ユーザーが閲覧していたページのURL
 * @prop {string} landscape - スクリーンショット（base64）
 */
{
  id: "T16ontoFZG1fx7OpAAAH",
  position: {
    x: 265,
    y: 246
  },
  window: {
    width: 1920,
    height: 1080
  },
  link: "https://www.google.co.jp/",
  landscape: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAACFCAYAAACt……"
}
```

###### Server
```js
```

###### Client
```js
```


***



<a name="io-checkOut"></a>
### 【checkOut】
同じRoomに所属していたユーザーのSocket IDをClientへ発信する  
socketサーバーからのdisconnectが完了したタイミングで発信される 

#### Overview
`API -> Client (送信先: roomId | 送信方法: broadcast)`   

##### Request Parameters
```js
```

##### Response 
```js
/**
 * @param {Object}
 * @prop {string} id - 同じRoomに所属していたユーザーのSocketID
 */
{
  id: "T16ontoFZG1fx7OpAAAH"
}
```

###### Server
```js
```

###### Client
```js
```


***



<a name="io-updateLocation"></a>
### 【updateLocation】
同じRoom に所属するユーザーの閲覧しているURLをClientへ発信する  

#### Overview
`Client -> API (送信先: roomId | 送信方法: broadcast)`  

##### Request Parameters
```js
```

##### Response (Emit Callback) 
```js
/**
 * @param {Object}
 * @prop {string} id - 発信者のsocket.id
 * @prop {string} link - 接続ユーザーの閲覧しているURL
 */
{
  id: "T16ontoFZG1fx7OpAAAH",
  link: "https://www.google.co.jp/"
}
```

###### Server
```js
```

###### Client
```js
```



***



<a name="io-updateWindowSize"></a>
### 【updateWindowSize】
同じRoom に所属するユーザーのwindowサイズをClientへ発信する  

#### Overview
`API -> Client (送信先: roomId | 送信方法: broadcast)`  

##### Request Parameters
```js
```

##### Response 
```js
/**
 * @param {Object}
 * @prop {string} id - 発信者のsocket.id
 * @prop {number} window.width - 発信者のwindowの幅
 * @prop {number} window.height - 発信者のwindowの高さ
 */
{
  id: "T16ontoFZG1fx7OpAAAH",
  window: {
    width: 1920,
    height: 1080
  }
}
```

###### Server
```js
```

###### Client
```js
```


***



<a name="io-updatePointer"></a>
### 【updatePointer】
同じRoomに所属するユーザーのポインターの座標をClientへ発信する  

#### Overview
`API -> Client `  

##### Request Parameters
```js
```

##### Response 
```js
/**
 * @param {Object}
 * @prop {string} id - 発信者のsocket.id
 * @prop {number} position.x - 発信者のポインターのx座標
 * @prop {number} position.y - 発信者のポインターのy座標
 */
{
  id: "T16ontoFZG1fx7OpAAAH",
  position: {
    x: 265,
    y: 246
  }
}
```

###### Server
```js
```

###### Client
```js
```



***



<a name="io-updateLandscape"></a>
### 【updateLandscape】
同じRoomに所属するユーザーのスクリーンショットをBase64でClientへ発信する  

#### Overview
`API -> Client `  

##### Request Parameters
```js
```

##### Response 
```js
/**
 * @param {Object}
 * @prop {string} id - 発信元のsocket.id
 * @prop {string} landscape - スクリーンショット（base64）
 */
{
  id: "T16ontoFZG1fx7OpAAAH",
  landscape: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAACFCAYAAACt……"
}
```

###### Server
```js
```

###### Client
```js
```



***