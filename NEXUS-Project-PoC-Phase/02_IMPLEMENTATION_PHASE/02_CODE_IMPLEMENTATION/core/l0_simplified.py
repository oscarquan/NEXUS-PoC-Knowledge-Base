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
