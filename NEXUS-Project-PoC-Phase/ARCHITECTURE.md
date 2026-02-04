# NEXUS 项目知识库架构

## 设计原则
1. **极致结构化** - 所有信息按预定结构组织
2. **可追溯性** - 每个决策可追溯到原始对话
3. **连续性保证** - 状态可在5秒内重建
4. **知识传承** - 支持无缝工具升级和角色切换

## 目录结构说明

### 00_PROJECT_META/ - 项目元数据
- `project_manifest.yaml` - 项目基础信息
- `team_roster.json` - 团队成员与能力映射
- `protocol_v2.0.md` - 多智能体协作协议
- `decision_log.md` - 关键决策记录

### 01_DESIGN_PHASE/ - 设计阶段产出
- `v0.1_concept_framework/` - 初始概念框架
- `role_alignment/` - 角色能力评估
- `design_reviews/` - 设计审阅记录

### 02_IMPLEMENTATION_PHASE/ - 实施阶段（当前）
- `TIMELINE.yaml` - 24小时时间线
- `01_C_EXECUTION_PLAN/` - C的实施计划
- `02_CODE_IMPLEMENTATION/` - 实际代码实现
- `03_MONITORING_AND_COORDINATION/` - 进度监控
- `04_EXPECTED_OUTPUTS/` - 预期产出模板
- `05_KNOWLEDGE_TRANSFER/` - 知识传递

### 03_KNOWLEDGE_GRAPH/ - 知识图谱
- `entities/` - 实体定义（概念、角色、产物）
- `relationships/` - 实体间关系
- `queries/` - 知识查询
- `visualizations/` - 可视化输出

### 04_UTILITIES/ - 工具脚本
- 连续性检查、报告生成、知识提取等工具

### 05_ARCHIVE/ - 原始存档
- 原始对话、处理后的知识块、元数据

## 文件命名规范
- 配置文件：`.yaml` 或 `.json`
- 文档：`.md`
- 代码：`.py`
- 数据：按格式 `.json`, `.csv`, `.yaml`
- 时间戳格式：`YYYYMMDD_HHMMSS`

## 版本控制
- 每次重大变更创建tag
- 关键决策点创建分支
- 每日自动创建连续性快照
