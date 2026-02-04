#!/bin/bash
# 一键安装所有脚本

echo "🔧 NEXUS 知识库完整安装"
echo "=" * 50

# 检查是否在正确目录
if [ ! -f "00_init_repository.sh" ]; then
    echo "❌ 请在包含所有脚本的目录中运行此命令"
    exit 1
fi

# 执行所有脚本
SCRIPTS=(
    "00_init_repository.sh"
    "01_create_manifest.sh"
    "02_create_timeline.sh"
    "03_create_core_files.sh"
    "04_create_code_templates.sh"
    "05_create_utilities.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        echo ""
        echo "🚀 执行: $script"
        echo "-" * 40
        bash "$script"
        if [ $? -eq 0 ]; then
            echo "✅ $script 完成"
        else
            echo "❌ $script 执行失败"
            exit 1
        fi
    else
        echo "⚠️  跳过: $script (未找到)"
    fi
done

echo ""
echo "=" * 50
echo "🎉 NEXUS 知识库安装完成！"
echo ""
echo "📁 结构已创建在: NEXUS-Project-PoC-Phase/"
echo ""
echo "📋 后续步骤:"
echo "1. cd NEXUS-Project-PoC-Phase"
echo "2. git init"
echo "3. git add ."
echo "4. git commit -m 'Initial NEXUS知识库结构'"
echo "5. git remote add origin https://github.com/oscarquan/2026.git"
echo "6. git push -u origin main"
