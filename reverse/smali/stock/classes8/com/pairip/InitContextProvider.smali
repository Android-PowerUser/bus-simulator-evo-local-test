.class final Lcom/pairip/InitContextProvider;
.super Ljava/lang/Object;
.source "InitContextProvider.java"


# direct methods
.method private constructor <init>()V
    .registers 1

    #@0
    .line 78
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    #@3
    return-void
.end method

.method static tryToCreateContextForBindingApp()Landroid/content/Context;
    .registers 12

    #@0
    const/4 v0, 0x0

    #@1
    .line 20
    :try_start_1
    const-string v1, "android.app.LoadedApk"

    #@3
    invoke-static {v1}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    #@6
    move-result-object v1

    #@7
    .line 22
    const-string v2, "android.app.ActivityThread"

    #@9
    invoke-static {v2}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    #@c
    move-result-object v2

    #@d
    .line 23
    const-string v3, "currentActivityThread"

    #@f
    const/4 v4, 0x0

    #@10
    new-array v5, v4, [Ljava/lang/Class;

    #@12
    invoke-virtual {v2, v3, v0}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    #@15
    move-result-object v3

    #@16
    .line 24
    const-string v5, "mBoundApplication"

    #@18
    invoke-virtual {v2, v5}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    #@1b
    move-result-object v5

    #@1c
    const/4 v6, 0x1

    #@1d
    .line 25
    invoke-virtual {v5, v6}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    #@20
    .line 27
    const-string v7, "android.app.ActivityThread$AppBindData"

    #@22
    invoke-static {v7}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    #@25
    move-result-object v7

    #@26
    .line 28
    const-string v8, "info"

    #@28
    invoke-virtual {v7, v8}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    #@2b
    move-result-object v7

    #@2c
    .line 29
    invoke-virtual {v7, v6}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    #@2f
    .line 31
    const-string v8, "android.app.ContextImpl"

    #@31
    invoke-static {v8}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    #@34
    move-result-object v8

    #@35
    .line 32
    const-string v9, "createAppContext"

    #@37
    const/4 v10, 0x2

    #@38
    new-array v11, v10, [Ljava/lang/Class;

    #@3a
    aput-object v2, v11, v4

    #@3c
    aput-object v1, v11, v6

    #@3e
    .line 33
    invoke-virtual {v8, v9, v11}, Ljava/lang/Class;->getDeclaredMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    #@41
    move-result-object v1

    #@42
    .line 35
    invoke-virtual {v1, v6}, Ljava/lang/reflect/Method;->setAccessible(Z)V

    #@45
    .line 37
    invoke-virtual {v3, v0, v0}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    #@48
    move-result-object v3

    #@49
    .line 38
    invoke-virtual {v5, v3}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    #@4c
    move-result-object v5

    #@4d
    .line 39
    invoke-virtual {v7, v5}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    #@50
    move-result-object v5

    #@51
    .line 40
    new-array v7, v10, [Ljava/lang/Object;

    #@53
    aput-object v3, v7, v4

    #@55
    aput-object v5, v7, v6

    #@57
    invoke-virtual {v1, v0, v7}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    #@5a
    move-result-object v1

    #@5b
    .line 42
    invoke-static {v2, v3}, Lcom/pairip/InitContextProvider;->tryToInitializeBasicInstrumentationForStartActivity(Ljava/lang/Class;Ljava/lang/Object;)V

    #@5e
    .line 44
    check-cast v1, Landroid/content/Context;
    :try_end_60
    .catch Ljava/lang/ClassNotFoundException; {:try_start_1 .. :try_end_60} :catch_61
    .catch Ljava/lang/IllegalAccessException; {:try_start_1 .. :try_end_60} :catch_61
    .catch Ljava/lang/reflect/InvocationTargetException; {:try_start_1 .. :try_end_60} :catch_61
    .catch Ljava/lang/NoSuchMethodException; {:try_start_1 .. :try_end_60} :catch_61
    .catch Ljava/lang/NoSuchFieldException; {:try_start_1 .. :try_end_60} :catch_61
    .catch Ljava/lang/RuntimeException; {:try_start_1 .. :try_end_60} :catch_61

    #@60
    move-object v0, v1

    #@61
    :catch_61
    return-object v0
.end method

.method private static tryToInitializeBasicInstrumentationForStartActivity(Ljava/lang/Class;Ljava/lang/Object;)V
    .registers 4
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0
        }
        names = {
            "activityThreadClass",
            "activityThread"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/Class<",
            "*>;",
            "Ljava/lang/Object;",
            ")V"
        }
    .end annotation

    #@0
    .line 61
    :try_start_0
    const-string v0, "mInstrumentation"

    #@2
    invoke-virtual {p0, v0}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    #@5
    move-result-object p0

    #@6
    const/4 v0, 0x1

    #@7
    .line 62
    invoke-virtual {p0, v0}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    #@a
    .line 64
    const-string v0, "android.app.Instrumentation"

    #@c
    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    #@f
    move-result-object v0

    #@10
    const/4 v1, 0x0

    #@11
    .line 65
    new-array v1, v1, [Ljava/lang/Class;

    #@13
    const/4 v1, 0x0

    #@14
    invoke-virtual {v0, v1}, Ljava/lang/Class;->getDeclaredConstructor([Ljava/lang/Class;)Ljava/lang/reflect/Constructor;

    #@17
    move-result-object v0

    #@18
    invoke-virtual {v0, v1}, Ljava/lang/reflect/Constructor;->newInstance([Ljava/lang/Object;)Ljava/lang/Object;

    #@1b
    move-result-object v0

    #@1c
    .line 66
    invoke-virtual {p0, p1, v0}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V
    :try_end_1f
    .catch Ljava/lang/ClassNotFoundException; {:try_start_0 .. :try_end_1f} :catch_1f
    .catch Ljava/lang/IllegalAccessException; {:try_start_0 .. :try_end_1f} :catch_1f
    .catch Ljava/lang/InstantiationException; {:try_start_0 .. :try_end_1f} :catch_1f
    .catch Ljava/lang/reflect/InvocationTargetException; {:try_start_0 .. :try_end_1f} :catch_1f
    .catch Ljava/lang/NoSuchFieldException; {:try_start_0 .. :try_end_1f} :catch_1f
    .catch Ljava/lang/NoSuchMethodException; {:try_start_0 .. :try_end_1f} :catch_1f
    .catch Ljava/lang/RuntimeException; {:try_start_0 .. :try_end_1f} :catch_1f

    #@1f
    :catch_1f
    return-void
.end method
