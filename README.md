# Monitor Switch for Stream Deck

**Stream Deck のボタン1つで、パソコンにつないだモニターの「使う・使わない」を切り替えるプラグインです。**

ボタンの押し方を変えるだけで、3通りのモニターの使い方を呼び出せます。

| ボタンの押し方 | たとえば… |
|---|---|
| ポンと1回押す（短押し） | モニター1枚だけ使う |
| ポンポンと2回押す（ダブルタップ） | モニター2枚使う |
| 長押し（0.5秒くらい） | モニター3枚ぜんぶ使う |

どの押し方でどのモニターを使うかは、自分で自由に決められます。

[English below](#english)

---

## こんな人におすすめ

- **パソコンにモニターを何枚かつないでいて、そのうち何枚かを別のパソコン（会社のノートパソコンなど）でも使っている人**
  たとえば「仕事中はモニター2枚を会社のノートパソコンにつなぎ替えて、家のパソコンは残りの1枚だけ使う。仕事が終わったら全部家のパソコンに戻す」という使い方をしている人。
- モニターを切り替えるたびに、Windows の設定画面を開いてモニターを付けたり消したりするのが面倒な人
- モニターの数を変えるたびに、**メインのモニター（タスクバーや時計が出る画面）や並び方がずれてしまう**のが嫌な人
- Windows の「Win キー + P」で選べる「拡張」「PC画面のみ」だけでは、やりたい切り替えができない人
  （例：3枚のうち2枚だけ使いたい、など）

プログラムの知識は必要ありません。このページの手順どおりに進めれば使えます。

---

## 使えるパソコン

- **Windows 10 または Windows 11** のパソコン（Mac では使えません）
- **Stream Deck**（エルガトのボタンがたくさん付いた機械）と、その専用アプリ（バージョン 6.5 以降）

---

## 使い始めるまでの手順

### 手順1：プラグインをダウンロードする

1. このページの右側にある **「Releases」** をクリックします。
2. 一番上にある `com.monitorswitch.streamDeckPlugin` というファイルをクリックしてダウンロードします。

### 手順2：Stream Deck に入れる

1. ダウンロードしたファイル（`com.monitorswitch.streamDeckPlugin`）を**ダブルクリック**します。
2. Stream Deck のアプリが開いて「インストールしますか？」と聞かれたら、**「インストール」** を押します。

> もし「Windows によって PC が保護されました」という青い画面が出たら、「詳細情報」→「実行」を押してください。
> （個人が作ったプラグインのため、初めて開くときに表示されることがあります）

### 手順3：ボタンに置く

1. Stream Deck のアプリを開きます。
2. 右側の一覧を下にスクロールして **「Monitor Switch」** を探し、その中の **「Monitor Layout」** を、使いたいボタンの場所にドラッグ（マウスでつかんで移動）します。

### 手順4：1つ目のモニターの使い方を登録する

ここがいちばん大事な手順です。**「今の画面の状態」をそのまま登録する**しくみになっています。

1. まず Windows の画面を、登録したい状態にします。
   1. 画面左下のスタートボタンを右クリックし、**「設定」** を開きます。
   2. **「システム」→「ディスプレイ」** を開きます。
   3. 使わないモニターの四角をクリックし、下のほうにある項目で **「このディスプレイの接続を切断する」** を選びます。
   4. モニターの四角をマウスでドラッグして、実際の机の上の並び方と同じにします。
   5. メインにしたいモニター（タスクバーを出したいモニター）の四角をクリックし、**「メイン ディスプレイにする」** にチェックを入れます。
2. Stream Deck のアプリに戻り、手順3で置いたボタンをクリックします。
3. アプリの下のほうに設定欄が出ます。登録したい押し方（「短押し」「ダブルタップ」「長押し」）の横にある **「今の配置を登録」** ボタンを押します。

### 手順5：残りの押し方も登録する

手順4をくり返して、ほかの押し方にも別のモニターの使い方を登録します。
（2通りだけでよければ、1つは登録しなくても大丈夫です）

### 手順6：試してみる

設定欄の **「試す」** ボタンを押すと、登録した状態に切り替わります。
うまくいったら、あとは Stream Deck のボタンを押すだけで切り替えられます。

---

## ボタンの絵の見かた

ボタンには、今のモニターの状態が絵で表示されます。

- **青い四角**：使っているモニター
- **点線の四角**：使っていない（消えている）モニター
- **白い太い枠**：メインのモニター
- **下の数字**：使っているモニターの枚数
- **「…」**：切り替え中（2〜5秒ほどかかります）

---

## うまく動かないとき

| こんなとき | やってみること |
|---|---|
| ボタンを押すと黄色い「！」マークが出る | その押し方がまだ登録されていません。手順4で登録してください |
| モニターをつなぎ直したら動かなくなった | ケーブルを挿す場所を変えたり、モニターを買い替えたりすると、別のモニターとして扱われます。手順4から登録し直してください |
| 切り替えたのに一部のモニターが映らない | モニター本体の入力切り替え（HDMI1 / DisplayPort など）が、このパソコンになっているか確認してください |
| 切り替えに時間がかかる | 2〜5秒ほどかかるのは正常です。「…」が消えるまで待ってください |

---

## AI に頼んで自分好みに変える

このプラグインは中身（プログラム）がすべて公開されているので、**ChatGPT や Claude などの AI に頼めば、自分好みに作り変えることができます**。
プログラムが書けなくても、やりたいことを普通の言葉で伝えるだけで大丈夫です。

### 頼み方の例

AI に、このページのアドレス（URL）を伝えたうえで、次のようにお願いしてみてください。

- **ボタンの絵を変えたい**
  > 「このStream Deckプラグインのボタンの絵を変えたいです。使っているモニターを青ではなく緑にして、メインのモニターには星マークを付けてください。変更したファイルと、Stream Deck に入れ直す方法も教えてください。」
- **プラグインのアイコン（一覧に出る絵）を変えたい**
  > 「このプラグインのアイコン画像を、かわいいモニターのイラストにしたいです。必要な画像のサイズと置き場所を教えて、画像も作ってください。」
- **長押しの時間を変えたい**
  > 「長押しと判定されるまでの時間を0.5秒から1秒に変えたいです。どこをどう変えればいいですか？」
- **ボタンの下の文字を変えたい**
  > 「ボタンの下に出る『3枚』という文字を、『仕事』『ゲーム』のように押し方ごとに好きな名前にしたいです。」
- **うまく動かないときに相談したい**
  > 「このプラグインを入れたのですが、ボタンを押してもモニターが切り替わりません。Windows 11 で、モニターは3枚です。原因を一緒に調べてください。」

### 知っておくと AI への説明が楽になること

| やりたいこと | 関係するファイル |
|---|---|
| ボタンの絵（色・形） | `src/plugin.js` の中の「key image」の部分 |
| プラグインのアイコン画像 | `com.monitorswitch.sdPlugin/imgs/` フォルダの中の画像 |
| 長押し・ダブルタップの時間 | `src/plugin.js` の `HOLD_MS`（長押し）と `DOUBLE_MS`（ダブルタップ） |
| 設定欄の見た目・文字 | `com.monitorswitch.sdPlugin/ui/index.html` |
| モニターを切り替える処理 | `com.monitorswitch.sdPlugin/bin/Display.ps1` |

> 変更したあとは、プラグインを作り直して Stream Deck に入れ直す必要があります。
> そのやり方も AI に「作り直して入れ直す方法も教えて」と頼めば説明してもらえます（下の「開発者向け情報」も参考になります）。

---

## 開発者向け情報

<details>
<summary>クリックで開く</summary>

### ビルド

```bash
npm install
npm run build   # com.monitorswitch.sdPlugin/bin/plugin.js を生成
npm run pack    # dist/com.monitorswitch.streamDeckPlugin を生成
```

### ファイル構成

| パス | 内容 |
|---|---|
| `src/plugin.js` | プラグイン本体（押し方の判定、ボタンの絵の描画） |
| `com.monitorswitch.sdPlugin/bin/Display.ps1` | モニターのオン/オフ・位置・メインを設定する PowerShell スクリプト（Windows の `SetDisplayConfig` API を使用。外部ツール不要） |
| `com.monitorswitch.sdPlugin/ui/index.html` | Stream Deck アプリの設定欄 |
| `com.monitorswitch.sdPlugin/manifest.json` | プラグインの定義 |
| `tools/ScenarioTest.ps1` | すべての切り替えの組み合わせを自動で確認するテスト |

### Display.ps1 を単体で使う

```powershell
# 今使っているモニターを表示（ID / X / Y / 幅 / 高さ / 名前）
powershell -ExecutionPolicy Bypass -File Display.ps1 --list
# ABC1234 をメイン(0,0)、DEF5678 をその右に置き、それ以外は消す
powershell -ExecutionPolicy Bypass -File Display.ps1 ABC1234=0,0 DEF5678=1920,0
```

### 動作確認テスト

モニターの ID と位置は、設定欄の「今の配置」に表示される値を使います。実行中は画面が何度も切り替わります（1〜3分）。

```powershell
powershell -ExecutionPolicy Bypass -File tools\ScenarioTest.ps1 `
  -Short  "ABC1234=0,0" `
  -Double "DEF5678=0,0 ABC1234=0,-1080" `
  -Hold   "GHI9012=0,0 DEF5678=1920,0 ABC1234=1920,-1080"
```

結果は `tools/test-result.txt` に出力されます。

### ログ

`%APPDATA%\Elgato\StreamDeck\Plugins\com.monitorswitch.sdPlugin\logs\`

</details>

---

## ライセンス

[MIT](LICENSE)（自由に使ったり、改造したり、配布したりできます）

---

<a id="english"></a>
## English

A Stream Deck plugin for Windows that turns monitors on and off with a single key.
Assign a different monitor setup to **short press, double press and hold** — which monitors are on, how they are arranged, and which one is the main monitor.

### Who is this for?

- You have several monitors on your PC and **share some of them with another computer** (e.g. a work laptop).
- You are tired of opening Windows Settings to turn monitors on and off, and of your **main monitor and arrangement getting mixed up**.
- `Win + P` is not enough because you want setups like **2 of 3 monitors**.

No programming knowledge needed.

### How to set it up

1. Open **Releases** on this page and download `com.monitorswitch.streamDeckPlugin`.
2. Double-click the file and choose **Install** in Stream Deck.
3. In the Stream Deck app, drag **Monitor Switch → Monitor Layout** onto a key.
4. In Windows **Settings → System → Display**, set up your monitors the way you want (turn unused ones off with "Disconnect this display", drag them into place, and tick "Make this my main display").
5. Click the key in the Stream Deck app and press **Capture** next to the press type you want.
6. Repeat steps 4–5 for the other press types. Use **Test** to try a setup.

### Key icon

Blue = on, dashed = off, white border = main monitor. The number shows how many monitors are on.

### Customize it with AI

All the code is open, so you can ask an AI assistant (ChatGPT, Claude, etc.) to change it for you — for example the key colors, the plugin icon, or the hold time. Give it the URL of this page and describe what you want in plain words.

Requirements: Windows 10/11, Stream Deck software 6.5 or later. Licensed under MIT.
