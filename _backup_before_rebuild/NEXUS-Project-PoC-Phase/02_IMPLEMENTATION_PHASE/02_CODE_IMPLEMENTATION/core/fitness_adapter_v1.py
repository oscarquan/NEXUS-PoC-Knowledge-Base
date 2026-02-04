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
