---
title: "hugo update"
date: 2023-05-27T15:00:00+08:00
draft: false
---
这几天每天邮箱都会收到Github Actions执行错误的邮件：
>[BachWV/BachWV.github.io] Deploy Hugo workflow run
>Deploy Hugo: All jobs have failed

点开一看

```
Run hugo
Start building sites … 
hugo v0.112.0-0a95d6704a8ac8d41cc5ca8fffaad8c5c7a3754a linux/amd64 BuildDate=2023-05-23T08:14:20Z VendorInfo=gohugoio
ERROR 2023/05/23 23:17:26 render of "page" failed: "/home/runner/work/BachWV.github.io/BachWV.github.io/themes/hugo-theme-tokiwa/layouts/_default/single.html:19:4": execute of template failed: template: _default/single.html:19:4: executing "aside" at <partial "page-aside.html" .>: error calling partial: "/home/runner/work/BachWV.github.io/BachWV.github.io/themes/hugo-theme-tokiwa/layouts/partials/page-aside.html:3:4": execute of template failed: template: partials/page-aside.html:3:4: executing "partials/page-aside.html" at <partial "social-follow.html" .>: error calling partial: "/home/runner/work/BachWV.github.io/BachWV.github.io/themes/hugo-theme-tokiwa/layouts/partials/social-follow.html:10:6": execute of template failed: template: partials/social-follow.html:10:6: executing "partials/social-follow.html" at <partial (printf "%s%s%s" "svg/" $key "-line.svg") .>: error calling partial: partial "svg/_merge-line.svg" not found
```

新版本0.112.0不知道升级了什么东西，这是啥错？

把hugo下载到本地，发现同样的错误，可以定位是hugo升级带来的不兼容问题了。

定位bug文件

partials/social-follow.html

```html
	{{ range $key,$value:=.Site.Social }}
	<a href='{{$value}}' target="_blank" class="{{- $key}} icon pl-1 text-eucalyptus-400 hover:text-java-400" title="{{- $key}} link" rel="noopener"
		aria-label="follow on {{$key}}——Opens in a new window">
		{{/*  <object type="image/svg+xml" data='{{ relURL (printf "%s%s%s" "svg/" $key ".svg") }}' class="w-12 h-12
		text-gray-200"></object> */}}
		<div class="fill-current h-8 w-8">
			{{ partial (printf "%s%s%s" "svg/" $key "-line.svg") . }}
		</div>
	</a>
	{{ end }}
```

看了仓库的issue，没人提。问题在哪？

找了半天，找到112的更新日志

https://gohugo.io/content-management/multilingual/#changes-in-hugo-01120

提到了配置文件config.toml映射的变化

所以把第一行的`	{{ range $key,$value:=.Site.Social }}`改成`	{{ range $key,$value:=.Site.Params.Social }}`就好啦
