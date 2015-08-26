# I"s - eternal me

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


- Day object

		{
			"_id": "1234567890abcdfegh"
			"dayId": "20150712",
			"manualRooms": [
				(Manual Room ObjectId),
				(Manual Room ObjectId),
				...
			],
			"automaticRooms": [
				(Automatic Room ObjectId),
				(Automatic Room ObjectId),
				...
			],
			"memorys": [
				(Memory ObjectId),
				(Memory ObjectId),
				...
			]
			"createAt": "2015-07-07T12:00:00.024Z"
		}

- Manual Room object

		{
			"_id": "1234567890abcdfegh",
			"dayId": "20150713", 
			"roomId": "123456",
			"capacity": 6,
			"lastModified": "2015-07-07T12:00:00.024Z",
		}

- Automatic Room object

		{
			"_id": "1234567890abcdfegh",
			"dayId": "20150713", 
			"roomId": "123456",
			"capacity": 6,
			"lastModified": "2015-07-07T12:00:00.024Z",
		}

- Memory object

	APIから取得する場合のMemory Object

		{
			"_id": "1234567890abcdfegh",
			"dayId": "20150712",
			"url": "//is-eternal.me/memorys/1234567890abcdfegh", (virtual)
			"link": "https://www.google.co.jp/",
			"window": {
				"width": 1920,
				"height": 1080
			},
			"ext": ".jpeg",
			"imgSrc": "//is-eternal.me/memorys/20150712/1234567890abcdfegh.jpeg", (virtual)
			"positions": [
		      	{ x: 0, y: 0 },
		      	{ x: 0, y: 0 },
		        ...
		    ],
			"random": [0.1, 0],
			"createAt": "2015-07-07T12:00:00.024Z"
		}

	- data[0]._id (int): 登録されている軌跡のID
	- data[0].dayId (string): 登録時のDayID
	- data[0].roomId (string): 登録時に入室していたRoomID
	- data[0].roomType (number): 0 = "Manual" or 1 = "Automatic"
	- data[0].url (string): 個別のリンク  
	- data[0].link (string): 登録時に閲覧していたサイトのURL  
	- date[0].positions.window: 登録時のブラウザWindowサイズ  
		- width: Window 幅
		- height: Window 高さ
	- date[0].positions.image: 登録時閲覧していたサイトのスクリーンショット
		- filename: 画像ファイル名    
		- width: スクリーンショット 幅
		- height: スクリーンショット 高さ
	- date[0].positions: 軌跡
		- x: x座標
		- y: y座標
		- ※ 軌跡の記録時間は最大6秒、時間はランダムに決まる
	- date[0].room (Object ID): 関係するRoomのObject ID
	- data[0].createDate (string): 登録時の時間  

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
軌跡のデータを保存する  

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
    {
		"status": 1
    }

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

    {
		"status": 0,
		"data": {
			"error_code": 400,
			"error_message": "validation error."
			"validation": {
				"id": [
					"idを指定してください"
				]
			}
		}
    }

	// error_code (int): エラーコード
	// error_message (string): エラーメッセージ
	// validation (object): バリデーション内容を収めたオブジェクト



- - -
<a name="socket_api"></a>
# socket.io 系

