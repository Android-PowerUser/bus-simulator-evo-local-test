.class public Lcom/unity3d/player/UnityPlayerActivity;
.super Landroid/app/Activity;
.source "UnityPlayerActivity.java"

# interfaces
.implements Lcom/unity3d/player/IUnityPlayerLifecycleEvents;


# instance fields
.field protected mUnityPlayer:Lcom/unity3d/player/UnityPlayer;


# direct methods
.method public constructor <init>()V
    .registers 1

    #@0
    .line 15
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V

    #@3
    return-void
.end method


# virtual methods
.method public dispatchKeyEvent(Landroid/view/KeyEvent;)Z
    .registers 4

    #@0
    .line 136
    invoke-virtual {p1}, Landroid/view/KeyEvent;->getAction()I

    #@3
    move-result v0

    #@4
    const/4 v1, 0x2

    #@5
    if-ne v0, v1, :cond_e

    #@7
    .line 137
    iget-object v0, p0, Lcom/unity3d/player/UnityPlayerActivity;->mUnityPlayer:Lcom/unity3d/player/UnityPlayer;

    #@9
    invoke-virtual {v0, p1}, Lcom/unity3d/player/UnityPlayer;->injectEvent(Landroid/view/InputEvent;)Z

    #@c
    move-result p1

    #@d
    return p1

    #@e
    .line 138
    :cond_e
    invoke-super {p0, p1}, Landroid/app/Activity;->dispatchKeyEvent(Landroid/view/KeyEvent;)Z

    #@11
    move-result p1

    #@12
    return p1
.end method

