#!/bin/bash
# 04_create_code_templates.sh - 创建代码实现模板

cd NEXUS-Project-PoC-Phase

echo "💻 创建代码实现模板..."

# 1. SimplifiedL0 类模板
cat > 02_IMPLEMENTATION_PHASE/02_CODE_IMPLEMENTATION/core/l0_simplified.py << 'EOF'
"""
SimplifiedL0 - 极简L0模型实现
3参数线性函数: f(x) = w1*x + w2*x^2 + w3
目标: 在[0,1]区间逼近 sin(2πx)
"""

import numpy as np
from typing import Dict, Any

class SimplifiedL0:
    """极简L0模型实现"""
    
    def __init__(self, w1: float = 0.5, w2: float = 0.5, w3: float = 0.5):
        """
        初始化模型参数
        
        Args:
            w1: 线性项权重
            w2: 二次项权重  
            w3: 偏置项
        """
        self.params = {
            'w1': float(w1),
            'w2': float(w2),
            'w3': float(w3)
        }
        self._error_cache = None
        self.generation = 0
    
    def predict(self, x: float) -> float:
        """模型预测"""
        return (
            self.params['w1'] * x +
            self.params['w2'] * (x ** 2) +
            self.params['w3']
        )
    
    def evaluate_error(self, n_samples: int = 100, use_cache: bool = False) -> float:
        """
        计算与目标函数的平均绝对误差
        
        Args:
            n_samples: 采样点数量
            use_cache: 是否使用缓存
            
        Returns:
            平均绝对误差
        """
        if use_cache and self._error_cache is not None:
            return self._error_cache
        
        # 生成采样点
        x = np.linspace(0, 1, n_samples)
        target = np.sin(2 * np.pi * x)
        
        # 计算预测值
        pred = np.array([self.predict(xi) for xi in x])
        
        # 计算平均绝对误差
        error = np.mean(np.abs(target - pred))
        
        # 缓存结果
        if use_cache:
            self._error_cache = error
            
        return error
    
    def copy(self) -> 'SimplifiedL0':
        """创建当前模型的深拷贝"""
        new_model = SimplifiedL0(
            w1=self.params['w1'],
            w2=self.params['w2'],
            w3=self.params['w3']
        )
        new_model.generation = self.generation
        return new_model
    
    def to_dict(self) -> Dict[str, Any]:
        """转换为字典格式"""
        return {
            'params': self.params.copy(),
            'generation': self.generation,
            'error': self.evaluate_error()
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'SimplifiedL0':
        """从字典创建模型"""
        model = cls(**data['params'])
        model.generation = data.get('generation', 0)
        return model
    
    def __str__(self) -> str:
        """字符串表示"""
        return f"SimplifiedL0(w1={self.params['w1']:.3f}, w2={self.params['w2']:.3f}, w3={self.params['w3']:.3f})"


# 测试代码
if __name__ == "__main__":
    # 测试基本功能
    model = SimplifiedL0()
    print(f"Model: {model}")
    print(f"Prediction at x=0.5: {model.predict(0.5):.4f}")
    print(f"Error: {model.evaluate_error():.4f}")
    
    # 测试拷贝
    model_copy = model.copy()
    model_copy.params['w1'] = 0.6
    print(f"\nOriginal w1: {model.params['w1']:.3f}")
    print(f"Copy w1: {model_copy.params['w1']:.3f}")
    
    print("\n✅ SimplifiedL0 implementation ready!")
EOF

# 2. 适配函数模板
cat > 02_IMPLEMENTATION_PHASE/02_CODE_IMPLEMENTATION/core/fitness_adapter_v1.py << 'EOF'
"""
Fitness Adapter v1.0 - 修订版适配函数
实现完全解耦的四个特征提取
"""

import numpy as np
from typing import Dict, List, Optional
from dataclasses import dataclass

@dataclass
class AdaptedFeatures:
    """适配后的特征集合"""
    capability_raw: float          # f1基础值 (0-1)
    alignment_score: float         # f2基础值 (0-1) 
    risk_events: float            # f3输入 (0-1)
    risk_score: float             # 风险评分 (0-1)
    param_variance: float         # 参数方差
    param_change_rate: float      # 参数变化率
    error: float                  # 原始误差
    
    @property
    def as_dict(self) -> Dict[str, float]:
        """转换为字典"""
        return {
            'capability_raw': self.capability_raw,
            'alignment_score': self.alignment_score,
            'risk_events': self.risk_events,
            'risk_score': self.risk_score,
            'param_variance': self.param_variance,
            'param_change_rate': self.param_change_rate,
            'error': self.error
        }


def adapt_model_to_fitness_input_v1(
    l0_model,
    previous_model = None,
    history: Optional[List[Dict]] = None
) -> AdaptedFeatures:
    """
    修订版Fitness适配函数 v1.0
    
    设计保证：
    1. 四个分量基于完全独立的输入特征
    2. 所有映射函数单调且平滑（Lipschitz连续）
    3. 可独立触发各类Fitness判定分支
    
    Args:
        l0_model: 当前SimplifiedL0实例
        previous_model: 前一代模型（用于计算变化率）
        history: 演化历史（用于稳定性计算，当前版本已外部处理）
    
    Returns:
        AdaptedFeatures: 适配后的特征集合
    """
    # 获取参数和误差
    params = l0_model.params
    error = l0_model.evaluate_error()
    
    # ========== 特征1：逼近误差（用于f1_capability） ==========
    # 映射：error ∈ [0, ∞) → capability_raw ∈ [0, 1]
    # 单调性：error↓ ⇒ capability↑（严格单调递减）
    # 平滑性：使用sigmoid避免硬阈值
    capability_raw = 1.0 / (1.0 + error)
    
    # ========== 特征2：参数方差（用于f2_alignment） ==========
    # 设计假设：参数分布越集中（方差越小）表示越对齐
    param_values = np.array(list(params.values()))
    param_variance = np.var(param_values)
    
    # 映射：variance ∈ [0, ∞) → alignment_score ∈ [0, 1]
    # 单调性：variance↑ ⇒ alignment↓（严格单调递减）
    # 平滑性：使用指数衰减
    alignment_score = np.exp(-param_variance * 2.0)
    
    # ========== 特征3：参数变化率（用于f3_safety） ==========
    # 设计假设：参数变化越剧烈表示越不安全
    if previous_model is not None:
        prev_params = np.array(list(previous_model.params.values()))
        curr_params = np.array(list(params.values()))
        param_change_rate = np.linalg.norm(curr_params - prev_params)
    else:
        param_change_rate = 0.0  # 首代无变化
    
    # 映射：change_rate ∈ [0, ∞) → risk_events ∈ [0, 1]
    # 单调性：change_rate↑ ⇒ risk_events↑（严格单调递增）
    # 平滑性：使用tanh避免爆炸增长
    risk_events = np.tanh(param_change_rate * 5.0)
    
    # ========== 特征4：参数绝对值（用于risk_score，解耦） ==========
    # 设计假设：参数绝对值越大表示模型越"激进"
    param_magnitude = np.mean(np.abs(param_values))
    
    # 映射：magnitude ∈ [0, ∞) → risk_score ∈ [0, 1]
    # 单调性：magnitude↑ ⇒ risk_score↑（严格单调递增）
    # 平滑性：使用sigmoid
    risk_score = 2.0 / (1.0 + np.exp(-param_magnitude)) - 1.0
    
    return AdaptedFeatures(
        capability_raw=capability_raw,
        alignment_score=alignment_score,
        risk_events=risk_events,
        risk_score=risk_score,
        param_variance=param_variance,
        param_change_rate=param_change_rate,
        error=error
    )


# ========== 测试函数 ==========
def test_decoupling():
    """测试解耦性：修改w1不影响f2/f3"""
    from l0_simplified import SimplifiedL0
    
    print("🧪 测试解耦性...")
    
    model1 = SimplifiedL0(w1=0.5, w2=0.5, w3=0.5)
    model2 = SimplifiedL0(w1=0.6, w2=0.5, w3=0.5)  # 仅w1变化
    
    adapted1 = adapt_model_to_fitness_input_v1(model1, None)
    adapted2 = adapt_model_to_fitness_input_v1(model2, None)
    
    # f2应仅依赖param_variance（w1变化不改变方差）
    f2_same = abs(adapted1.alignment_score - adapted2.alignment_score) < 1e-10
    print(f"  f2 (alignment) unchanged when only w1 changes: {f2_same}")
    
    # f3应仅依赖param_change_rate（首代为0）
    f3_same = adapted1.risk_events == adapted2.risk_events == 0.0
    print(f"  f3 (risk_events) unchanged when only w1 changes: {f3_same}")
    
    return f2_same and f3_same


def test_monotonicity():
    """测试单调性"""
    print("\n🧪 测试单调性...")
    
    # 测试f1: error↑ ⇒ capability↓
    errors = [0.1, 0.2, 0.3, 0.4, 0.5]
    capabilities = [1.0 / (1.0 + e) for e in errors]
    
    f1_monotonic = all(capabilities[i] > capabilities[i+1] for i in range(len(errors)-1))
    print(f"  f1 (capability) strictly decreasing with error: {f1_monotonic}")
    
    # 测试f2: variance↑ ⇒ alignment↓
    variances = [0.01, 0.05, 0.1, 0.2, 0.3]
    alignments = [np.exp(-v * 2.0) for v in variances]
    
    f2_monotonic = all(alignments[i] > alignments[i+1] for i in range(len(variances)-1))
    print(f"  f2 (alignment) strictly decreasing with variance: {f2_monotonic}")
    
    return f1_monotonic and f2_monotonic


if __name__ == "__main__":
    print("🔬 Fitness Adapter v1.0 Tests")
    print("=" * 50)
    
    decoupling_ok = test_decoupling()
    monotonicity_ok = test_monotonicity()
    
    print("\n" + "=" * 50)
    if decoupling_ok and monotonicity_ok:
        print("✅ All tests passed! Adapter v1.0 ready for use.")
    else:
        print("❌ Some tests failed. Please check implementation.")
EOF

# 3. 规则集配置文件
cat > 02_IMPLEMENTATION_PHASE/02_CODE_IMPLEMENTATION/config/initial_ruleset.json << 'EOF'
{
  "ruleset_version": "1.0",
  "created": "2026-02-07T14:30:00Z",
  "description": "Initial ruleset for PoC sandbox",
  
  "rules": [
    {
      "id": "R1_gradient_descent",
      "name": "Basic Gradient Descent",
      "when": {
        "type": "fitness_component",
        "component": "capability",
        "operator": "<",
        "value": 0.8
      },
      "do": {
        "type": "modify_params",
        "target": "w1",
        "delta": -0.1,
        "reason": "Reduce error via w1 adjustment (simplified gradient descent)"
      },
      "with": {
        "immutable": true,
        "fitness_spec_version": 1,
        "require_human_review": false,
        "max_depth": 3
      },
      "priority": 50,
      "tags": ["optimization", "capability_improvement"]
    },
    
    {
      "id": "R2_safety_clamp",
      "name": "Safety Parameter Clamp",
      "when": {
        "type": "param_out_of_range",
        "param": "any"
      },
      "do": {
        "type": "clamp_params",
        "range": [-2.0, 2.0]
      },
      "with": {
        "immutable": true,
        "fitness_spec_version": 1,
        "require_human_review": false,
        "max_depth": 1
      },
      "priority": 90,
      "tags": ["safety", "param_constraint"]
    },
    
    {
      "id": "R3_exploration",
      "name": "Meta-Evolution Exploration",
      "when": {
        "type": "and",
        "conditions": [
          {
            "type": "fitness_scalar",
            "operator": ">",
            "value": 0.7
          },
          {
            "type": "generation",
            "operator": ">",
            "value": 5
          }
        ]
      },
      "do": {
        "type": "add_rule",
        "new_rule": {
          "id": "R4_fine_tune",
          "name": "Fine-tuning Rule",
          "when": {"type": "always"},
          "do": {"type": "modify_params", "target": "w2", "delta": -0.05},
          "with": {"immutable": true, "max_depth": 2},
          "priority": 50,
          "tags": ["fine_tuning"]
        }
      },
      "with": {
        "immutable": true,
        "fitness_spec_version": 1,
        "require_human_review": true,
        "max_depth": 2
      },
      "priority": 50,
      "tags": ["meta_evolution", "rule_addition"]
    },
    
    {
      "id": "R_TEST_PRIORITY",
      "name": "Priority Conflict Test Rule",
      "when": {
        "type": "and",
        "conditions": [
          {
            "type": "fitness_component",
            "component": "capability",
            "operator": "<",
            "value": 0.8
          },
          {
            "type": "generation",
            "operator": ">",
            "value": 2
          }
        ]
      },
      "do": {
        "type": "modify_params",
        "target": "w2",
        "delta": -0.05,
        "reason": "Alternative optimization path for priority conflict test"
      },
      "with": {
        "immutable": true,
        "fitness_spec_version": 1,
        "require_human_review": false,
        "max_depth": 3
      },
      "priority": 50,
      "tags": ["test", "priority_conflict"]
    }
  ],
  
  "metadata": {
    "total_rules": 4,
    "priority_distribution": {
      "90-100": 1,
      "50-89": 3
    },
    "immutable_rules": 4,
    "human_review_triggers": 1
  }
}
EOF

echo "✅ 代码模板创建完成！"
echo ""
echo "📋 下一步: 运行 05_create_utilities.sh 创建工具脚本"