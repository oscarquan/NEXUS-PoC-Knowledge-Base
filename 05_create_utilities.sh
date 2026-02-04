#!/bin/bash
# 05_create_utilities.sh - 创建辅助工具和脚本（简化版）

cd NEXUS-Project-PoC-Phase

echo "🛠️ 创建辅助工具和脚本..."

# 1. 创建一个简化的连续性检查器
cat > 04_UTILITIES/continuity_checker.py << 'EOF'
#!/usr/bin/env python3
"""
连续性检查器 - 基础版本
"""

import os
import json
from pathlib import Path

def main():
    print("🔍 NEXUS 项目连续性检查")
    print("=" * 50)
    
    base_path = Path(".")
    
    # 检查核心目录
    required_dirs = [
        "00_PROJECT_META",
        "02_IMPLEMENTATION_PHASE",
        "04_UTILITIES"
    ]
    
    for dir_name in required_dirs:
        if (base_path / dir_name).exists():
            print(f"✅ {dir_name}/")
        else:
            print(f"❌ {dir_name}/ (缺失)")
    
    # 检查核心文件
    required_files = [
        "00_PROJECT_META/project_manifest.yaml",
        "00_PROJECT_META/team_roster.json",
        "02_IMPLEMENTATION_PHASE/TIMELINE.yaml",
        "README.md"
    ]
    
    print("\n📄 检查核心文件:")
    for file_path in required_files:
        if (base_path / file_path).exists():
            print(f"✅ {file_path}")
        else:
            print(f"❌ {file_path} (缺失)")
    
    print("\n" + "=" * 50)
    print("检查完成！")

if __name__ == "__main__":
    main()
EOF

chmod +x 04_UTILITIES/continuity_checker.py

# 2. 创建进度报告模板
cat > 04_UTILITIES/templates/progress_report_template.md << 'EOF'
# 进度报告模板

## 基本信息
- **报告ID**: [自动生成]
- **报告时间**: [YYYY-MM-DD HH:MM UTC]
- **报告者**: [角色ID]
- **当前阶段**: [Phase X]

## 进度概览
- **阶段名称**: [Phase 名称]
- **进度百分比**: [0-100]%
- **状态**: [进行中/已完成/延迟/阻塞]

## 已完成工作
1. [任务1描述]
2. [任务2描述]
3. [任务3描述]

## 遇到问题
- [问题1描述]
- [问题2描述]

## 下一步计划
1. [计划1]
2. [计划2]

## 风险与预警
- 风险等级: [绿色/黄色/红色]
- 预警: [无/有]

## 请求支持
- [如需支持请说明]

---
*报告生成时间: [时间戳]*
EOF

# 3. 创建简单的归档脚本
cat > 04_UTILITIES/archive_conversation.sh << 'EOF'
#!/bin/bash
# 归档对话脚本

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_DIR="05_ARCHIVE/raw_conversations"

echo "📚 归档对话内容..."
echo "时间戳: $TIMESTAMP"

# 创建归档文件
ARCHIVE_FILE="$ARCHIVE_DIR/conversation_$TIMESTAMP.txt"

cat > "$ARCHIVE_FILE" << CONTENT
# 对话归档 - $TIMESTAMP
# NEXUS 项目 PoC 实施阶段

## 元数据
- 归档时间: $(date)
- 项目阶段: PoC Implementation
- 当前Phase: Phase 1 (Core Component Implementation)

## 对话内容
[在此粘贴对话内容]

## 关键决策点
1. [决策1]
2. [决策2]

## 状态摘要
- 整体状态: [正常/预警]
- 下一步: [下一步行动]
CONTENT

echo "✅ 归档文件已创建: $ARCHIVE_FILE"
echo "请将对话内容粘贴到文件中。"
EOF

chmod +x 04_UTILITIES/archive_conversation.sh

# 4. 创建GitHub Actions工作流
mkdir -p .github/workflows

cat > .github/workflows/continuity.yml << 'EOF'
name: 连续性保障

on:
  schedule:
    - cron: '0 */6 * * *'  # 每6小时运行一次
  workflow_dispatch:       # 手动触发

jobs:
  snapshot:
    runs-on: ubuntu-latest
    
    steps:
      - name: 检出代码
        uses: actions/checkout@v3
        
      - name: 运行连续性检查
        run: |
          python 04_UTILITIES/continuity_checker.py
          
      - name: 创建快照
        run: |
          TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
          echo "创建快照: $TIMESTAMP"
          
          # 检查目录结构
          find . -type f -name "*.yaml" -o -name "*.json" -o -name "*.md" | head -20 > snapshot_$TIMESTAMP.txt
          
          echo "✅ 快照创建完成"
          
      - name: 提交更新
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add .
          git commit -m "Auto: 连续性快照 $(date +'%Y-%m-%d %H:%M')" || echo "没有变化"
          git push
EOF

# 5. 创建安装脚本
cat > setup_all.sh << 'EOF'
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
EOF

chmod +x setup_all.sh

echo ""
echo "✅ 工具脚本创建完成！"
echo ""
echo "📋 您现在已经完成了所有基础脚本。"
echo ""
echo "🎯 下一步建议："
echo "1. 运行 ./setup_all.sh 重新从头安装所有内容"
echo "2. 或者直接进入 NEXUS-Project-PoC-Phase/ 目录查看"
echo "3. 使用 git 初始化并推送到您的仓库"
echo ""
echo "🔗 您的仓库: https://github.com/oscarquan/2026"