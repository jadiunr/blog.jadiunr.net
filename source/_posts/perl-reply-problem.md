---
title: PerlのReplyでReadlineが効かない時
date: 2019-12-22 12:00:00
tags: Perl
---

[ITCのアドベントカレンダー22日目](https://adventar.org/calendars/4713)です。
歴史的にスカスカで号泣してんすけど、こんな記事でもいいので何か書いてください...

[read, eval, print, loop, yay!](https://metacpan.org/pod/Reply) ただしReadlineが効かないって話

<!-- more -->

# 問題

冒頭で既に書きましたがReplyを入れただけではREPLでReadlineが効かないことがあります。

```
0> my $hogehogeunko = 'aaaaaaaa'
$res[0] = 'aaaaaaaa'

1> print $hi^[[D
        👆ア？

2> ^[[A^[[A^[[A^[[A^[[A^[[A
        👆ア？
```

Term::ReadLineがデフォルトで入っているので問題ない気がしますが、コレは罠でTerm::ReadLine::Gnuも入れないと動いてくれません(は？)。

# 解決

Term::ReadLine::Gnuを入れましょう。

```
# あるいはcpanfileにでも
cpanm -nq Term::ReadLine::Gnu
```

Readlineパッケージは既に入ってると思いますが無ければ入れておきましょう。

```
# ArchLinuxの場合　ほかはしらん
sudo pacman -Sy readline
```

以上。Tab補完したりとか矢印キーで履歴見たりとかできるようになります。