---
title: 今「WebRTC」がアツい！ WebRTCでリレー配信を試してみる
date: 2018-12-22 12:00:00
tags:
---

> この記事は[mstdn.maud .io Advent Calendar 2018](https://adventar.org/calendars/2892) 22日目です
> 昨日は[けーぶる・うぃすたー](https://mstdn.maud.io/@wister_fl)さんでした

別にWebRTCがアツいかというと結構怪しいですけど、[期待に応えたかった](http://wisteriabook.hatenadiary.jp/entry/2018/12/21/173207#%E3%82%BF%E3%82%A4%E3%83%88%E3%83%AB%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6)ので

> WebRTCでリレー配信を試してみる
> ↓
> 今「WebRTC」がアツい！ WebRTCでリレー配信を試してみる

自分の中ではアツい方です。
表題の件ですが、試してみたら出来てしまったので書きます。

# 誰だオメーは

Geneと申します。しがない専門学生です。
ICTSCに参加しながらITインフラ周りの勉強とかやってますが、最近サボり気味です。今年の二次予選でBGPが出題されましたが全部忘れてて終わった
あと技術書典で本出したので買ってね(宣伝)
https://kinyoubenkyokai.github.io/book/techbook05/

ハンドルネームは過去に何度か変えていて(Shivaとか5184とか)その時代の人からは"しばさん"とか"5184"と呼ばれています。
"ネットワークのおべんきょしませんか"のGeneさんではないです。著書"詳解IPマルチキャスト"には大変お世話になりました。

# 迫真WebRTC、MediaStreamの裏技

WebRTCで扱うMediaStream、実はコレ対向Peerから受信したものを別のPeerにそのまま渡して再生させられるんですね。
これが出来るということはPeerCastのような配信構造を実現できるので、WebRTCを使って単方向配信をする場合には非常に有用なのですね。(需要があるかは怪しいけど。大体SFUとか使ってる気がする。)
てか切断時に一瞬だけ映像途切れてる気がする　多分使い物にならない😩

# Sample Code

死ぬほど適当に書いた。
Rails+ActionCableです。
FrontはVueです。死ぬほど雑に書いた。

https://github.com/jadiunr/spls-exp

Docker & Docker Compose必須です。
`script/bootstrap` を実行した後 `docker-compose up -d` してください。
`localhost:8080` でTopページに移ります。
`/login` に飛んでしてログインを済ませた後
`/live` に飛んで下さい。 `Video Start` を押してから `Live Start` で配信できます。
配信開始後はシークレットウインドウとか作って `/watch/hoge` に飛ぶと映像が受信できるはずです。
たまに失敗するのでリロードしてください(ha)。

- 認証情報: email: hoge@example.jp, password: hogehogeunko

以下チラシの裏です。

# Node Model

```
class Node {
  uuid: String // 一意に割り当てられるNodeのID
  parent_uuid: String // 接続先の親NodeのID
  children_uuid: String[] // 配下にいる子NodeのID
  relayable: Boolean // リレーの可否を示す　使ってません(は？)
}
```

# Diagram

クソポンチ絵

## 1.新しいNodeが参加した時

![](diagram1.png)

この場合Node Lは親NodeからRoot Nodeが配信しているMediaStreamを受け取って再生出来ます。

## 2.末端Nodeが切断した時

![](diagram2.png)

切断通知を受信した親Nodeは自身の子Nodeの配列から当該Nodeを削除します。

## 3.中間Nodeが切断した時

![](diagram3.png)

a: 切断通知を受信したら自身の子Nodeの配列から当該Nodeを削除します。
b, c: 切断通知を受信したら再度NodeTreeを取得して`1.新しいNodeが参加した時`に戻ります

# 今後

映像途切れるのクソクソクソといった感じなので、多分ですけどMediaRecorderで録画した映像をDataChannelでぶん投げてMedia Source Extensionsに食わせればシームレスになりそう。やってみます。
というか、配信するならOBSとか使いたい　RTMPなんもわからん。

明日は[meganesoft](https://mstdn.maud.io/@meganesoft)さんです。
しりとりはマジでしなくていいです。