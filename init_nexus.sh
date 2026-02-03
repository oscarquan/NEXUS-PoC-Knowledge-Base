#!/bin/bash

echo "🚀 初始化NEXUS知识库项目..."

# 创建标准目录结构
mkdir -p \
  .github/workflows \
  .github/ISSUE_TEMPLATE \
  docs/architecture \
  docs/decisions \
  src/core \
  src/knowledge \
  src/agents \
  tests/unit \
  tests/integration \
  data/samples \
  scripts

# 创建核心文档
cat > README.md << 'DOC'
# NEXUS PoC Knowledge Base

## 项目概述
多智能体联合设计的知识系统概念验证

## 核心概念
- 知识图谱构建
- 多智能体协作
- AI工程设计流程

## 快速开始
\`\`\`bash
git clone https://github.com/oscarquan/NEXUS-PoC-Knowledge-Base.git
cd NEXUS-PoC-Knowledge-Base
python -m pip install -r requirements.txt
\`\`\`

## AI协作标记
- [AI-generated] AI生成的代码
- [AI-assisted] AI辅助修改
- [human-reviewed] 人工审核通过
DOC

# 创建AI协作文档
cat > CONTRIBUTING.md << 'DOC'
# NEXUS知识库协作指南

## AI协作流程
1. AI生成代码 → 标记 [AI-generated]
2. 人工审查 → 标记 [human-reviewed]
3. 通过PR合并

## 分支规范
- \`feature/\` 新功能
- \`knowledge/\` 知识节点
- \`ai/\` AI生成内容
- \`docs/\` 文档更新

## 质量要求
- 所有AI代码必须人工审查
- 重要决策需要文档记录
- 知识节点需要测试验证
DOC

# 创建PR模板
cat > .github/pull_request_template.md << 'DOC'
## 知识库变更类型
- [ ] 新增知识节点
- [ ] 知识关联更新
- [ ] AI智能体功能
- [ ] 系统架构调整
- [ ] 文档完善

## AI协作说明
- [ ] 包含AI生成内容 [AI-generated]
- [ ] 已人工审核 [human-reviewed]
- [ ] 知识关联已验证
- [ ] 测试已通过

## 变更描述

## 知识影响分析

## 相关Issue
Closes #
DOC

# 创建AI友好的CI工作流
cat > .github/workflows/ai-knowledge-ci.yml << 'YAML'
name: NEXUS Knowledge CI

on:
  push:
    branches: [ main, develop, knowledge/** ]
  pull_request:
    branches: [ main ]

jobs:
  knowledge-validation:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Validate structure
      run: |
        echo "🔍 验证知识库结构..."
        [ -f "README.md" ] && echo "✓ README.md" || echo "✗ README.md missing"
        [ -d "docs/decisions" ] && echo "✓ 决策文档目录" || echo "✗ 决策文档缺失"
        [ -d "src/knowledge" ] && echo "✓ 知识节点目录" || echo "✗ 知识节点目录缺失"
        
    - name: Check AI markers
      if: github.event_name == 'pull_request'
      run: |
        echo "🤖 检查AI生成内容..."
        PR_TITLE="${{ github.event.pull_request.title }}"
        if echo "$PR_TITLE" | grep -q "\[AI-generated\]"; then
          echo "⚠️ AI-GENERATED CONTENT DETECTED"
          echo "::warning::This PR contains AI-generated knowledge nodes. Human review required!"
          echo ""
          echo "📋 知识审查清单:"
          echo "1. ✅ 验证知识准确性"
          echo "2. ✅ 检查关联合理性"
          echo "3. ✅ 确认无矛盾信息"
          echo "4. ✅ 更新相关文档"
        fi

  documentation-check:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Check documentation links
      run: |
        echo "📚 检查文档完整性..."
        find docs -name "*.md" | while read file; do
          echo "检查: $file"
          if grep -q "TODO\|FIXME" "$file"; then
            echo "⚠️  发现待完成项: $file"
          fi
        done
YAML

# 创建知识节点模板
cat > docs/knowledge-node-template.md << 'DOC'
# 知识节点: [节点名称]

## 基本信息
- 创建时间: 
- 创建者: 
- 最后更新: 
- 状态: [草案|审核中|已确认|已弃用]

## 核心定义
[简要描述知识节点]

## 关联节点
- 父节点: 
- 子节点: 
- 相关节点: 

## 证据/来源
1. 
2. 

## 变更历史
| 时间 | 变更内容 | 变更者 |
|------|----------|--------|
|      |          |        |

## AI协作标记
[AI-generated] / [AI-assisted] / [human-reviewed]
DOC

# 创建决策记录模板
cat > docs/decisions/decision-template.md << 'DOC'
# 决策记录: [决策标题]

## 状态
[提议|已接受|已拒绝|已替代]

## 决策背景
[为什么需要这个决策]

## 考虑方案
### 方案A
- 优点:
- 缺点:

### 方案B
- 优点:
- 缺点:

## 决策结果
选择方案: [X]
理由: [详细说明]

## 影响评估
- 对知识库的影响:
- 对智能体的影响:
- 对架构的影响:

## 相关链接
- Issues: #
- PRs: #
- 知识节点: #

## 审查记录
| 审查者 | 意见 | 时间 |
|--------|------|------|
|        |      |      |
DOC

echo "✅ NEXUS知识库初始化完成！"
echo "📁 目录结构已创建"
echo "📄 核心文档已准备"
echo "🤖 AI协作流程已配置"
