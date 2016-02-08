# 7.4.1194 に追いつくプロジェクト

ここらでいっちょ最新に追いつこうぜ、というプロジェクト。最低限、新機能のド
キュメントを未翻訳のままでも、日本語ファイルに組み入れてしまう。

最近Vim本体の更新が激しいので、多少のズレはでてしまうが、まずは気にせず1194を
ターゲットにする。

## 流れ

1.  英語ファイルを全部更新 (終わった!)
2.  1の差分を見ながら、日本語ファイルに英文のまま反映 (最低限の目標:終わった!)
3.  2の差分を翻訳 (できたらココまでやりたい)
4.  このファイルを削除

## ファイル一覧

### 英文だけは反映済み

以上は変更点が100行未満なので、翻訳しやすいはず。

    doc/netbeans.jax
    doc/spell.jax
    doc/usr_02.jax    # 行数は多いけど、まとまった書き換えで、楽そう

こっから先は100行超えるので、嫌。

    doc/options.jax
    doc/pi_netrw.jax  # 地獄
    doc/syntax.jax
    doc/windows.jax

### 完訳!

    doc/autocmd.jax
    doc/change.jax
    doc/cmdline.jax
    doc/develop.jax
    doc/editing.jax
    doc/eval.jax
    doc/filetype.jax
    doc/fold.jax
    doc/hangulin.jax
    doc/help.jax
    doc/if_lua.jax    # 100行超えたけど、内容的に大したことない
    doc/if_mzsch.jax
    doc/if_perl.jax
    doc/if_pyth.jax
    doc/if_ruby.jax
    doc/if_tcl.jax
    doc/index.jax
    doc/insert.jax
    doc/map.jax
    doc/mlang.jax
    doc/os_os2.jax
    doc/pattern.jax
    doc/pi_logipat.jax
    doc/quickfix.jax
    doc/quickref.jax
    doc/repeat.jax
    doc/tagsrch.jax
    doc/term.jax
    doc/usr_03.jax
    doc/usr_29.jax
    doc/usr_41.jax
    doc/usr_43.jax
    doc/various.jax
    doc/vi_diff.jax

### その他/深い事情があって断念したもの

まだない
