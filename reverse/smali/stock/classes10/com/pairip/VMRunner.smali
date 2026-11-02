.class public Lcom/pairip/VMRunner;
.super Ljava/lang/Object;
.source "VMRunner.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/pairip/VMRunner$VMRunnerException;
    }
.end annotation


# static fields
.field private static final PACKAGE_MANAGER_TRIES:I = 0x5

.field private static final TAG:Ljava/lang/String; = "VMRunner"

.field private static apkPath:Ljava/lang/String; = null

.field private static context:Landroid/content/Context; = null

.field private static job:Ljava/util/concurrent/Future; = null
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/concurrent/Future<",
            "*>;"
        }
    .end annotation
.end field

.field private static loggingEnabled:Ljava/lang/String; = "false"

.field private static versionCode:I = 0xf2


# direct methods
.method static constructor <clinit>()V
    .registers 1

    #@0
    .line 33
    const-string v0, "pairipcore"

    #@2
    invoke-static {v0}, Ljava/lang/System;->loadLibrary(Ljava/lang/String;)V

    #@5
    return-void
.end method

.method private constructor <init>()V
    .registers 1

    #@0
    .line 246
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    #@3
    return-void
.end method

.method public static createInvokeRunnable(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Runnable;
    .registers 3
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0
        }
        names = {
            "vmByteCodeFile",
            "args"
        }
    .end annotation

    #@0
    .line 85
    new-instance v0, Lcom/pairip/VMRunner$1;

    #@2
    invoke-direct {v0, p0, p1}, Lcom/pairip/VMRunner$1;-><init>(Ljava/lang/String;[Ljava/lang/Object;)V

    #@5
    return-object v0
.end method

.method public static native executeVM([B[Ljava/lang/Object;)Ljava/lang/Object;
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0
        }
        names = {
            "vmCode",
            "args"
        }
    .end annotation
.end method

.method private static getApkFromContextPath()Ljava/util/zip/ZipFile;
    .registers 5

    #@0
    .line 154
    sget-object v0, Lcom/pairip/VMRunner;->context:Landroid/content/Context;

    #@2
    const/4 v1, 0x0

    #@3
    if-eqz v0, :cond_3e

    #@5
    const/4 v0, 0x0

    #@6
    const/4 v2, 0x0

    #@7
    :goto_7
    const/4 v3, 0x5

    #@8
    if-ge v2, v3, :cond_3e

    #@a
    .line 160
    :try_start_a
    sget-object v1, Lcom/pairip/VMRunner;->context:Landroid/content/Context;

    #@c
    .line 161
    invoke-virtual {v1}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    #@f
    move-result-object v1

    #@10
    sget-object v3, Lcom/pairip/VMRunner;->context:Landroid/content/Context;

    #@12
    invoke-virtual {v3}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    #@15
    move-result-object v3

    #@16
    invoke-virtual {v1, v3, v0}, Landroid/content/pm/PackageManager;->getApplicationInfo(Ljava/lang/String;I)Landroid/content/pm/ApplicationInfo;

    #@19
    move-result-object v1

    #@1a
    iget-object v1, v1, Landroid/content/pm/ApplicationInfo;->sourceDir:Ljava/lang/String;

    #@1c
    .line 162
    invoke-static {v1}, Lcom/pairip/VMRunner;->tryOpen(Ljava/lang/String;)Ljava/util/zip/ZipFile;

    #@1f
    move-result-object v1
    :try_end_20
    .catch Landroid/content/pm/PackageManager$NameNotFoundException; {:try_start_a .. :try_end_20} :catch_25

    #@20
    if-nez v1, :cond_3e

    #@22
    add-int/lit8 v2, v2, 0x1

    #@24
    goto :goto_7

    #@25
    :catch_25
    move-exception v0

    #@26
    .line 167
    new-instance v1, Lcom/pairip/VMRunner$VMRunnerException;

    #@28
    invoke-virtual {v0}, Landroid/content/pm/PackageManager$NameNotFoundException;->getMessage()Ljava/lang/String;

    #@2b
    move-result-object v2

    #@2c
    new-instance v3, Ljava/lang/StringBuilder;

    #@2e
    const-string v4, "Error while opening base apk: "

    #@30
    invoke-direct {v3, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    #@33
    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@36
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    #@39
    move-result-object v2

    #@3a
    invoke-direct {v1, v2, v0}, Lcom/pairip/VMRunner$VMRunnerException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    #@3d
    throw v1

    #@3e
    :cond_3e
    return-object v1
.end method

.method private static declared-synchronized getApkPathFromResource()Ljava/lang/String;
    .registers 8

    #@0
    const-string v0, "Resource URL is "

    #@2
    const-class v1, Lcom/pairip/VMRunner;

    #@4
    monitor-enter v1

    #@5
    .line 209
    :try_start_5
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    #@8
    move-result-wide v2

    #@9
    .line 213
    const-string v4, "/AndroidManifest.xml"

    #@b
    invoke-virtual {v1, v4}, Ljava/lang/Class;->getResource(Ljava/lang/String;)Ljava/net/URL;

    #@e
    move-result-object v4

    #@f
    if-nez v4, :cond_21

    #@11
    .line 215
    invoke-static {}, Lcom/pairip/VMRunner;->isDebuggingEnabled()Z

    #@14
    move-result v0

    #@15
    if-eqz v0, :cond_1e

    #@17
    .line 216
    const-string v0, "VMRunner"

    #@19
    const-string v2, "Cannot load resource!"

    #@1b
    invoke-static {v0, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_1e
    .catchall {:try_start_5 .. :try_end_1e} :catchall_73

    #@1e
    .line 218
    :cond_1e
    monitor-exit v1

    #@1f
    const/4 v0, 0x0

    #@20
    goto :goto_70

    #@21
    .line 220
    :cond_21
    :try_start_21
    invoke-static {}, Lcom/pairip/VMRunner;->isDebuggingEnabled()Z

    #@24
    move-result v5

    #@25
    if-eqz v5, :cond_3c

    #@27
    .line 221
    const-string v5, "VMRunner"

    #@29
    invoke-static {v4}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    #@2c
    move-result-object v6

    #@2d
    new-instance v7, Ljava/lang/StringBuilder;

    #@2f
    invoke-direct {v7, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    #@32
    invoke-virtual {v7, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@35
    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    #@38
    move-result-object v0

    #@39
    invoke-static {v5, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    #@3c
    .line 228
    :cond_3c
    invoke-virtual {v4}, Ljava/net/URL;->toString()Ljava/lang/String;

    #@3f
    move-result-object v0

    #@40
    const/16 v4, 0x21

    #@42
    .line 229
    invoke-virtual {v0, v4}, Ljava/lang/String;->lastIndexOf(I)I

    #@45
    move-result v4

    #@46
    const/16 v5, 0x9

    #@48
    invoke-virtual {v0, v5, v4}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    #@4b
    move-result-object v0

    #@4c
    .line 230
    invoke-static {}, Lcom/pairip/VMRunner;->isDebuggingEnabled()Z

    #@4f
    move-result v4

    #@50
    if-eqz v4, :cond_6f

    #@52
    .line 231
    const-string v4, "VMRunner"

    #@54
    const-string v5, "Found APK path %s after %d ms."

    #@56
    .line 235
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    #@59
    move-result-wide v6

    #@5a
    sub-long/2addr v6, v2

    #@5b
    invoke-static {v6, v7}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    #@5e
    move-result-object v2

    #@5f
    const/4 v3, 0x2

    #@60
    new-array v3, v3, [Ljava/lang/Object;

    #@62
    const/4 v6, 0x0

    #@63
    aput-object v0, v3, v6

    #@65
    const/4 v6, 0x1

    #@66
    aput-object v2, v3, v6

    #@68
    .line 233
    invoke-static {v5, v3}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    #@6b
    move-result-object v2

    #@6c
    .line 231
    invoke-static {v4, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_6f
    .catchall {:try_start_21 .. :try_end_6f} :catchall_73

    #@6f
    .line 237
    :cond_6f
    monitor-exit v1

    #@70
    :goto_70
    return-object v0

    #@71
    :goto_71
    :try_start_71
    monitor-exit v1
    :try_end_72
    .catchall {:try_start_71 .. :try_end_72} :catchall_73

    #@72
    throw v0

    #@73
    :catchall_73
    move-exception v0

    #@74
    goto :goto_71
.end method

.method public static getContext()Landroid/content/Context;
    .registers 1

    #@0
    .line 52
    sget-object v0, Lcom/pairip/VMRunner;->context:Landroid/content/Context;

    #@2
    return-object v0
.end method

.method public static getJob()Ljava/util/concurrent/Future;
    .registers 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/concurrent/Future<",
            "*>;"
        }
    .end annotation

    #@0
    .line 98
    sget-object v0, Lcom/pairip/VMRunner;->job:Ljava/util/concurrent/Future;

    #@2
    return-object v0
.end method

.method private static getVmByteCode(Ljava/lang/String;)[B
    .registers 4
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "vmByteCodeFile"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    #@0
    .line 102
    invoke-static {p0}, Lcom/pairip/VMRunner;->readByteCode(Ljava/lang/String;)[B

    #@3
    move-result-object p0

    #@4
    .line 103
    new-instance v0, Lcom/pairip/VmDecryptor;

    #@6
    invoke-direct {v0}, Lcom/pairip/VmDecryptor;-><init>()V

    #@9
    sget v1, Lcom/pairip/VMRunner;->versionCode:I

    #@b
    invoke-static {}, Lcom/pairip/VMRunner;->isDebuggingEnabled()Z

    #@e
    move-result v2

    #@f
    invoke-virtual {v0, p0, v1, v2}, Lcom/pairip/VmDecryptor;->decrypt([BIZ)[B

    #@12
    move-result-object p0

    #@13
    return-object p0
.end method

.method public static invoke(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;
    .registers 8
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0
        }
        names = {
            "vmByteCodeFile",
            "args"
        }
    .end annotation

    #@0
    .line 56
    sget-object v0, Lcom/pairip/VMRunner;->context:Landroid/content/Context;

    #@2
    if-nez v0, :cond_b

    #@4
    .line 57
    invoke-static {}, Lcom/pairip/InitContextProvider;->tryToCreateContextForBindingApp()Landroid/content/Context;

    #@7
    move-result-object v0

    #@8
    invoke-static {v0}, Lcom/pairip/VMRunner;->setContext(Landroid/content/Context;)V

    #@b
    .line 59
    :cond_b
    invoke-static {}, Lcom/pairip/VMRunner;->isDebuggingEnabled()Z

    #@e
    move-result v0

    #@f
    const-string v1, "VMRunner"

    #@11
    if-eqz v0, :cond_24

    #@13
    .line 60
    new-instance v0, Ljava/lang/StringBuilder;

    #@15
    const-string v2, "Executing "

    #@17
    invoke-direct {v0, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    #@1a
    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@1d
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    #@20
    move-result-object v0

    #@21
    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    #@24
    .line 64
    :cond_24
    :try_start_24
    invoke-static {p0}, Lcom/pairip/VMRunner;->getVmByteCode(Ljava/lang/String;)[B

    #@27
    move-result-object v0
    :try_end_28
    .catch Ljava/io/IOException; {:try_start_24 .. :try_end_28} :catch_52

    #@28
    .line 68
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    #@2b
    move-result-wide v2

    #@2c
    .line 69
    invoke-static {v0, p1}, Lcom/pairip/VMRunner;->executeVM([B[Ljava/lang/Object;)Ljava/lang/Object;

    #@2f
    move-result-object p1

    #@30
    .line 70
    invoke-static {}, Lcom/pairip/VMRunner;->isDebuggingEnabled()Z

    #@33
    move-result v0

    #@34
    if-eqz v0, :cond_51

    #@36
    .line 75
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    #@39
    move-result-wide v4

    #@3a
    sub-long/2addr v4, v2

    #@3b
    invoke-static {v4, v5}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    #@3e
    move-result-object v0

    #@3f
    const/4 v2, 0x2

    #@40
    new-array v2, v2, [Ljava/lang/Object;

    #@42
    const/4 v3, 0x0

    #@43
    aput-object p0, v2, v3

    #@45
    const/4 p0, 0x1

    #@46
    aput-object v0, v2, p0

    #@48
    .line 73
    const-string p0, "Finished executing %s after %d ms."

    #@4a
    invoke-static {p0, v2}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    #@4d
    move-result-object p0

    #@4e
    .line 71
    invoke-static {v1, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    #@51
    :cond_51
    return-object p1

    #@52
    :catch_52
    move-exception p0

    #@53
    .line 66
    new-instance p1, Lcom/pairip/VMRunner$VMRunnerException;

    #@55
    const-string v0, "Error while loading bytecode."

    #@57
    invoke-direct {p1, v0, p0}, Lcom/pairip/VMRunner$VMRunnerException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    #@5a
    throw p1
.end method

.method private static isDebuggingEnabled()Z
    .registers 2

    #@0
    .line 241
    const-string/jumbo v0, "true"

    #@3
    sget-object v1, Lcom/pairip/VMRunner;->loggingEnabled:Ljava/lang/String;

    #@5
    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    #@8
    move-result v0

    #@9
    return v0
.end method

.method private static openBaseApk()Ljava/util/zip/ZipFile;
    .registers 2

    #@0
    .line 135
    sget-object v0, Lcom/pairip/VMRunner;->apkPath:Ljava/lang/String;

    #@2
    invoke-static {v0}, Lcom/pairip/VMRunner;->tryOpen(Ljava/lang/String;)Ljava/util/zip/ZipFile;

    #@5
    move-result-object v0

    #@6
    if-nez v0, :cond_18

    #@8
    .line 140
    invoke-static {}, Lcom/pairip/VMRunner;->getApkPathFromResource()Ljava/lang/String;

    #@b
    move-result-object v0

    #@c
    .line 141
    invoke-static {v0}, Lcom/pairip/VMRunner;->tryOpen(Ljava/lang/String;)Ljava/util/zip/ZipFile;

    #@f
    move-result-object v0

    #@10
    if-nez v0, :cond_18

    #@12
    .line 146
    invoke-static {}, Lcom/pairip/VMRunner;->getApkFromContextPath()Ljava/util/zip/ZipFile;

    #@15
    move-result-object v0

    #@16
    if-eqz v0, :cond_19

    #@18
    :cond_18
    return-object v0

    #@19
    .line 150
    :cond_19
    new-instance v0, Lcom/pairip/VMRunner$VMRunnerException;

    #@1b
    const-string v1, "Could not open base apk."

    #@1d
    invoke-direct {v0, v1}, Lcom/pairip/VMRunner$VMRunnerException;-><init>(Ljava/lang/String;)V

    #@20
    throw v0
.end method

.method private static readByteCode(Ljava/lang/String;)[B
    .registers 11
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "vmByteCodeFile"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    #@0
    const-string v0, "assets/"

    #@2
    .line 107
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    #@5
    move-result-wide v1

    #@6
    .line 110
    invoke-static {}, Lcom/pairip/VMRunner;->openBaseApk()Ljava/util/zip/ZipFile;

    #@9
    move-result-object v3

    #@a
    .line 111
    :try_start_a
    new-instance v4, Ljava/lang/StringBuilder;

    #@c
    invoke-direct {v4, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    #@f
    invoke-virtual {v4, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@12
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    #@15
    move-result-object v0

    #@16
    invoke-virtual {v3, v0}, Ljava/util/zip/ZipFile;->getEntry(Ljava/lang/String;)Ljava/util/zip/ZipEntry;

    #@19
    move-result-object v0

    #@1a
    if-eqz v0, :cond_6d

    #@1c
    .line 116
    invoke-virtual {v3, v0}, Ljava/util/zip/ZipFile;->getInputStream(Ljava/util/zip/ZipEntry;)Ljava/io/InputStream;

    #@1f
    move-result-object v4
    :try_end_20
    .catchall {:try_start_a .. :try_end_20} :catchall_84

    #@20
    .line 117
    :try_start_20
    invoke-virtual {v0}, Ljava/util/zip/ZipEntry;->getSize()J

    #@23
    move-result-wide v5

    #@24
    long-to-int v0, v5

    #@25
    new-array v5, v0, [B

    #@27
    .line 118
    invoke-static {v4, v5}, Lcom/pairip/VMRunner;->readFullByteArrayFromStream(Ljava/io/InputStream;[B)[B

    #@2a
    .line 119
    invoke-static {}, Lcom/pairip/VMRunner;->isDebuggingEnabled()Z

    #@2d
    move-result v6

    #@2e
    if-eqz v6, :cond_56

    #@30
    .line 120
    const-string v6, "VMRunner"

    #@32
    const-string v7, "Finished loading %s (%d kB) after %d ms."

    #@34
    div-int/lit16 v0, v0, 0x400

    #@36
    .line 125
    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    #@39
    move-result-object v0

    #@3a
    .line 126
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    #@3d
    move-result-wide v8

    #@3e
    sub-long/2addr v8, v1

    #@3f
    invoke-static {v8, v9}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    #@42
    move-result-object v1

    #@43
    const/4 v2, 0x3

    #@44
    new-array v2, v2, [Ljava/lang/Object;

    #@46
    const/4 v8, 0x0

    #@47
    aput-object p0, v2, v8

    #@49
    const/4 p0, 0x1

    #@4a
    aput-object v0, v2, p0

    #@4c
    const/4 p0, 0x2

    #@4d
    aput-object v1, v2, p0

    #@4f
    .line 122
    invoke-static {v7, v2}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    #@52
    move-result-object p0

    #@53
    .line 120
    invoke-static {v6, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_56
    .catchall {:try_start_20 .. :try_end_56} :catchall_61

    #@56
    :cond_56
    if-eqz v4, :cond_5b

    #@58
    .line 129
    :try_start_58
    invoke-virtual {v4}, Ljava/io/InputStream;->close()V
    :try_end_5b
    .catchall {:try_start_58 .. :try_end_5b} :catchall_84

    #@5b
    :cond_5b
    if-eqz v3, :cond_60

    #@5d
    .line 130
    invoke-virtual {v3}, Ljava/util/zip/ZipFile;->close()V

    #@60
    :cond_60
    return-object v5

    #@61
    :catchall_61
    move-exception p0

    #@62
    if-eqz v4, :cond_6c

    #@64
    .line 116
    :try_start_64
    invoke-virtual {v4}, Ljava/io/InputStream;->close()V
    :try_end_67
    .catchall {:try_start_64 .. :try_end_67} :catchall_68

    #@67
    goto :goto_6c

    #@68
    :catchall_68
    move-exception v0

    #@69
    :try_start_69
    invoke-virtual {p0, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    #@6c
    :cond_6c
    :goto_6c
    throw p0

    #@6d
    .line 113
    :cond_6d
    new-instance v0, Ljava/io/IOException;

    #@6f
    new-instance v1, Ljava/lang/StringBuilder;

    #@71
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    #@74
    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@77
    const-string p0, " not found."

    #@79
    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@7c
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    #@7f
    move-result-object p0

    #@80
    invoke-direct {v0, p0}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    #@83
    throw v0
    :try_end_84
    .catchall {:try_start_69 .. :try_end_84} :catchall_84

    #@84
    :catchall_84
    move-exception p0

    #@85
    if-eqz v3, :cond_8f

    #@87
    .line 110
    :try_start_87
    invoke-virtual {v3}, Ljava/util/zip/ZipFile;->close()V
    :try_end_8a
    .catchall {:try_start_87 .. :try_end_8a} :catchall_8b

    #@8a
    goto :goto_8f

    #@8b
    :catchall_8b
    move-exception v0

    #@8c
    invoke-virtual {p0, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    #@8f
    :cond_8f
    :goto_8f
    throw p0
.end method

.method private static readFullByteArrayFromStream(Ljava/io/InputStream;[B)[B
    .registers 5
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0
        }
        names = {
            "is",
            "byteArray"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    #@0
    const/4 v0, 0x0

    #@1
    .line 198
    :goto_1
    array-length v1, p1

    #@2
    sub-int/2addr v1, v0

    #@3
    invoke-virtual {p0, p1, v0, v1}, Ljava/io/InputStream;->read([BII)I

    #@6
    move-result v1

    #@7
    if-lez v1, :cond_b

    #@9
    add-int/2addr v0, v1

    #@a
    goto :goto_1

    #@b
    .line 202
    :cond_b
    array-length p0, p1

    #@c
    if-ne v0, p0, :cond_f

    #@e
    return-object p1

    #@f
    .line 203
    :cond_f
    new-instance p0, Ljava/io/IOException;

    #@11
    array-length p1, p1

    #@12
    new-instance v1, Ljava/lang/StringBuilder;

    #@14
    const-string v2, "Read "

    #@16
    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    #@19
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    #@1c
    const-string v0, "/"

    #@1e
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@21
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    #@24
    const-string p1, " bytes."

    #@26
    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@29
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    #@2c
    move-result-object p1

    #@2d
    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    #@30
    throw p0
.end method

.method public static setContext(Landroid/content/Context;)V
    .registers 1
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "context"
        }
    .end annotation

    #@0
    .line 48
    sput-object p0, Lcom/pairip/VMRunner;->context:Landroid/content/Context;

    #@2
    return-void
.end method

.method public static setJob(Ljava/util/concurrent/Future;)V
    .registers 1
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "job"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/concurrent/Future<",
            "*>;)V"
        }
    .end annotation

    #@0
    .line 94
    sput-object p0, Lcom/pairip/VMRunner;->job:Ljava/util/concurrent/Future;

    #@2
    return-void
.end method

.method private static tryOpen(Ljava/lang/String;)Ljava/util/zip/ZipFile;
    .registers 5
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "path"
        }
    .end annotation

    #@0
    const/4 v0, 0x0

    #@1
    if-eqz p0, :cond_32

    #@3
    .line 179
    :try_start_3
    new-instance v1, Ljava/util/zip/ZipFile;

    #@5
    invoke-direct {v1, p0}, Ljava/util/zip/ZipFile;-><init>(Ljava/lang/String;)V

    #@8
    .line 181
    sput-object p0, Lcom/pairip/VMRunner;->apkPath:Ljava/lang/String;
    :try_end_a
    .catch Ljava/io/IOException; {:try_start_3 .. :try_end_a} :catch_c

    #@a
    move-object v0, v1

    #@b
    goto :goto_32

    #@c
    :catch_c
    move-exception v1

    #@d
    .line 184
    invoke-static {}, Lcom/pairip/VMRunner;->isDebuggingEnabled()Z

    #@10
    move-result v2

    #@11
    if-eqz v2, :cond_32

    #@13
    .line 185
    invoke-virtual {v1}, Ljava/io/IOException;->getMessage()Ljava/lang/String;

    #@16
    move-result-object v1

    #@17
    new-instance v2, Ljava/lang/StringBuilder;

    #@19
    const-string v3, "Cannot open zipfile "

    #@1b
    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    #@1e
    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@21
    const-string p0, " error: "

    #@23
    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@26
    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@29
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    #@2c
    move-result-object p0

    #@2d
    const-string v1, "VMRunner"

    #@2f
    invoke-static {v1, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    #@32
    :cond_32
    :goto_32
    return-object v0
.end method