* [connect](#connect)
* [disconnect](#disconnect)
* [join](#join)
* [windowResize](#windowResize)
* [pointerMove](#pointerMove)
* [shootLandscape](#shootLandscape)

### port: 80

下記のルールでアクセス可能とする  
エクステンション用 Name Space  
http://api.is-eternal.me/extension

## Namespace `Extension`


<a name="connect"></a>
### 【connect】
ユーザーの追加通知

#### Overview
`Client -> API`  
ユーザーがWebSocketサーバーとの接続が成功した時に通知される  
Socket接続を開始する

##### Parameters

##### Callback

###### Server

```js
socketIo.on( 'connection', function( socket ){});
```

###### Client

```js
var socket = io.connect( 'http://api.is-eternal.me/extension' );
```

***


<a name="disconnect"></a>
### 【disconnect】

#### Overview
`Client -> API`  
ユーザーがWebSocketサーバーとの接続が切断した時に受信する    
Socket接続を終了し、それまで所属していたroom のcapacity をデクリメントする  
[checkOut](#io-checkOut) を発信する

##### Request Parameters

##### Callback

###### Server

```js
```

###### Client

```js
```

***


<a name="join"></a>
### 【join】
ユーザーの追加通知  
[checkIn](#io-checkIn) を発信する

#### Overview
`Client -> API`  

##### Request Parameters
- data

		@param {Object}
		@prop {String} [roomId] - 接続するRoomID

		{
			"roomId": "000000"
		}

##### Response 

###### Server

```js
```

###### Client

```js
```


***


<a name="windowResize"></a>
### 【windowResize】
ユーザーのwindow サイズを受信する  
受信した値を元に[updateWindowSize](#io-updateWindowSize) を発信する

#### Overview
`Client -> API`  

##### Request Parameters
- data

		@param {Object}
		@prop {number} [width] - 接続ユーザーのwindow の幅
		@prop {number} [height] - 接続ユーザーのwindow の高さ

		{
			"width": 1920
			"height": 1080
		}

##### Response 

###### Server

```js
```

###### Client

```js
```


***


<a name="pointerMove"></a>
### 【pointerMove】
ポインターが移動した時に通知される  
同じRoom にJoin しているユーザーに [updatePointer](#io-updatePointer) を発信する

#### Overview
`Client -> API`  

##### Request Parameters
- data

		@param {Object}
		@prop {number} x - 発信者のポインターのx座標
		@prop {number} y - 発信者のポインターのy座標

		{
			x: 265,
			y: 246
		}

##### Response

###### Server

```js
```

###### Client

```js
```

***


<a name="shootLandscape"></a>
### 【shootLandscape】
スクリーンショットが更新されたタイミングで通知される  
同じRoom にJoin しているユーザーに [updateLandscape](#io-updateLandscape) を発信する

#### Overview
`Client -> API`  

##### Request Parameters
- data

		@param {Object}
		@prop {string} landscape - スクリーンショット（base64）

		{
			landscape: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAACFCAYAAACt……"
		}


##### Response

###### Server

```js
```

###### Client

```js
```

***


# socket.io event
以下のように受信可能  

	socket.on('userAdded', function(data) {
		var image_path = data.image_path;
	})

***

<a name="io-checkIn"></a>
### 【checkIn】
同じRoom に所属するユーザーのSocket ID の配列を受信する  
room へのjoin が完了したタイミングで発信される 

#### Overview
`API -> Client`  

##### Request Parameters

##### Response 
- data

		@return {Object}
		@prop {[string]} [users] - 同じRoom に所属するユーザーのSocket ID の配列

		{
			"users": [
				"T16ontoFZG1fx7OpAAAH",
				"3fKlmlfGtKBXtnw-AAAD",
				"WPFZdXhEwrgstuB0AAAG"
			]
		}

###### Server

```js
```

###### Client

```js
```

***

<a name="io-checkOut"></a>
### 【checkOut】
同じRoom に所属していたユーザーのSocket ID を受信する  
socket サーバーからのdisconnect が完了したタイミングで発信される 

#### Overview
`API -> Client`  

##### Request Parameters

##### Response 
- data

		@return {string} 同じRoom に所属していたユーザーのSocket ID

		"T16ontoFZG1fx7OpAAAH"

###### Server

```js
```

###### Client

```js
```


***


<a name="io-updateWindowSize"></a>
### 【updateWindowSize】
同じRoom に所属するユーザーのwindow サイズを受信する  

#### Overview
`API -> Client `  

##### Request Parameters

##### Response 
- data

		@param {Object}
		@prop {string} socketId - 発信元のsocket.id
		@prop {number} [width] - 接続ユーザーのwindow の幅
		@prop {number} [height] - 接続ユーザーのwindow の高さ


		{
			socketId: "T16ontoFZG1fx7OpAAAH",
			width: 1920,
			height: 1080
		}

###### Server

```js
```

###### Client

```js
```

***


<a name="io-updatePointer"></a>
### 【updatePointer】
同じRoom に所属するユーザーのポインターの座標を受信する  

#### Overview
`API -> Client `  

##### Request Parameters

##### Response 
- data

		@param {Object}
		@prop {string} socketId - 発信元のsocket.id
		@prop {number} x - 発信者のポインターのx座標
		@prop {number} y - 発信者のポインターのy座標

		{
			socketId: "T16ontoFZG1fx7OpAAAH",
			x: 265,
			y: 246
		}

###### Server

```js
```

###### Client

```js
```

***

<a name="io-updateLandscape"></a>
### 【updateLandscape】
同じRoom に所属するユーザーのスクリーンショットをBase64 で受信する  

#### Overview
`API -> Client `  

##### Request Parameters

##### Response 
- data

		@param {Object}
		@prop {string} socketId - 発信元のsocket.id
		@prop {string} landscape - スクリーンショット（base64）

		{
			socketId: "T16ontoFZG1fx7OpAAAH",
			landscape: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAACFCAYAAACt……"
		}

###### Server

```js
```

###### Client

```js
```

***

<a name="io-receiveMemorys"></a>
### 【receiveMemorys】
データベースのMemorys からランダムにMemory Document を返す  

#### Overview
`API -> Client `  

##### Request Parameters

##### Response 
- data

		@param {Object}
		@prop {[Memory]} memorys - Memory Document の配列


		- Memory object
		{
			memorys: {
				[
					{
						"_id": "1234567890abcdfegh",
						"dayId": "20150712",
						"url": "//is-eternal.me/memorys/1234567890abcdfegh", (virtual)
						"link": "https://www.google.co.jp/",
						"window": {
							"width": 1920,
							"height": 1080
						},
						"ext": ".jpeg",
						"imgSrc": "//is-eternal.me/memorys/20150712/1234567890abcdfegh.jpeg", (virtual)
						"positions": [
					      	{ x: 0, y: 0 },
					      	{ x: 0, y: 0 },
					        ...
					    ],
						"random": [0.1, 0],
						"createAt": "2015-07-07T12:00:00.024Z"
					},
					...
				]
			}
		}

###### Server

```js
```

###### Client

```js
```

***