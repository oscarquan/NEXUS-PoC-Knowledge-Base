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
