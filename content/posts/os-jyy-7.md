---
title: "操作系统-jyy-7"
date: 2022-07-16T18:01:22+08:00
draft: false
toc: true
---

# 第七讲 并发控制 互斥

## 自旋锁
前提：cpu提供原子的cmpxchg指令
```c
typedef struct {
  ...
} lock_t;
void spin_lock(lock_t *lk);  // 可以有多组 can_go
void spin_unlock(lock_t *lk);


void spin_lock(lock_t *lk) {
retry:
    if (!atomic_cmpxchg(&lk->status, ✅, ❌)) {
        goto retry;
    }
}

void spin_unlock(lock_t *lk) {
    lk->status = ✅;
    __sync_synchronize();
}
```

## 互斥锁
把锁的实现放到操作系统里
- syscall(SYSCALL_lock,&lk); 试图获得lk，如果失败，就切换到其他线程
- syscall(SYSCALL_unlock,&lk);释放lk，如果有等待锁的线程，就唤醒它

剩下的复杂工作都交给内核：

关中断 + 自旋
自旋锁只用来保护操作系统中非常短的代码块
成功获得锁 → 返回
获得失败 → 设置线程为 “不可执行” 并切换


## 优化
Futex: Fast Userspace muTexes
小孩子才做选择。操作系统当然是全都要啦！
性能优化的最常见技巧：优化 fast path
- Fast Path: 自旋一次
一条原子指令，成功直接进入临界区
- Slow Path: 自旋失败
请求系统调用 futex_wait
请操作系统帮我达到自旋的效果
(实际上并不真的自旋)