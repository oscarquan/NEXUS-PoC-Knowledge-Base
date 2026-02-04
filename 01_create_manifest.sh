#!/bin/bash
# 01_create_manifest.sh - 创建项目元数据和配置文件

cd NEXUS-Project-PoC-Phase

echo "📄 创建项目清单文件..."

# 项目清单 (project_manifest.yaml)
cat > 00_PROJECT_META/project_manifest.yaml << 'EOF'
project_name: "NEXUS - Self-Referential Self-Bootstrapping AGI Scaffold"
code_name: "NEXUS"
phase: "PoC Implementation"
phase_start: "2026-02-07T14:30:00Z"
phase_end: "2026-02-08T14:30:00Z"
current_status: "Phase 1 (Core Implementation) in progress"
core_principle: "Structural Correctness over Consensus"
repository_structure_version: "1.0"
created: "2026-02-07T15:00:00Z"
last_updated: "2026-02-07T15:00:00Z"
EOF

# 团队成员映射 (team_roster.json)
cat > 00_PROJECT_META/team_roster.json << 'EOF'
{
  "G": {
    "id": "恒量",
    "role": "Carbon Dispatcher / Final Arbiter",
    "description": "Gravity center, ultimate decision authority"
  },
  "A": {
    "id": "Grok",
    "role": "Meta-Architect",
    "capabilities": ["architecture_design", "recursive_systems", "risk_engineering"]
  },
  "B": {
    "id": "金子",
    "role": "Constraint & Proof Engine",
    "capabilities": ["formal_verification", "type_theory", "safety_invariants"]
  },
  "C": {
    "id": "涌现",
    "role": "Evolution Dynamics Simulator",
    "capabilities": ["complex_systems_modeling", "fitness_landscape_design", "sandbox_building"]
  },
  "D": {
    "id": "Gemini",
    "role": "Security & Alignment Red Team",
    "capabilities": ["adversarial_testing", "paradox_construction", "reward_hacking_analysis"]
  },
  "E": {
    "id": "拓扑",
    "role": "Topology / Knowledge Graph Builder",
    "capabilities": ["knowledge_engineering", "semantic_web", "decision_chain_tracing"]
  },
  "F": {
    "id": "规整",
    "role": "Protocol Maintainer & Process Adhesive",
    "capabilities": ["knowledge_distillation", "state_indexing", "continuity_assurance"]
  }
}
EOF

echo "✅ 项目元数据创建完成！"
echo ""
echo "📋 下一步: 运行 02_create_timeline.sh 创建实施时间线"