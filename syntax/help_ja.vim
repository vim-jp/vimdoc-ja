scriptencoding utf-8

syn match helpVim "Vim バージョン [0-9.a-z]\+"
syn match helpVim "VIMリファレンス.*"
syn region helpNotVi start="{Vim" start="{|++\?[A-Za-z0-9_/()]\+|" end="}" contains=helpLeadBlank,helpHyperTextJump
syn match helpWarning "\<警告:"
syn region helpTransNote start="{訳注:" end="}" contains=helpLeadBlank,helpHyperTextJump
syn match helpSpecial "[。、]\zs\[[-a-z^A-Z0-9_]\{2,}]"
hi def link helpTransNote Special
