.class public Lcom/safedk/android/SafeDKApplication;
.super Landroid/app/Application;
.source "SourceFile"


# static fields
.field public static context:Landroid/content/Context;

.field public static final mHandler:Landroid/os/Handler;


# direct methods
.method public static constructor <clinit>()V
    .registers 1

    #@0
    invoke-static {}, Lcom/pairip/StartupLauncher;->launch()V

    #@3
    .line 15
    new-instance v0, Landroid/os/Handler;

    #@5
    invoke-direct {v0}, Landroid/os/Handler;-><init>()V

    #@8
    sput-object v0, Lcom/safedk/android/SafeDKApplication;->mHandler:Landroid/os/Handler;

    #@a
    return-void
.end method

.method public constructor <init>()V
    .registers 1

    #@0
    .line 10
    invoke-direct {p0}, Landroid/app/Application;-><init>()V

    #@3
    return-void
.end method

.method public static getAppContext()Landroid/content/Context;
    .registers 1

    #@0
    .line 36
    sget-object v0, Lcom/safedk/android/SafeDKApplication;->context:Landroid/content/Context;

    #@2
    return-object v0
.end method

.method public static synthetic getApplicationContext$002(Lcom/safedk/android/SafeDKApplication;)Landroid/content/Context;
    .registers 2

    #@0
    invoke-virtual/range {p0 .. p0}, Lcom/safedk/android/SafeDKApplication;->getApplicationContext()Landroid/content/Context;

    #@3
    move-result-object v0

    #@4
    return-object v0
.end method

.method public static synthetic getApplicationContext$003(Lcom/safedk/android/SafeDKApplication;)Landroid/content/Context;
    .registers 2

    #@0
    invoke-virtual/range {p0 .. p0}, Lcom/safedk/android/SafeDKApplication;->getApplicationContext()Landroid/content/Context;

    #@3
    move-result-object v0

    #@4
    return-object v0
.end method

.method public static synthetic onCreate$001(Landroid/app/Application;)V
    .registers 2

    #@0
    invoke-super/range {p0 .. p0}, Landroid/app/Application;->onCreate()V

    #@3
    return-void
.end method

.method public static runOnUiThread(Ljava/lang/Runnable;)V
    .registers 5
    .param p0, "runnable"    # Ljava/lang/Runnable;

    #@0
    .line 41
    const-string v0, "SafeDKApplication"

    #@2
    const/4 v1, 0x1

    #@3
    new-array v1, v1, [Ljava/lang/Object;

    #@5
    const-string v2, "runOnUiThread started"

    #@7
    const/4 v3, 0x0

    #@8
    aput-object v2, v1, v3

    #@a
    invoke-static {v0, v1}, Lcom/safedk/android/utils/Logger;->d(Ljava/lang/String;[Ljava/lang/Object;)I

    #@d
    .line 42
    invoke-static {}, Ljava/lang/Thread;->currentThread()Ljava/lang/Thread;

    #@10
    move-result-object v0

    #@11
    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    #@14
    move-result-object v1

    #@15
    invoke-virtual {v1}, Landroid/os/Looper;->getThread()Ljava/lang/Thread;

    #@18
    move-result-object v1

    #@19
    if-ne v0, v1, :cond_1f

    #@1b
    .line 44
    invoke-interface {p0}, Ljava/lang/Runnable;->run()V

    #@1e
    goto :goto_24

    #@1f
    .line 48
    :cond_1f
    sget-object v0, Lcom/safedk/android/SafeDKApplication;->mHandler:Landroid/os/Handler;

    #@21
    invoke-virtual {v0, p0}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    #@24
    .line 50
    :goto_24
    return-void
.end method


# virtual methods
.method public onCreate()V
    .registers 7

    #@0
    const v2, 0x1

    #@3
    new-array v1, v2, [Ljava/lang/Object;

    #@5
    const v2, 0x0

    #@8
    aput-object p0, v1, v2

    #@a
    sget-object v0, Lcom/google/android/gms/ads/appopen/Gd/lplwsKKkSF;->fNwUrD:Ljava/lang/reflect/Method;

    #@c
    const/4 v3, 0x0

    #@d
    invoke-virtual {v0, v3, v1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    #@10
    move-result-object v0

    #@11
    return-void
.end method
