# I"s - eternal me

* [REST_API](#rest_api)
* [SOCKET_API](#socket_api)

- - -

## Roomについて
### 概要

- 起動画面のform（Join Space ID）から送信されたRoomID（数字6桁）を元にRoomを生成する
- formからの送信された値のRoomがすでに存在すればそのRoomに接続する
- Random Joinから接続するとRoomIDをランダムに生成して接続する
- ひとつのRoomの最大接続数は6

### RoomIDの取り回し方
1. 新規起動時
	- `join`をid無し、またはRandom Joinでemitするとサーバー側で新規RoomIDが割り当てられる
	- 割り当てられたRoomIDを`localStorage.roomId`に保存する

2. 2回め以降の起動時
	- localStorageに保存したRoomIDをパラメータとして`join`をemit
	- 当該idが期限切れになっていたら場合は新規RoomIDが返されるのでlocalStorageに保存する
	- Room（Space）からログアウトするとlocalStorageに保存してあるRoomIDを破棄する
	- Roomが期限切れになるとRoomIDを破棄する


- Day object

		{
			"_id": "1234567890abcdfegh"
			"dayID": ""20150712,
			"rooms": [
				(Room ObjectId),
				(Room ObjectId),
				...
			],
			"createDate": "2015-07-07T12:00:00.024Z"
		}

- Room object

		{
			"_id": "1234567890abcdfegh",
			"roomID": "123456",
			"memorys": [
				(Memory ObjectId),
				(Memory ObjectId),
				...
			]
			"isJoin": true
			"lastModified": "2015-07-07T12:00:00.024Z",
		}

- Memory object

	APIから取得する場合のMemory Object

		{
			"_id": "1234567890abcdfegh",
			"dayID": "20150712",
			"roomID": "123456",
			"url": "//is-eternal.me/memory/20150712/123456/1234567890abcdfegh"
			"link": "https://www.google.co.jp/"
			"window": {
				"width": 1920
				"height": 1080
			},
			"image": {
				"filename": "1234567890abcdfegh.jpeg",
				"width": 480,
				"height": 640,
			},
			"positions": [
		        { x: 0, y: 0 },
		        { x: 0, y: 0 },
		        ...
		    ],
			"room": (Room ObjectId),
			"createDate": "2015-07-07T12:00:00.024Z"
		}

	- data[0]._id (int): 登録されている軌跡のID
	- data[0].dayID (string): 登録時のDayID
	- data[0].roomID (string): 登録時に入室していたRoomID
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

* [receivePointer](#receivePointer)
* [receiveIs](#receivePointer)
* [getImage](#getImage)

### port: 80

下記のルールでアクセス可能とする

    http://is-eternal.me/api/sockets

## 各 API イベントリスナー 解説

<a name="addUser"></a>
## 【publicPointer】
ユーザー追加通知依頼


### ■ リクエストメソッド
POST

### ■ リクエストパラメータ
#### - image_path (string) (required)
保存された画像のパス

	例）img/1.png

### ■ 成功時戻り値
	{
	    "status": 1,
	    "data": {
	        "image_path": "xxxxxx"
	    }
	}

##### response detail
* data.image_path (string): api が受け取った画像パス（確認用）

  
  
# socket.io event
以下のように受信可能  

	socket.on('userAdded', function(data) {
		var image_path = data.image_path;
	})