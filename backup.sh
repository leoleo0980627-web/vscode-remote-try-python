cat > setup.sh << 'EOF'
#!/bin/bash
echo "🐟 完整環境設置腳本"
echo "===================="

# 更新套件列表
echo "🔄 更新套件列表..."
sudo apt update

# 克隆 git_pan
echo "📁 克隆個人倉庫..."
git clone https://github.com/leoleo0980627-web/git_pan /workspaces/git_pan_local || true

# 基礎安裝列表（只保留你指定的）
base_packages="fish chafa tty-clock netris"

# 檢查記憶檔案中的額外套件
APT_HISTORY="/workspaces/apt_history.txt"
extra_packages=""
if [ -f "$APT_HISTORY" ]; then
    echo "📚 檢測到歷史安裝記錄..."
    while IFS= read -r line; do
        if [[ "$line" =~ sudo\ apt\ install\ -y\ (.*) ]]; then
            extra_packages="$extra_packages ${BASH_REMATCH[1]}"
        fi
    done < "$APT_HISTORY"
fi

# 合併所有套件，去除重複
all_packages=$(echo "$base_packages $extra_packages" | tr ' ' '\n' | sort -u | tr '\n' ' ')
total_packages=$(echo "$all_packages" | wc -w)

echo "📦 總共安裝 $total_packages 個套件"
echo "🔧 套件列表: $all_packages"
echo ""
echo "⏳ 開始並行安裝..."
sudo apt install -y $all_packages
echo "✅ 所有套件安裝完成！"

# 設置記憶系統
echo "📦 設置 Apt 記憶系統..."
cat > /workspaces/apt_memory.sh << 'MEMEOF'
#!/bin/bash
APT_HISTORY="/workspaces/apt_history.txt"
touch "$APT_HISTORY"
echo "📦 Apt 記憶系統已就緒"
echo "💾 歷史記錄位置: $APT_HISTORY"
MEMEOF
chmod +x /workspaces/apt_memory.sh

# Fish 配置（包含自動記錄和主題）
echo "🐟 設置 Fish Shell..."
mkdir -p ~/.config/fish
cat > ~/.config/fish/config.fish << 'FISHCONFIG'
function apt
    if contains install \$argv[1]
        command apt \$argv
        if test \$status -eq 0
            set -l packages (string join " " \$argv[2..-1])
            echo "sudo apt install -y \$packages" >> /workspaces/apt_history.txt
            echo "📦 已記錄: \$packages"
        end
    else
        command apt \$argv
    end
end

function fish_prompt
    if test -n "$SSH_TTY"
        echo -n (set_color brred)"$USER"(set_color white)'@'(set_color yellow)(prompt_hostname)' '
    end
    echo -n (set_color blue)(prompt_pwd)' '
    set_color -o
    if fish_is_root_user
        echo -n (set_color red)'# '
    end
    echo -n (set_color red)'❯'(set_color yellow)'❯'(set_color green)'❯ '
    set_color normal
end
FISHCONFIG

# 設置 Fish 為預設 shell
chsh -s /usr/bin/fish

echo "🎉 環境設置完成！"
sleep 1
clear
exec fish
EOF

chmod +x setup.sh
./setup.sh
