---
title: "Android dev tips"
date: 2022-02-11T18:37:54+08:00
draft: false
---



 切换fragment

menu中动态添加item

为item动态绑定点击行为

```
//    private void replaceFragment(Fragment fragment){
//        FragmentManager fragmentManager= getActivity().getSupportFragmentManager();
//        FragmentTransaction transaction=fragmentManager.beginTransaction();
//        transaction.replace(R.id.framelayout_needtoReplace,fragment);
//        transaction.commit();
//
//    }


//上下文是fragment
//    @Override
//    public void onPrepareOptionsMenu(@NonNull @NotNull Menu menu) {
//        super.onPrepareOptionsMenu(menu);
//        menu.clear();
//
//        for(int i=0;i< CommonVar.num_of_tag;i++){
//            menu.add(0,i,1," "+i);
//
//        }
//    }


//上下文是fragment
//    @Override
//    public boolean onOptionsItemSelected(MenuItem item) {//点击事件
//        int i=item.getItemId();
//        Log.e("itemid"," "+i);
//        mWebView.loadUrl(CommonUrl.url.get(i));
//        return  true;}

  //toolbar =(Toolbar) getActivity().findViewById(R.id.toolbar);
       // ((AppCompatActivity) getActivity()).setSupportActionBar(toolbar);
        //setHasOptionsMenu(true);
        
        
// 点击后退按钮,让WebView后退一页(也可以覆写Activity的onKeyDown方法)
//        mWebView.setOnKeyListener(new View.OnKeyListener() {
//            @Override
//            public boolean onKey(View v, int keyCode, KeyEvent event) {
//                if (event.getAction() == KeyEvent.ACTION_DOWN) {
//                    if (keyCode == KeyEvent.KEYCODE_BACK && mWebView.canGoBack()) { // 表示按返回键
//                        // 时的操作
//                        mWebView.goBack(); // 后退
//                        // webview.goForward();//前进
//                        return true; // 已处理
//                    }
//                }
//                return false;
//            }
//        });
```

