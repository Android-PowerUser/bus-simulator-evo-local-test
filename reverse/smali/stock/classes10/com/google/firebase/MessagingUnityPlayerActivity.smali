.class public Lcom/google/firebase/MessagingUnityPlayerActivity;
.super Lcom/unity3d/player/UnityPlayerActivity;
.source "MessagingUnityPlayerActivity.java"


# static fields
.field public static final EXTRA_FROM:Ljava/lang/String; = "google.message_id"

.field public static final EXTRA_MESSAGE_ID_KEY:Ljava/lang/String; = "google.message_id"

.field public static final EXTRA_MESSAGE_ID_KEY_SERVER:Ljava/lang/String; = "message_id"


# direct methods
.method public constructor <init>()V
    .registers 1

    #@0
    .line 21
    invoke-direct {p0}, Lcom/unity3d/player/UnityPlayerActivity;-><init>()V

    #@3
    return-void
.end method

.method public static synthetic onCreate$002(Lcom/unity3d/player/UnityPlayerActivity;Landroid/os/Bundle;)V
    .registers 3

    #@0
    invoke-super/range {p0 .. p1}, Lcom/unity3d/player/UnityPlayerActivity;->onCreate(Landroid/os/Bundle;)V

    #@3
    return-void
.end method

.method public static synthetic quit$001(Lcom/unity3d/player/UnityPlayer;)V
    .registers 2

    #@0
    invoke-virtual/range {p0 .. p0}, Lcom/unity3d/player/UnityPlayer;->quit()V

    #@3
    return-void
.end method


# virtual methods
.method public dispatchTouchEvent(Landroid/view/MotionEvent;)Z
    .registers 3
    .param p1, "me"    # Landroid/view/MotionEvent;

    #@0
    const-string v0, "com.google.firebase.messaging"

    #@2
    invoke-static {p0, v0, p1}, Lcom/safedk/android/analytics/brandsafety/DetectTouchUtils;->activityOnTouch(Landroid/app/Activity;Ljava/lang/String;Landroid/view/MotionEvent;)V

    #@5
    invoke-super {p0, p1}, Lcom/unity3d/player/UnityPlayerActivity;->dispatchTouchEvent(Landroid/view/MotionEvent;)Z

    #@8
    move-result v0

    #@9
    return v0
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .registers 8

    #@0
    const v2, 0x2

    #@3
    new-array v1, v2, [Ljava/lang/Object;

    #@5
    const v2, 0x0

    #@8
    aput-object p0, v1, v2

    #@a
    const v2, 0x1

    #@d
    aput-object p1, v1, v2

    #@f
    sget-object v0, Lio/bidmachine/media3/exoplayer/offline/cB/YGASMcfGjKN;->WovVaIdNF:Ljava/lang/reflect/Method;

    #@11
    const/4 v3, 0x0

    #@12
    invoke-virtual {v0, v3, v1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    #@15
    move-result-object v0

    #@16
    return-void
.end method

.method protected onNewIntent(Landroid/content/Intent;)V
    .registers 5

    #@0
    .line 46
    invoke-super {p0, p1}, Lcom/unity3d/player/UnityPlayerActivity;->onNewIntent(Landroid/content/Intent;)V

    #@3
    .line 50
    invoke-virtual {p1}, Landroid/content/Intent;->getExtras()Landroid/os/Bundle;

    #@6
    move-result-object v0

    #@7
    if-nez v0, :cond_a

    #@9
    return-void

    #@a
    :cond_a
    const-string v1, "google.message_id"

    #@c
    .line 54
    invoke-virtual {v0, v1}, Landroid/os/BaseBundle;->getString(Ljava/lang/String;)Ljava/lang/String;

    #@f
    move-result-object v2

    #@10
    .line 55
    invoke-virtual {v0, v1}, Landroid/os/BaseBundle;->getString(Ljava/lang/String;)Ljava/lang/String;

    #@13
    move-result-object v1

    #@14
    if-nez v1, :cond_1c

    #@16
    const-string v1, "message_id"

    #@18
    .line 57
    invoke-virtual {v0, v1}, Landroid/os/BaseBundle;->getString(Ljava/lang/String;)Ljava/lang/String;

    #@1b
    move-result-object v1

    #@1c
    :cond_1c
    if-eqz v2, :cond_39

    #@1e
    if-eqz v1, :cond_39

    #@20
    .line 60
    new-instance v0, Landroid/content/Intent;

    #@22
    const-class v1, Lcom/google/firebase/messaging/MessageForwardingService;

    #@24
    invoke-direct {v0, p0, v1}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    #@27
    const-string v1, "com.google.android.c2dm.intent.RECEIVE"

    #@29
    .line 61
    invoke-virtual {v0, v1}, Landroid/content/Intent;->setAction(Ljava/lang/String;)Landroid/content/Intent;

    #@2c
    .line 62
    invoke-virtual {v0, p1}, Landroid/content/Intent;->putExtras(Landroid/content/Intent;)Landroid/content/Intent;

    #@2f
    .line 63
    invoke-virtual {p1}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    #@32
    move-result-object v1

    #@33
    invoke-virtual {v0, v1}, Landroid/content/Intent;->setData(Landroid/net/Uri;)Landroid/content/Intent;

    #@36
    .line 64
    invoke-static {p0, v0}, Lcom/google/firebase/messaging/MessageForwardingService;->enqueueWork(Landroid/content/Context;Landroid/content/Intent;)V

    #@39
    .line 66
    :cond_39
    invoke-virtual {p0, p1}, Landroid/app/Activity;->setIntent(Landroid/content/Intent;)V

    #@3c
    return-void
.end method