.method public onConfigurationChanged(Landroid/content/res/Configuration;)V
    .registers 3

    #@0
    .line 121
    invoke-super {p0, p1}, Landroid/app/Activity;->onConfigurationChanged(Landroid/content/res/Configuration;)V

    #@3
    .line 122
    iget-object v0, p0, Lcom/unity3d/player/UnityPlayerActivity;->mUnityPlayer:Lcom/unity3d/player/UnityPlayer;

    #@5
    invoke-virtual {v0, p1}, Lcom/unity3d/player/UnityPlayer;->configurationChanged(Landroid/content/res/Configuration;)V

    #@8
    return-void
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .registers 4

    #@0
    const/4 v0, 0x1

    #@1
    .line 34
    invoke-virtual {p0, v0}, Landroid/app/Activity;->requestWindowFeature(I)Z

    #@4
    .line 35
    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    #@7
    .line 37
    invoke-virtual {p0}, Landroid/app/Activity;->getIntent()Landroid/content/Intent;

    #@a
    move-result-object p1

    #@b
    const-string/jumbo v0, "unity"

    #@e
    invoke-virtual {p1, v0}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    #@11
    move-result-object p1

    #@12
    invoke-virtual {p0, p1}, Lcom/unity3d/player/UnityPlayerActivity;->updateUnityCommandLineArguments(Ljava/lang/String;)Ljava/lang/String;

    #@15
    move-result-object p1

    #@16
    .line 38
    invoke-virtual {p0}, Landroid/app/Activity;->getIntent()Landroid/content/Intent;

    #@19
    move-result-object v1

    #@1a
    invoke-virtual {v1, v0, p1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    #@1d
    .line 40
    new-instance p1, Lcom/unity3d/player/UnityPlayer;

    #@1f
    invoke-direct {p1, p0, p0}, Lcom/unity3d/player/UnityPlayer;-><init>(Landroid/content/Context;Lcom/unity3d/player/IUnityPlayerLifecycleEvents;)V

    #@22
    iput-object p1, p0, Lcom/unity3d/player/UnityPlayerActivity;->mUnityPlayer:Lcom/unity3d/player/UnityPlayer;

    #@24
    .line 41
    invoke-virtual {p0, p1}, Landroid/app/Activity;->setContentView(Landroid/view/View;)V

    #@27
    .line 42
    iget-object p1, p0, Lcom/unity3d/player/UnityPlayerActivity;->mUnityPlayer:Lcom/unity3d/player/UnityPlayer;

    #@29
    invoke-virtual {p1}, Landroid/view/View;->requestFocus()Z

    #@2c
    return-void
.end method

.method protected onDestroy()V
    .registers 2

    #@0
    .line 67
    iget-object v0, p0, Lcom/unity3d/player/UnityPlayerActivity;->mUnityPlayer:Lcom/unity3d/player/UnityPlayer;

    #@2
    invoke-virtual {v0}, Lcom/unity3d/player/UnityPlayer;->destroy()V

    #@5
    .line 68
    invoke-super {p0}, Landroid/app/Activity;->onDestroy()V

    #@8
    return-void
.end method

.method public onGenericMotionEvent(Landroid/view/MotionEvent;)Z
    .registers 3

    #@0
    .line 145
    iget-object v0, p0, Lcom/unity3d/player/UnityPlayerActivity;->mUnityPlayer:Lcom/unity3d/player/UnityPlayer;

    #@2
    invoke-virtual {v0, p1}, Lcom/unity3d/player/UnityPlayer;->onGenericMotionEvent(Landroid/view/MotionEvent;)Z

    #@5
    move-result p1

    #@6
    return p1
.end method

.method public onKeyDown(ILandroid/view/KeyEvent;)Z
    .registers 4

    #@0
    .line 143
    iget-object v0, p0, Lcom/unity3d/player/UnityPlayerActivity;->mUnityPlayer:Lcom/unity3d/player/UnityPlayer;

    #@2
    invoke-virtual {v0, p1, p2}, Lcom/unity3d/player/UnityPlayer;->onKeyDown(ILandroid/view/KeyEvent;)Z

    #@5
    move-result p1

    #@6
    return p1
.end method

.method public onKeyUp(ILandroid/view/KeyEvent;)Z
    .registers 4

    #@0
    .line 142
    iget-object v0, p0, Lcom/unity3d/player/UnityPlayerActivity;->mUnityPlayer:Lcom/unity3d/player/UnityPlayer;

    #@2
    invoke-virtual {v0, p1, p2}, Lcom/unity3d/player/UnityPlayer;->onKeyUp(ILandroid/view/KeyEvent;)Z

    #@5
    move-result p1

    #@6
    return p1
.end method

.method public onLowMemory()V
    .registers 2

    #@0
    .line 104
    invoke-super {p0}, Landroid/app/Activity;->onLowMemory()V

    #@3
    .line 105
    iget-object v0, p0, Lcom/unity3d/player/UnityPlayerActivity;->mUnityPlayer:Lcom/unity3d/player/UnityPlayer;

    #@5
    invoke-virtual {v0}, Lcom/unity3d/player/UnityPlayer;->lowMemory()V

    #@8
    return-void
.end method

.method protected onNewIntent(Landroid/content/Intent;)V
    .registers 3

    #@0
    .line 60
    invoke-virtual {p0, p1}, Landroid/app/Activity;->setIntent(Landroid/content/Intent;)V

    #@3
    .line 61
    iget-object v0, p0, Lcom/unity3d/player/UnityPlayerActivity;->mUnityPlayer:Lcom/unity3d/player/UnityPlayer;

    #@5
    invoke-virtual {v0, p1}, Lcom/unity3d/player/UnityPlayer;->newIntent(Landroid/content/Intent;)V

    #@8
    return-void
.end method

.method protected onPause()V
    .registers 2

    #@0
    .line 90
    invoke-super {p0}, Landroid/app/Activity;->onPause()V

    #@3
    .line 91
    iget-object v0, p0, Lcom/unity3d/player/UnityPlayerActivity;->mUnityPlayer:Lcom/unity3d/player/UnityPlayer;

    #@5
    invoke-virtual {v0}, Lcom/unity3d/player/UnityPlayer;->onPause()V

    #@8
    return-void
.end method

.method protected onResume()V
    .registers 2

    #@0
    .line 97
    invoke-super {p0}, Landroid/app/Activity;->onResume()V

    #@3
    .line 98
    iget-object v0, p0, Lcom/unity3d/player/UnityPlayerActivity;->mUnityPlayer:Lcom/unity3d/player/UnityPlayer;

    #@5
    invoke-virtual {v0}, Lcom/unity3d/player/UnityPlayer;->onResume()V

    #@8
    return-void
.end method

.method protected onStart()V
    .registers 2

    #@0
    .line 83
    invoke-super {p0}, Landroid/app/Activity;->onStart()V

    #@3
    .line 84
    iget-object v0, p0, Lcom/unity3d/player/UnityPlayerActivity;->mUnityPlayer:Lcom/unity3d/player/UnityPlayer;

    #@5
    invoke-virtual {v0}, Lcom/unity3d/player/UnityPlayer;->onStart()V

    #@8
    return-void
.end method

.method protected onStop()V
    .registers 2

    #@0
    .line 77
    invoke-super {p0}, Landroid/app/Activity;->onStop()V

    #@3
    .line 78
    iget-object v0, p0, Lcom/unity3d/player/UnityPlayerActivity;->mUnityPlayer:Lcom/unity3d/player/UnityPlayer;

    #@5
    invoke-virtual {v0}, Lcom/unity3d/player/UnityPlayer;->onStop()V

    #@8
    return-void
.end method

.method public onTouchEvent(Landroid/view/MotionEvent;)Z
    .registers 3

    #@0
    .line 144
    iget-object v0, p0, Lcom/unity3d/player/UnityPlayerActivity;->mUnityPlayer:Lcom/unity3d/player/UnityPlayer;

    #@2
    invoke-virtual {v0, p1}, Lcom/unity3d/player/UnityPlayer;->onTouchEvent(Landroid/view/MotionEvent;)Z

    #@5
    move-result p1

    #@6
    return p1
.end method

.method public onTrimMemory(I)V
    .registers 3

    #@0
    .line 111
    invoke-super {p0, p1}, Landroid/app/Activity;->onTrimMemory(I)V

    #@3
    const/16 v0, 0xf

    #@5
    if-ne p1, v0, :cond_c

    #@7
    .line 114
    iget-object p1, p0, Lcom/unity3d/player/UnityPlayerActivity;->mUnityPlayer:Lcom/unity3d/player/UnityPlayer;

    #@9
    invoke-virtual {p1}, Lcom/unity3d/player/UnityPlayer;->lowMemory()V

    #@c
    :cond_c
    return-void
.end method

.method public onUnityPlayerQuitted()V
    .registers 1

    #@0
    .line 0
    return-void
.end method

.method public onUnityPlayerUnloaded()V
    .registers 2

    #@0
    const/4 v0, 0x1

    #@1
    .line 47
    invoke-virtual {p0, v0}, Landroid/app/Activity;->moveTaskToBack(Z)Z

    #@4
    return-void
.end method

.method public onWindowFocusChanged(Z)V
    .registers 3

    #@0
    .line 128
    invoke-super {p0, p1}, Landroid/app/Activity;->onWindowFocusChanged(Z)V

    #@3
    .line 129
    iget-object v0, p0, Lcom/unity3d/player/UnityPlayerActivity;->mUnityPlayer:Lcom/unity3d/player/UnityPlayer;

    #@5
    invoke-virtual {v0, p1}, Lcom/unity3d/player/UnityPlayer;->windowFocusChanged(Z)V

    #@8
    return-void
.end method

.method protected updateUnityCommandLineArguments(Ljava/lang/String;)Ljava/lang/String;
    .registers 2

    #@0
    .line 0
    return-object p1
.end method
