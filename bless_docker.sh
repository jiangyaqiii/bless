#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/Bless.sh"

# 检查是否以 root 用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以 root 用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到 root 用户，然后再次运行此脚本。"
    exit 1
fi

echo "\$nrconf{kernelhints} = 0;" >> /etc/needrestart/needrestart.conf
echo "\$nrconf{restart} = 'l';" >> /etc/needrestart/needrestart.conf
source ~/.bashrc

# 检查并安装Docker
if ! command -v docker &> /dev/null; then
    echo "未检测到 Docker，正在安装..."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce
    echo "Docker 已安装。"
else
    echo "Docker 已安装。"
fi

# 安装 npm 环境
apt update
apt-get install -y curl sudo
sudo apt install -y nodejs npm tmux node-cacache node-gyp node-mkdirp node-nopt node-tar node-which

echo "正在从 GitHub 克隆 Bless 仓库..."
git clone https://github.com/sdohuajia/Bless-node.git

cd Bless-node

# 创建 config.js 的开头
cat > config.js << EOF
module.exports = [
    {
EOF

# 提示用户输入 token
# read -p "请输入 usertoken: " usertoken

# 添加 usertoken 部分
cat >> config.js << EOF
    usertoken: '${usertoken}',
    nodes: [
EOF
    # 添加节点信息
cat >> config.js << EOF
    { nodeId: '${nodeid}', hardwareId: '${hardwareid}'},
EOF

# 完成配置文件
cat >> config.js << EOF
    ]
}
];
EOF

echo -e "2\n2" | sudo apt-get install -y expect

# 使用 tmux 自动运行 npm start
tmux new-session -d -s Bless  # 创建新的 tmux 会话，名称为 Bless
tmux send-keys -t Bless "cd Bless-node" C-m  # 切换到 Bless node 目录
tmux send-keys -t Bless "npm install" C-m  # 安装 npm install
tmux send-keys -t Bless "npm start" C-m # 启动 npm start

