function fish_prompt
    set -l dir (basename (pwd))
    set -l short_dir

    # 特殊專案處理
    switch $dir
        case "vscode-remote-try-python"
            set short_dir "vs-try-py"
        case "*"
            # 通用智慧縮寫
            set -l caps (string match -r -a '[A-Z]' $dir)
            if test -n "$caps"
                set short_dir (string join '' $caps)
            else
                set -l words (string split -r -m2 '-' $dir)
                set short_dir (string join '' (for word in $words; string sub -l1 $word; end))
            end
    end

    echo -n (set_color blue)"~/$short_dir"' '
    # 修復箭頭：改用您手機的符號
    echo -n (set_color red)'❯'(set_color yellow)'❯'(set_color green)'❯ '
    set_color normal
end
