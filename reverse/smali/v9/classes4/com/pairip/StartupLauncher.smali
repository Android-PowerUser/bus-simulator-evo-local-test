.class public final Lcom/pairip/StartupLauncher;
.super Ljava/lang/Object;
.source "StartupLauncher.java"


# static fields
.field private static launchCalled:Z = false

.field private static startupProgramName:Ljava/lang/String; = "ERzS3xEHg1Vs5U4O"


# direct methods
.method static constructor <clinit>()V
    .registers 0

    #@0
    return-void
.end method

.method private constructor <init>()V
    .registers 1

    #@0
    .line 17
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    #@3
    return-void
.end method

.method public static declared-synchronized launch()V
    .registers 3

    #@0
    const-class v0, Lcom/pairip/StartupLauncher;

    #@2
    monitor-enter v0

    #@3
    .line 10
    :try_start_3
    sget-boolean v1, Lcom/pairip/StartupLauncher;->launchCalled:Z
    :try_end_5
    .catchall {:try_start_3 .. :try_end_5} :catchall_16

    #@5
    if-eqz v1, :cond_9

    #@7
    .line 11
    monitor-exit v0

    #@8
    goto :goto_13

    #@9
    :cond_9
    const/4 v1, 0x1

    #@a
    .line 13
    :try_start_a
    sput-boolean v1, Lcom/pairip/StartupLauncher;->launchCalled:Z

    #@c
    .line 14
    sget-object v1, Lcom/pairip/StartupLauncher;->startupProgramName:Ljava/lang/String;

    #@e
    const/4 v2, 0x0

    #@f
    invoke-static {v1, v2}, Lcom/pairip/VMRunner;->invoke(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_12
    .catchall {:try_start_a .. :try_end_12} :catchall_16

    #@12
    .line 15
    monitor-exit v0

    #@13
    :goto_13
    return-void

    #@14
    :goto_14
    :try_start_14
    monitor-exit v0
    :try_end_15
    .catchall {:try_start_14 .. :try_end_15} :catchall_16

    #@15
    throw v1

    #@16
    :catchall_16
    move-exception v1

    #@17
    goto :goto_14
.end method
