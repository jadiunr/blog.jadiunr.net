---
title: HashiCorp Boundary の検証環境作成、および設定に関する補足
date: 2020-12-24 9:00:00
tags: Infra
---

[ITC アドベントカレンダー16日目](https://adventar.org/calendars/5079)ですが公開したのは24日です。遅れてすんませんした。
めちゃくちゃ詳しく書こうと思ってたんですけど、公式ドキュメントに書いてること日本語で書き直しても大して生産性が無いので、ドキュメント読んでも分かりにくい (あるいは分からない) 点について補足でもしておくといいのかなと思いました。技術記事書くのむずすぎるねん。
あと検証環境作りました。Tutorial 見たら速攻作れるんですけどブラックボックスが過ぎるんでイチから構築した。

# HashiCorp Boundary

https://www.boundaryproject.io/

ざっくり言うと高度な踏み台サーバとして機能するやつです。
細かいことは公式見たほうが早いです。英語ですが

## ネットワーク構成

![](network.jpg)

Redis はテスト用にとりあえず作ってるだけです。
Boundary では使いません。
てかこの記事では結局扱いませんでした。起動までなので。

## 検証環境

これ

https://github.com/voltaxic-rift/boundary-sandbox

Boundary では `boundary dev` によって Docker コンテナ上に開発環境を構築できるのですが、落とした時毎回 DB が吹っ飛んでだるいので Vagrant/VirtualBox で作りました。
あと、実稼働環境においては Boundary サーバだけでなく PostgreSQL サーバも準備する必要があります。そのへん Boundary のドキュメントではめちゃ端折ってる (あるいは手順などバラバラ) ので補足しておくと嬉しいかなと。
というか Postgres ほぼ触ったことなかったのでなんもわからんかった。カス
なお、vagrant up 時に provision が走るようになっているので、Postgres -> Boundary の順番で上げるとすべての環境が整います。
上記リポジトリを元に、Boundary 構築の補足をしていきます。

## PostgreSQL

テストされるのが11以上なので13を使っています。
インストールしただけだと外から繋げないので設定を変える必要があります。
Docker 公式 Image の Dockerfile と同じことやってますが商用で使える保証はありません。
Postgres わからんねん。

```
echo "host all all all md5" >> /etc/postgresql/13/main/pg_hba.conf
sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /etc/postgresql/13/main/postgresql.conf
```

Boundary 用の DB と Role を作っておく必要があるので、作っておきます。
権限付与もお忘れなく。

```
sudo -u postgres -i psql -c "create role boundary with login password 'boundary'"
sudo -u postgres -i psql -c "create database boundary"
sudo -u postgres -i psql -c "grant all privileges on database boundary to boundary"
```

## Boundary Server

ドキュメント通り Systemd で起動します。
Boundary は2つのコンポーネントがあり、Controller が認証を担当し、Worker が対象サーバへのプロキシを担当します。
両者は別のサーバに分散させられますが、めんどくさいので詰め込んでいます。
まずは Controller と Worker 両方の HCL 設定ファイルを用意します。

### Controller

- `purpose = "api"`

API あるいは Web UI フロントエンドです。
Default Port は9200です。
 `address` は外部から到達できる必要があります。

- `purpose = "cluster"`

Worker が Controller に接続する際に使用するものです。
Default Port は9201です。
`address` は Worker から到達できる必要があります。

### Worker

- `purpose = "proxy"`

Controller で認証したクライアントを対象サーバに接続させるためのプロキシです。
Default Port は9202です。
`address` は外部から到達できる必要があります。
`public_addr` はホストに直接バインドされない Amazon EIP などを使用する際に使うとのこと。

## Boundary: Systemd Unit 作成から起動まで

特に補足することはないのでリポジトリ見て。
`boundary database init` によって DB の初期化が実行されます。
あとは Tutorial 見ながらよしなにどうぞ。

## Boundary まとめ

クライアントにも Boundary を入れないといけないってのが辛すぎる。
それさえ問題なければ LDAP とかよりも2億倍は楽な権限管理が実現できそうです。
OpenLDAP の OLC まじで意味不明すぎて発狂しそう。

# チラ裏

見事に遅刻したけど記事書く時間より環境作ってる時間のほうが長かったからゆるして。
かなり適当に書いたけど Vagrant の構成見ながらドキュメントとにらめっこしてたら分かるはずなのでがんばって。