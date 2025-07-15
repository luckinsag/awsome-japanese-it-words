#!/bin/bash

# IT Words Learning 项目启动脚本

echo "🚀 正在启动 IT Words Learning 项目..."
echo "======================================"

# 检查是否在正确目录
if [ ! -d "itwordslearning_api" ] || [ ! -d "IT-wordslearing_display3.0 2" ]; then
    echo "❌ 错误: 请在项目根目录运行此脚本"
    exit 1
fi

# 检查Java环境
if ! command -v java &> /dev/null; then
    echo "❌ 错误: 未找到Java环境，请先安装Java 17+"
    exit 1
fi

# 检查Node.js环境
if ! command -v node &> /dev/null; then
    echo "❌ 错误: 未找到Node.js环境，请先安装Node.js"
    exit 1
fi

# 检查MySQL是否运行
if ! pgrep -f "mysqld" > /dev/null; then
    echo "⚠️  警告: MySQL服务可能未运行，请确保MySQL已启动"
    echo "   可以使用以下命令启动MySQL:"
    echo "   brew services start mysql"
    echo "   或 sudo systemctl start mysql"
    echo ""
fi

# 启动后端服务
echo "🔧 启动Spring Boot后端服务..."
cd itwordslearning_api
./mvnw spring-boot:run &
BACKEND_PID=$!
echo "   后端服务启动中... (PID: $BACKEND_PID)"
cd ..

# 等待后端启动
echo "⏳ 等待后端服务启动 (10秒)..."
sleep 10

# 启动前端服务
echo "🎨 启动Vue.js前端服务..."
cd "IT-wordslearing_display3.0 2"
npm run dev &
FRONTEND_PID=$!
echo "   前端服务启动中... (PID: $FRONTEND_PID)"
cd ..

echo ""
echo "✅ 项目启动完成!"
echo "======================================"
echo "📍 访问地址:"
echo "   前端: http://localhost:5173"
echo "   后端: http://localhost:8080"
echo ""
echo "🛑 停止服务:"
echo "   按 Ctrl+C 停止此脚本"
echo "   或者使用: kill $BACKEND_PID $FRONTEND_PID"
echo ""

# 等待用户中断
trap "echo '正在停止服务...'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit" INT

# 保持脚本运行
wait 