# Firefly 项目指南

> 一款基于 Astro 框架的清新美观静态博客主题模板

## 项目概述

Firefly 是一款现代化的个人博客主题，基于 Astro 6.x + Tailwind CSS 4.x + Svelte 5.x 构建。项目从 [fuwari](https://github.com/saicaca/fuwari) 模板二次开发而来，增加了左右双侧边栏、文章网格布局、瀑布流布局等创新功能。

**版本**: 6.10.3  
**包管理器**: pnpm 9.x  
**Node.js 要求**: ≥ 22

## 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Astro | 6.3.1 | 静态站点生成框架 |
| Tailwind CSS | 4.2.4 | 原子化 CSS 框架 |
| Svelte | 5.55.5 | 交互组件 |
| TypeScript | 5.9.2 | 类型安全 |
| Biome | 2.4.14 | 代码格式化和检查 |
| Pagefind | 1.5.2 | 客户端全文搜索 |

## 项目结构

```
Firefly/
├── src/
│   ├── assets/images/       # 需优化的图片资源
│   ├── components/          # UI 组件
│   │   ├── analytics/       # 统计分析组件
│   │   ├── comment/         # 评论系统组件
│   │   ├── common/          # 通用组件
│   │   ├── controls/        # 控制面板组件
│   │   ├── features/        # 功能特性组件
│   │   ├── layout/          # 布局组件
│   │   ├── misc/            # 杂项组件
│   │   ├── pages/           # 页面组件
│   │   └── widget/          # 侧边栏小组件
│   ├── config/              # 配置文件目录
│   ├── constants/           # 常量定义
│   ├── content/
│   │   ├── posts/           # 博客文章 (Markdown/MDX)
│   │   └── spec/            # 特殊页面内容
│   ├── i18n/                # 国际化翻译
│   ├── layouts/             # 页面布局模板
│   ├── pages/               # 路由页面
│   ├── plugins/             # Markdown/Rehype 插件
│   ├── styles/              # 全局样式
│   ├── types/               # TypeScript 类型定义
│   └── utils/               # 工具函数
├── public/                  # 静态资源
│   ├── assets/              # CSS/JS/音乐等资源
│   ├── favicon/             # 网站图标
│   ├── gallery/             # 相册图片
│   └── pio/                 # 看板娘模型
└── scripts/                 # 构建脚本
```

## 常用命令

```bash
# 开发
pnpm dev                    # 启动开发服务器 (localhost:4321)
pnpm start                  # 同 pnpm dev

# 构建
pnpm build                  # 构建网站 (含图标生成 + Pagefind 索引)
pnpm preview                # 预览构建结果

# 代码质量
pnpm check                  # Astro 类型检查
pnpm type-check             # TypeScript 类型检查
pnpm format                 # Biome 格式化代码
pnpm lint                   # Biome 检查并修复

# 内容
pnpm new-post <filename>    # 创建新文章

# 工具
pnpm icons                  # 生成图标
pnpm astro ...              # 执行 Astro CLI 命令
```

## 配置系统

所有配置文件位于 `src/config/` 目录，通过 `src/config/index.ts` 统一导出。

### 核心配置文件

| 文件 | 说明 |
|------|------|
| `siteConfig.ts` | 站点基础配置（标题、URL、语言、主题色等） |
| `sidebarConfig.ts` | 侧边栏布局配置（单/双侧边栏、组件列表） |
| `navBarConfig.ts` | 导航栏配置（Logo、菜单链接） |
| `profileConfig.ts` | 用户资料配置 |
| `backgroundWallpaper.ts` | 背景壁纸配置（横幅/全屏/覆盖模式） |

### 功能配置文件

| 文件 | 说明 |
|------|------|
| `commentConfig.ts` | 评论系统（支持 Twikoo/Waline/Giscus/Disqus/Artalk） |
| `musicConfig.ts` | 音乐播放器（Meting API 或本地模式） |
| `friendsConfig.ts` | 友链配置 |
| `galleryConfig.ts` | 相册配置 |
| `sponsorConfig.ts` | 赞助页面配置 |
| `announcementConfig.ts` | 公告配置 |
| `adConfig.ts` | 广告配置 |

### 样式配置文件

| 文件 | 说明 |
|------|------|
| `fontConfig.ts` | 字体配置（支持自定义字体加载） |
| `expressiveCodeConfig.ts` | 代码高亮配置（双主题、折叠、语言徽章） |
| `effectsConfig.ts` | 动画特效配置（樱花飘落） |
| `coverImageConfig.ts` | 文章封面图配置 |

## 内容管理

### 文章 Frontmatter

```yaml
---
title: 文章标题
published: 2024-01-01
description: 文章描述
image: ./cover.jpg        # 封面图路径或 "api" 启用随机封面
tags: [标签1, 标签2]
category: 分类名称
draft: false              # 草稿状态
lang: zh-CN               # 文章语言（与站点不同时设置）
pinned: false             # 是否置顶
comment: true             # 是否启用评论
password: ""              # 文章密码（非空时加密）
passwordHint: ""          # 密码提示
---
```

### 国际化支持

支持语言：`zh_CN`（简体中文）、`zh_TW`（繁体中文）、`en`（英文）、`ja`（日文）、`ru`（俄文）

语言配置位于 `src/config/siteConfig.ts` 的 `SITE_LANG` 常量。

## Markdown 扩展

- **提醒块 (Admonitions)**: 支持 GitHub/Obsidian/VitePress 三种风格
- **GitHub 卡片**: 自动渲染仓库卡片
- **数学公式**: KaTeX 支持（含 mhchem 化学公式扩展）
- **图表**: Mermaid 和 PlantUML 支持
- **代码块**: Expressive Code 增强（折叠、行号、语言徽章）
- **图片网格**: 多图网格布局语法

## 路径别名

```typescript
@components/*  → src/components/*
@assets/*      → src/assets/*
@constants/*   → src/constants/*
@utils/*       → src/utils/*
@i18n/*        → src/i18n/*
@layouts/*     → src/layouts/*
@/*            → src/*
```

## 代码规范

- **格式化**: Biome，使用 Tab 缩进
- **引号**: 双引号
- **导入排序**: 自动组织导入
- **Svelte/Astro 文件**: 部分 lint 规则禁用（const、未使用变量等）

## 构建优化

- **图像优化**: 支持 WebP/AVIF 格式转换，质量可配置
- **CSS 代码分割**: 启用 `cssCodeSplit`
- **代码压缩**: esbuild 压缩，移除 console.log 和 debugger
- **资源内联阈值**: 4KB 以下资源内联
- **页面过渡**: Swup 动画库实现流畅页面切换

## 部署

项目支持 Vercel、Netlify、Cloudflare Pages 等平台部署。

**构建命令**: `pnpm build`  
**输出目录**: `dist`  
**框架预设**: Astro

## 开发注意事项

1. 使用 pnpm 作为包管理器（项目配置了 preinstall 钩子强制使用）
2. 修改配置后需重启开发服务器
3. `src/constants/icons.ts` 被 Biome 忽略（自动生成文件）
4. 图片优化会增加构建时间，建议本地调试时关闭 `generateOgImages`
5. Bangumi 数据在 dev 模式下只获取一页，build 时获取全部
