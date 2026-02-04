#!/bin/bash
# 00_init_repository.sh - 初始化NEXUS知识库基础结构

echo "🚀 开始初始化NEXUS项目知识库..."

# 创建根目录
mkdir -p NEXUS-Project-PoC-Phase
cd NEXUS-Project-PoC-Phase

# 创建顶级目录结构
mkdir -p {00_PROJECT_META,01_DESIGN_PHASE/{v0.1_concept_framework,role_alignment,design_reviews},02_IMPLEMENTATION_PHASE/{01_C_EXECUTION_PLAN,02_CODE_IMPLEMENTATION/{core,config,tests,core/common},03_MONITORING_AND_COORDINATION/{G_coordination_emails,progress_reports},04_EXPECTED_OUTPUTS,05_KNOWLEDGE_TRANSFER},03_KNOWLEDGE_GRAPH/{entities/{concepts,roles,artifacts/{documents,code_modules,decisions}},relationships,queries,visualizations},04_UTILITIES/templates,05_ARCHIVE/{raw_conversations,processed/{conversation_chunks,annotated},metadata}}

# 创建基础文件
touch README.md ARCHITECTURE.md CHANGELOG.md

echo "✅ 基础目录结构创建完成！"
echo "📁 路径: $(pwd)"
echo ""
echo "📋 下一步: 运行 01_create_manifest.sh 创建项目元数据"