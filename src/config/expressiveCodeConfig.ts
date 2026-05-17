import type { ExpressiveCodeConfig } from "../types/config";

/**
 * expressive-code配置
 * @see https://expressive-code.com/
 * 修改本配置后需要重启Astro开发服务器才能生效
 */

export const expressiveCodeConfig: ExpressiveCodeConfig = {
	// 暗色主题（用于暗色模式）
	darkTheme: "github-dark",

	// 亮色主题（用于亮色模式）
	lightTheme: "github-light",

	// 更多样式请看expressive-code的官方文档
	// https://expressive-code.com/guides/themes/

	// 代码块折叠插件配置
	pluginCollapsible: {
		enable: false,
		lineThreshold: 15,
		previewLines: 8,
		defaultCollapsed: true,
	},

	// 语言徽章插件配置
	pluginLanguageBadge: {
		// 是否启用语言徽章插件
		enable: false,
	},
};
