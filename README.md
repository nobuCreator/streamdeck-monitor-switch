# Monitor Switch for Stream Deck

Stream Deck のキー1つで、Windows のモニター構成を切り替えるプラグインです。
**短押し・ダブルタップ・長押し**の3通りに、それぞれ別のモニター構成を割り当てられます。

- どのモニターを点けるか / 消すか
- 各モニターの位置（並び方）
- どのモニターをメインにするか

をまとめて切り替えます。キーのアイコンには今の構成が図で表示されます。

[English below](#english)

---

## こんな人向け

- **デスクトップPCにモニターを複数つないでいて、そのうち何枚かを別のPC（会社のノートPCなど）と共有している人**
  例：仕事中はモニター2枚をノートPCに切り替え、残りだけデスクトップで使う。仕事が終わったら全部デスクトップに戻す。
- 「Win + P」の「拡張」「PC画面のみ」では足りず、**3枚中2枚だけ**のような中途半端な構成に切り替えたい人
- モニターを減らしたり増やしたりするたびに、**メインモニターや並び方が崩れて**直すのが面倒な人
- 設定画面を開かずに、**キー1つ**で切り替えたい Stream Deck ユーザー

## できること

| 押し方 | 動作 |
|---|---|
| 短押し | 「短押し」に登録した構成に切り替え |
| ダブルタップ | 「ダブルタップ」に登録した構成に切り替え |
| 長押し（0.5秒） | 「長押し」に登録した構成に切り替え |

- 構成は、Windows の「設定 → ディスプレイ」で並べた**今の配置をボタン1つで登録**するだけです。設定ファイルの手書きは不要です。
- 切り替え時にコマンドプロンプトなどの**黒い画面は出ません**。
- キーのアイコン：点いているモニターは青、消えているモニターは点線、メインモニターは白い太枠。下に点いている枚数を表示します。
- 30秒ごとに状態を読み直すので、Windows 側で手動で変えた場合もアイコンに反映されます。
- 外部ツールは使わず、Windows の「設定 → ディスプレイ」画面と同じ仕組み（`SetDisplayConfig` API）で切り替えます。

## 動作環境

- Windows 10 / 11
- Stream Deck ソフトウェア 6.5 以降
- Stream Deck 本体（キー操作のみ。Stream Deck + のダイヤルには非対応）

## インストール

1. [Releases](../../releases) から `com.monitorswitch.streamDeckPlugin` をダウンロードします。
2. ダブルクリックすると Stream Deck にインストールされます。

## 使い方

1. Stream Deck アプリの右側の一覧にある **Monitor Switch → Monitor Layout** を、好きなキーにドラッグします。
2. Windows の「設定 → システム → ディスプレイ」で、1つ目の構成にします。
   - 使わないモニターは「このディスプレイの接続を切断する」
   - 並び方をドラッグで調整
   - メインにしたいモニターで「メイン ディスプレイにする」
3. Stream Deck アプリでそのキーを選び、下の設定欄で、割り当てたい押し方の **「今の配置を登録」** を押します。
4. 2〜3 を、残りの押し方についても繰り返します。
5. 「試す」ボタンで、登録した構成に切り替わるか確認できます。

> 登録していない押し方を押すと、キーに警告マークが出て何もしません。2通りだけ使うこともできます。

## 動作確認テスト（任意）

すべての切り替えの組み合わせを自動で試し、結果を `tools/test-result.txt` に書き出すスクリプトがあります。
モニターの ID と位置は、設定欄の「今の配置」に表示される値（例：`ABC1234 0,0`）を使います。

```powershell
powershell -ExecutionPolicy Bypass -File tools\ScenarioTest.ps1 `
  -Short  "ABC1234=0,0" `
  -Double "DEF5678=0,0 ABC1234=0,-1080" `
  -Hold   "GHI9012=0,0 DEF5678=1920,0 ABC1234=1920,-1080"
```

実行中は画面が何度も切り替わります（1〜3分）。

## うまく動かないとき

- **モニターが見つからない**：ケーブルの差し込み口を変えたり、モニターを買い替えたりすると ID が変わります。構成を登録し直してください。
- **ログ**：`%APPDATA%\Elgato\StreamDeck\Plugins\com.monitorswitch.sdPlugin\logs\` に動作記録が残ります。
- 切り替えには 2〜5 秒ほどかかります（処理中はキーに「…」が出ます）。

## ソースからビルド

```bash
npm install
npm run build   # com.monitorswitch.sdPlugin/bin/plugin.js を生成
npm run pack    # dist/com.monitorswitch.streamDeckPlugin を生成
```

| パス | 内容 |
|---|---|
| `src/plugin.js` | プラグイン本体（押し方の判定、アイコン描画） |
| `com.monitorswitch.sdPlugin/bin/Display.ps1` | モニターのオン/オフ・位置・メインを設定するスクリプト（単体でも使えます） |
| `com.monitorswitch.sdPlugin/ui/index.html` | Stream Deck アプリの設定欄 |
| `tools/ScenarioTest.ps1` | 動作確認テスト |

`Display.ps1` は単体でも使えます。

```powershell
# 今点いているモニターを表示（ID / X / Y / 幅 / 高さ / 名前）
powershell -ExecutionPolicy Bypass -File Display.ps1 --list
# ABC1234 をメイン(0,0)、DEF5678 をその右に。それ以外はオフ
powershell -ExecutionPolicy Bypass -File Display.ps1 ABC1234=0,0 DEF5678=1920,0
```

## ライセンス

[MIT](LICENSE)

---

<a id="english"></a>
## English

A Stream Deck plugin for Windows that switches your monitor layout with a single key.
Assign a different layout to **short press, double press and hold**. Each layout defines which monitors are on, where they are placed, and which one is the main monitor. The key icon shows the current layout.

### Who is this for?

- You have several monitors on a desktop PC and **share some of them with another computer** (e.g. a work laptop) — and want to switch between "all monitors on the desktop" and "only some of them" with one key.
- `Win + P` is not enough because you need layouts like **2 of 3 monitors**.
- Your **main monitor and arrangement get messed up** every time you turn monitors on and off.

### Setup

1. Download `com.monitorswitch.streamDeckPlugin` from [Releases](../../releases) and double-click it.
2. Drag **Monitor Switch → Monitor Layout** onto a key.
3. Arrange your monitors in Windows *Settings → System → Display* (turn monitors off with "Disconnect this display", set the main display).
4. In the key's settings, press **Capture** for the press type you want. Repeat for the other press types.

No command windows appear when switching. No third-party tools are used — layouts are applied with the Windows `SetDisplayConfig` API, the same one the Settings app uses.

Requirements: Windows 10/11, Stream Deck software 6.5 or later. Licensed under MIT.
