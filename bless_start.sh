#!/bin/bash

# 安装 npm 环境
apt update
apt-get install -y curl sudo
echo -e "2\n2" | sudo apt-get install -y expect
sudo apt install -y git nodejs npm tmux node-cacache node-gyp node-mkdirp node-nopt node-tar node-which

echo "正在从 GitHub 克隆 Bless 仓库..."
git clone https://github.com/sdohuajia/Bless-node.git

cd Bless-node

##生成
one_gene=$(echo -e "1\n1" |node gen.js)
nodeId=$(echo "$one_gene" | awk -F ':' '/publicKey/ {print $2}' | sed 's/,$//' | tr -d '"' | tr -d "'" | sed 's/^ *//')
hardwareId=$(echo "$one_gene" | awk -F ':' '/hardwareID/ {print $2}' | sed 's/,$//' | tr -d '"' | tr -d "'" | sed 's/^ *//')
echo "传入的usertoken：" $usertoken
echo ""
echo "生成新的nodeId:" $nodeId
echo ""
echo "生成新的hardwareId:" $hardwareId

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
    { nodeId: '${nodeId}', hardwareId: '${hardwareId}'},
EOF

# 完成配置文件
cat >> config.js << EOF
    ]
}
];
EOF

# 编写跳过选项脚本
echo '#!/usr/bin/expect
spawn npm start
expect "y/n"
send "n\r"
interact'>run_npm.expect

# # 编写跳过选项脚本
# echo '#!/usr/bin/expect
# # 启动npm start，并通过>&4将其输出重定向到已经关联好的文件描述符4
# spawn bash -c "npm start 2>&1 | tee tmp.txt"
# expect "y/n"
# send "n\r"
# interact'>run_npm.expect

chmod +x run_npm.expect

npm install
./run_npm.expect 2>&1 | tee tmp.txt

# 使用 tmux 自动运行 npm start
# tmux new-session -d -s Bless  # 创建新的 tmux 会话，名称为 Bless
# tmux send-keys -t Bless "cd Bless-node" C-m  # 切换到 Bless node 目录
# tmux send-keys -t Bless "npm install" C-m  # 安装 npm install
# tmux send-keys -t Bless "./run_npm.expect" C-m # 启动 npm start
echo "已经启动成功"
while true; do
  sleep 1000
done
