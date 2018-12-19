---
title: DataChannelの使い方
date: 2018-12-19 12:00:00
tags: WebRTC
---

> この記事は[OIC ITCreate Club Advent Calendar 2018](https://adventar.org/calendars/3072) 19日目です
> 昨日は[hiroki](https://adventar.org/calendars/3072#list-2018-12-18)さんでした

トラコン1次予選にWebRTCの問題があったのですけど、解説を今読んでみたら余りにクソチョロ過ぎて泣いてました。その当時は名前しか存じ上げなかったのでしょうがないね。
http://icttoracon.net/tech-blog/2018/08/27/ictsc2018-prep01-webrtc-p/
2問目がDataChannelに関するものでした、これはDataChannelを扱う時に陥りがちな罠ではないかと個人的に感じたので、今日はその話を含めてWebRTCのDataChannelの話をします。

あとトラコン2次予選は土曜日にやりましたけど12位でした　[激！激！激！激クソ](https://mstdn.maud.io/@jadiunr/101257336684646201)
49チーム中12位だったので我々は良い結果を残したと思い込んでおきます。

# 対象者

[これ](https://booth.pm/ja/items/628127)を3周くらい読んでいる人

最高の本なので買ってください。

# DataChannel

WebRTCには映像/音声を送受信するMediaChannelと、それ以外のデータも送受信できるDataChannelがあります。
JavaScriptにおいて、DataChannelで扱えるデータ型は次の4つです。

- String
- Binary Large Object (Blob)
- ArrayBuffer
- ArrayBufferView

ちなみにChromeでBlobをDataChannelで投げようとしたら「実装してない」って怒られました。泣いてます。
他のブラウザでは試していませんが、少なくともChrome70ではBlobをArrayBufferに変換して送信する必要があります。

# 使い方

## Offer視点

### WebRTCのコネクションを確立

SDPを投げ合ってP2Pコネクションを確立するところまでは省略します。
ただ、注意点が一つだけあって、**必ずPeerに対するDataChannelを作成してからOfferSDPを生成する**必要があります。これがトラコン1次予選で出題された罠です。

```javascript
const dataChannel = peer.createDataChannel("hoge");
const offer = await peer.createOffer();
```

DataChannelを作っておかないとスッカラカンのSDPが生成されるため、対向Peerと正常にネゴシエーションが出来ません。
MediaChannelの場合も同様に、Offer生成前にPeerに対してTrackを投入しておく必要があります。

```javascript
localStream.getTracks().forEach(track => {
  peer.addTrack(track, localStream);
});
const offer = await peer.createOffer();
```

### イベントハンドラ

dataChannelが作成された後は、次のようなイベントハンドラで処理できます。

```javascript
dataChannel.onopen = (ev) => {
  console.log(ev);
  dataChannel.send("Hello");  
};
dataChannel.onmessage = (ev) => console.log(ev);
dataChannel.onerror = (ev) => console.log(ev);
dataChannel.onclose = (ev) => console.log(ev);
```

## Answer視点

### peer.ondatachannelの発火を待つ

Offer側でDataChannelが作成されると、Answer側では`ondatachannel`が発火します。
OfferSDPを貰ったタイミングでAnswer側でもDataChannelを作ることはできますが、DataChannelを双方で2本張る必要があるかと言うと怪しいところです。

```javascript
peer.ondatachannel = (ev) => {
  const dataChannel = ev.channel;
  dataChannel.onopen = (ev) => {
    console.log(ev);
    dataChannel.send("Hola");
  };
  dataChannel.onmessage = (ev) => console.log(ev);
  dataChannel.onerror = (ev) => console.log(ev);
  dataChannel.onclose = (ev) => console.log(ev);
};
```

イベントハンドラはOfferで扱うものと同じです。
Answer側は少し特殊で、ondatachannelの引数(ev: Event)からdataChannelを取り出すという手間があります。それだけです。

# チラ裏

DataChannelに関する資料はMediaChannelと比べると少ないですが、例えばWebTorrentではWebRTCのDataChannelが使われていますし、P2P CDNのPeer5でもDataChannelが使われています。
WebRTCでは映像/音声に限らず、あらゆるデータをサーバレスで送る事が出来るので、他にも色々な用途で使えそうです。
あと最近初めて参加させてもらった学生LTでも少しだけWebRTCの話をしたのですが、割とウケたので助かりました。
P2Pは夢があっていいですね。
夢はありますが大抵よからぬことに使われるの本当に泣く。

明日は[elipmoc](https://adventar.org/calendars/3072#list-2018-12-20)です。クリーンなC++楽しみにしています。俺は読めない(えっ)