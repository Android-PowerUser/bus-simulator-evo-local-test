.class public Lcom/pairip/licensecheck/LicenseClient;
.super Ljava/lang/Object;
.source "LicenseClient.java"

# interfaces
.implements Landroid/content/ServiceConnection;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;,
        Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;,
        Lcom/pairip/licensecheck/LicenseClient$DelayedTaskExecutorImpl;,
        Lcom/pairip/licensecheck/LicenseClient$DelayedTaskExecutor;
    }
.end annotation


# static fields
.field private static final BACKGROUND_SERVICE_INTERFACE_CLASS_NAME:Ljava/lang/String; = "com.android.vending.licensing.IBackgroundLicensingService"

.field private static final ERROR_INVALID_PACKAGE_NAME:I = 0x3

.field private static final EVENTUAL_SHUTDOWN_DELAY_MILLIS:I = 0x7530

.field private static final EXTRA_END_CUSTOM_TRIAL:Ljava/lang/String; = "end_custom_trial"

.field private static final FIRST_ISOLATED_UID:I = 0x182b8

.field private static final FLAG_RPC_CALL:I = 0x0

.field private static final LAST_ISOLATED_UID:I = 0x1869f

.field private static final LICENSED:I = 0x0

.field private static final MAX_RETRIES:I = 0x3

.field private static final MILLIS_PER_SEC:I = 0x3e8

.field private static final MIN_TRIAL_END_INTERVAL_MILLIS:J = 0xbb8L

.field private static final NOT_LICENSED:I = 0x2

.field private static final PAYLOAD_PAYWALL:Ljava/lang/String; = "PAYWALL_INTENT"

.field private static final PER_USER_RANGE:I = 0x186a0

.field private static final REPEATED_CHECK_RETRY_DELAY_MILLIS:I = 0x493e0

.field private static final RETRY_DELAY_MILLIS:I = 0x7d0

.field private static final SERVICE_INTERFACE_CLASS_NAME:Ljava/lang/String; = "com.android.vending.licensing.ILicensingService"

.field private static final SERVICE_PACKAGE:Ljava/lang/String; = "com.android.vending"

.field private static final TAG:Ljava/lang/String; = "LicenseClient"

.field private static final TRANSACTION_CHECK_LICENSE_V2:I = 0x2

.field private static final TRANSACTION_REPORT_SUCCESSFUL_LICENSE_CHECK:I = 0x3

.field protected static backgroundLicensingServiceEnabled:Z = true

.field protected static backgroundRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor; = null

.field protected static customTrialEndTriggered:Z = false

.field protected static eventualShutdownEnabled:Z = true

.field protected static exitAction:Ljava/lang/Runnable; = null

.field public static gracefulShutdownEnabled:Z = true

.field private static final handler:Landroid/os/Handler;

.field private static instance:Lcom/pairip/licensecheck/LicenseClient; = null

.field protected static lastTrialEndElapsedRealtimeMillis:J = 0x0L

.field protected static volatile licenseCheckState:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState; = null

.field protected static licensePubKey:Ljava/lang/String; = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApq8V5MCVi/R+DwXAwAJwQOiJl6xhcsZIDgO8fpqRwE5NS5ij+3Zo3jIFoxOC48Iy2hXY23dKUVjMLaA/QX0NPaoESJA52KW2KZMDSvOAcNrHimrY3/oAKTXnnGeKOV0L1AyTwRQQugZUv/CcPjBWQjRmPAeT8Ve1ODIzbS7kEHMzzno+5FzmyJtMyN6wAmIoKiwj8loHIKgExb77kcg8Ug1jVVOU3qrZUKjqajb/Tm8VKbmAJdk+/8uKvGAg3ELbjyHsFUerNCeHIzC9KvmpY47Q2AEVlrzRCIn8UE1leCQJIJrcT8iVwZVE6Iq0Te7TAZk84tJyCtLDkv3N0T5i+wIDAQAB"

.field protected static localCheckEnabled:Z = false

.field protected static mainThreadRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor; = null

.field protected static packageName:Ljava/lang/String; = "com.Ovilex.BusSimulator2023"

.field protected static repeatedCheckEnabled:Z = true

.field protected static responsePayload:Landroid/os/Bundle;


# instance fields
.field private final context:Landroid/content/Context;

.field protected delayedTaskExecutor:Lcom/pairip/licensecheck/LicenseClient$DelayedTaskExecutor;

.field protected isBound:Z

.field private repeatedCheckStartElapsedRealtime:J

.field protected retryNum:I

.field protected waitingForRepeatedCheck:Z


# direct methods
.method public static synthetic $r8$lambda$8YRQpF8qc5JOZUcKq79QHnbGjYY(Lcom/pairip/licensecheck/LicenseClient;Lcom/pairip/licensecheck/RepeatedCheckMetadata;)V
    .registers 2

    #@0
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseClient;->lambda$scheduleRepeatedLicenseCheck$0(Lcom/pairip/licensecheck/RepeatedCheckMetadata;)V

    #@3
    return-void
.end method

.method public static synthetic $r8$lambda$GS82Fij7VQePgSFog-s63-Rcyb0(Lcom/pairip/licensecheck/LicenseClient;)V
    .registers 1

    #@0
    invoke-direct {p0}, Lcom/pairip/licensecheck/LicenseClient;->lambda$initializeLicenseCheck$0()V

    #@3
    return-void
.end method

.method public static synthetic $r8$lambda$gb-vmUiJUmqdCloCudVdY-igh7I(Lcom/pairip/licensecheck/LicenseClient;Landroid/os/IBinder;)V
    .registers 2

    #@0
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseClient;->lambda$onServiceConnected$1(Landroid/os/IBinder;)V

    #@3
    return-void
.end method

.method public static synthetic $r8$lambda$nn58bl0tYjCXTurL0z1br2IkQ-g(Lcom/pairip/licensecheck/LicenseClient;Lcom/pairip/licensecheck/LicenseCheckException;)V
    .registers 2

    #@0
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseClient;->lambda$handleError$0(Lcom/pairip/licensecheck/LicenseCheckException;)V

    #@3
    return-void
.end method

.method public static synthetic $r8$lambda$ot_XkRbEJeEFG1Hy-d3H6N4DX_I(Lcom/pairip/licensecheck/LicenseClient;Lcom/pairip/licensecheck/RepeatedCheckMetadata;Landroid/os/Bundle;)V
    .registers 3

    #@0
    invoke-direct {p0, p1, p2}, Lcom/pairip/licensecheck/LicenseClient;->lambda$processResponse$0(Lcom/pairip/licensecheck/RepeatedCheckMetadata;Landroid/os/Bundle;)V

    #@3
    return-void
.end method

.method public static synthetic $r8$lambda$q2q7YKfx3jIZHqiUNn7fQ55wwzI(Lcom/pairip/licensecheck/LicenseClient;Z)V
    .registers 2

    #@0
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseClient;->lambda$initializeLicenseCheck$1(Z)V

    #@3
    return-void
.end method

.method public static synthetic $r8$lambda$tB8S6FJPE8_x6-ohvmHs84x5lek(Lcom/pairip/licensecheck/LicenseClient;ZLcom/pairip/licensecheck/LicenseCheckException;Z)V
    .registers 4

    #@0
    invoke-direct {p0, p1, p2, p3}, Lcom/pairip/licensecheck/LicenseClient;->lambda$retryOrThrow$0(ZLcom/pairip/licensecheck/LicenseCheckException;Z)V

    #@3
    return-void
.end method

.method public static synthetic $r8$lambda$x_INbtAE1cLJhbPOU3l3uRiKDN8(Lcom/pairip/licensecheck/LicenseClient;Z)V
    .registers 2

    #@0
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseClient;->lambda$retryOrThrow$1(Z)V

    #@3
    return-void
.end method

.method public static synthetic $r8$lambda$xzrAfByzooHDT9oIsgTdQvzthuE(Lcom/pairip/licensecheck/LicenseClient;Landroid/os/IBinder;)V
    .registers 2

    #@0
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseClient;->lambda$onServiceConnected$0(Landroid/os/IBinder;)V

    #@3
    return-void
.end method

.method static bridge synthetic -$$Nest$mprocessResponse(Lcom/pairip/licensecheck/LicenseClient;ILandroid/os/Bundle;)V
    .registers 3

    #@0
    invoke-direct {p0, p1, p2}, Lcom/pairip/licensecheck/LicenseClient;->processResponse(ILandroid/os/Bundle;)V

    #@3
    return-void
.end method

.method static constructor <clinit>()V
    .registers 2

    #@0
    .line 78
    new-instance v0, Lcom/pairip/licensecheck/LicenseClient$1;

    #@2
    invoke-direct {v0}, Lcom/pairip/licensecheck/LicenseClient$1;-><init>()V

    #@5
    sput-object v0, Lcom/pairip/licensecheck/LicenseClient;->exitAction:Ljava/lang/Runnable;

    #@7
    .line 116
    sget-object v0, Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;->CHECK_REQUIRED:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@9
    sput-object v0, Lcom/pairip/licensecheck/LicenseClient;->licenseCheckState:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@b
    .line 119
    new-instance v0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda5;

    #@d
    invoke-direct {v0}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda5;-><init>()V

    #@10
    sput-object v0, Lcom/pairip/licensecheck/LicenseClient;->backgroundRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;

    #@12
    .line 124
    new-instance v0, Landroid/os/Handler;

    #@14
    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    #@17
    move-result-object v1

    #@18
    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    #@1b
    sput-object v0, Lcom/pairip/licensecheck/LicenseClient;->handler:Landroid/os/Handler;

    #@1d
    .line 126
    invoke-static {v0}, Ljava/util/Objects;->requireNonNull(Ljava/lang/Object;)Ljava/lang/Object;

    #@20
    new-instance v1, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda6;

    #@22
    invoke-direct {v1, v0}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda6;-><init>(Landroid/os/Handler;)V

    #@25
    sput-object v1, Lcom/pairip/licensecheck/LicenseClient;->mainThreadRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;

    #@27
    const/4 v0, 0x0

    #@28
    .line 131
    sput-boolean v0, Lcom/pairip/licensecheck/LicenseClient;->customTrialEndTriggered:Z

    #@2a
    const-wide/16 v0, 0x0

    #@2c
    .line 134
    sput-wide v0, Lcom/pairip/licensecheck/LicenseClient;->lastTrialEndElapsedRealtimeMillis:J

    #@2e
    return-void
.end method

.method public constructor <init>(Landroid/content/Context;)V
    .registers 4
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "context"
        }
    .end annotation

    #@0
    .line 262
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    #@3
    .line 140
    new-instance v0, Lcom/pairip/licensecheck/LicenseClient$DelayedTaskExecutorImpl;

    #@5
    const/4 v1, 0x0

    #@6
    invoke-direct {v0, v1}, Lcom/pairip/licensecheck/LicenseClient$DelayedTaskExecutorImpl;-><init>(Lcom/pairip/licensecheck/LicenseClient-IA;)V

    #@9
    iput-object v0, p0, Lcom/pairip/licensecheck/LicenseClient;->delayedTaskExecutor:Lcom/pairip/licensecheck/LicenseClient$DelayedTaskExecutor;

    #@b
    const/4 v0, 0x0

    #@c
    .line 143
    iput v0, p0, Lcom/pairip/licensecheck/LicenseClient;->retryNum:I

    #@e
    .line 150
    iput-boolean v0, p0, Lcom/pairip/licensecheck/LicenseClient;->isBound:Z

    #@10
    .line 157
    iput-boolean v0, p0, Lcom/pairip/licensecheck/LicenseClient;->waitingForRepeatedCheck:Z

    #@12
    const-wide/16 v0, 0x0

    #@14
    .line 160
    iput-wide v0, p0, Lcom/pairip/licensecheck/LicenseClient;->repeatedCheckStartElapsedRealtime:J

    #@16
    .line 263
    iput-object p1, p0, Lcom/pairip/licensecheck/LicenseClient;->context:Landroid/content/Context;

    #@18
    return-void
.end method

.method private bindToLicensingService(Z)V
    .registers 7
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "useBackgroundService"
        }
    .end annotation

    #@0
    .line 357
    invoke-virtual {p0}, Lcom/pairip/licensecheck/LicenseClient;->unbindFromLicensingService()V

    #@3
    if-eqz p1, :cond_8

    #@5
    .line 361
    const-string v0, "Connecting to the background licensing service..."

    #@7
    goto :goto_a

    #@8
    .line 362
    :cond_8
    const-string v0, "Connecting to the main licensing service..."

    #@a
    .line 358
    :goto_a
    const-string v1, "LicenseClient"

    #@c
    invoke-static {v1, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    #@f
    if-eqz p1, :cond_14

    #@11
    .line 365
    const-string v0, "com.android.vending.licensing.IBackgroundLicensingService"

    #@13
    goto :goto_16

    #@14
    .line 366
    :cond_14
    const-string v0, "com.android.vending.licensing.ILicensingService"

    #@16
    .line 367
    :goto_16
    new-instance v1, Landroid/content/Intent;

    #@18
    invoke-direct {v1, v0}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    #@1b
    const-string v2, "com.android.vending"

    #@1d
    .line 368
    invoke-virtual {v1, v2}, Landroid/content/Intent;->setPackage(Ljava/lang/String;)Landroid/content/Intent;

    #@20
    move-result-object v1

    #@21
    invoke-virtual {v1, v0}, Landroid/content/Intent;->setAction(Ljava/lang/String;)Landroid/content/Intent;

    #@24
    move-result-object v1

    #@25
    const/4 v2, 0x1

    #@26
    if-nez p1, :cond_30

    #@28
    .line 370
    invoke-static {}, Lcom/pairip/licensecheck/LicenseClient;->isLocalCheckPassed()Z

    #@2b
    move-result v3

    #@2c
    if-nez v3, :cond_30

    #@2e
    const/4 v3, 0x0

    #@2f
    goto :goto_31

    #@30
    :cond_30
    const/4 v3, 0x1

    #@31
    .line 372
    :goto_31
    :try_start_31
    iget-object v4, p0, Lcom/pairip/licensecheck/LicenseClient;->context:Landroid/content/Context;

    #@33
    .line 373
    invoke-virtual {v4, v1, p0, v2}, Landroid/content/Context;->bindService(Landroid/content/Intent;Landroid/content/ServiceConnection;I)Z

    #@36
    move-result v1
    :try_end_37
    .catch Ljava/lang/SecurityException; {:try_start_31 .. :try_end_37} :catch_4b

    #@37
    if-nez v1, :cond_48

    #@39
    .line 383
    new-instance v1, Lcom/pairip/licensecheck/LicenseCheckException;

    #@3b
    const-string v2, "Could not bind with the licensing service: "

    #@3d
    invoke-virtual {v2, v0}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;

    #@40
    move-result-object v0

    #@41
    invoke-direct {v1, v0}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;)V

    #@44
    invoke-direct {p0, v1, v3, p1}, Lcom/pairip/licensecheck/LicenseClient;->retryOrThrow(Lcom/pairip/licensecheck/LicenseCheckException;ZZ)V

    #@47
    goto :goto_5a

    #@48
    .line 389
    :cond_48
    iput-boolean v2, p0, Lcom/pairip/licensecheck/LicenseClient;->isBound:Z

    #@4a
    goto :goto_5a

    #@4b
    :catch_4b
    move-exception v1

    #@4c
    .line 375
    new-instance v2, Lcom/pairip/licensecheck/LicenseCheckException;

    #@4e
    const-string v4, "Not allowed to bind with the licensing service: "

    #@50
    invoke-virtual {v4, v0}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;

    #@53
    move-result-object v0

    #@54
    invoke-direct {v2, v0, v1}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    #@57
    invoke-direct {p0, v2, v3, p1}, Lcom/pairip/licensecheck/LicenseClient;->retryOrThrow(Lcom/pairip/licensecheck/LicenseCheckException;ZZ)V

    #@5a
    :goto_5a
    return-void
.end method

.method public static checkLicense(Landroid/content/Context;)V
    .registers 3
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "context"
        }
    .end annotation

    #@0
    .line 175
    const-string v0, "LicenseClient"

    #@2
    if-nez p0, :cond_a

    #@4
    .line 176
    const-string p0, "Cannot check license with null context."

    #@6
    invoke-static {v0, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    #@9
    goto :goto_20

    #@a
    .line 179
    :cond_a
    invoke-static {}, Lcom/pairip/licensecheck/LicenseClient;->isIsolatedProcess()Z

    #@d
    move-result v1

    #@e
    if-eqz v1, :cond_16

    #@10
    .line 180
    const-string p0, "Skipping license check in isolated process."

    #@12
    invoke-static {v0, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    #@15
    goto :goto_20

    #@16
    .line 183
    :cond_16
    sget-object v0, Lcom/pairip/licensecheck/LicenseClient;->mainThreadRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;

    #@18
    new-instance v1, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda7;

    #@1a
    invoke-direct {v1, p0}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda7;-><init>(Landroid/content/Context;)V

    #@1d
    invoke-interface {v0, v1}, Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;->run(Ljava/lang/Runnable;)V

    #@20
    :goto_20
    return-void
.end method

.method private checkLicenseInternal(Landroid/os/IBinder;)V
    .registers 8
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "licensingServiceBinder"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/pairip/licensecheck/LicenseCheckException;,
            Landroid/os/RemoteException;
        }
    .end annotation

    #@0
    .line 456
    const-string v0, "Request to licensing service sent."

    #@2
    if-nez p1, :cond_f

    #@4
    .line 457
    new-instance p1, Lcom/pairip/licensecheck/LicenseCheckException;

    #@6
    const-string v0, "Received a null binder."

    #@8
    invoke-direct {p1, v0}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;)V

    #@b
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseClient;->retryOrThrow(Lcom/pairip/licensecheck/LicenseCheckException;)V

    #@e
    goto :goto_60

    #@f
    .line 461
    :cond_f
    invoke-interface {p1}, Landroid/os/IBinder;->getInterfaceDescriptor()Ljava/lang/String;

    #@12
    move-result-object v1

    #@13
    const-string v2, "com.android.vending.licensing.IBackgroundLicensingService"

    #@15
    .line 462
    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    #@18
    move-result v1

    #@19
    if-nez v1, :cond_6c

    #@1b
    .line 467
    const-string v1, "Sending request to licensing service..."

    #@1d
    const-string v2, "LicenseClient"

    #@1f
    invoke-static {v2, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    #@22
    .line 468
    invoke-static {}, Landroid/os/Parcel;->obtain()Landroid/os/Parcel;

    #@25
    move-result-object v1

    #@26
    .line 469
    invoke-static {}, Landroid/os/Parcel;->obtain()Landroid/os/Parcel;

    #@29
    move-result-object v3

    #@2a
    .line 471
    :try_start_2a
    invoke-direct {p0, v1, p1}, Lcom/pairip/licensecheck/LicenseClient;->populateInputDataForLicenseCheckV2(Landroid/os/Parcel;Landroid/os/IBinder;)V

    #@2d
    const/4 v4, 0x2

    #@2e
    const/4 v5, 0x0

    #@2f
    .line 473
    invoke-interface {p1, v4, v1, v3, v5}, Landroid/os/IBinder;->transact(ILandroid/os/Parcel;Landroid/os/Parcel;I)Z

    #@32
    move-result p1

    #@33
    if-nez p1, :cond_57

    #@35
    .line 476
    new-instance p1, Lcom/pairip/licensecheck/LicenseCheckException;

    #@37
    const-string v4, "Licensing service could not process request."

    #@39
    invoke-direct {p1, v4}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;)V

    #@3c
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseClient;->handleError(Lcom/pairip/licensecheck/LicenseCheckException;)V
    :try_end_3f
    .catch Landroid/os/DeadObjectException; {:try_start_2a .. :try_end_3f} :catch_4c
    .catch Landroid/os/RemoteException; {:try_start_2a .. :try_end_3f} :catch_40
    .catchall {:try_start_2a .. :try_end_3f} :catchall_61

    #@3f
    goto :goto_57

    #@40
    :catch_40
    move-exception p1

    #@41
    .line 481
    :try_start_41
    new-instance v4, Lcom/pairip/licensecheck/LicenseCheckException;

    #@43
    const-string v5, "Error when calling licensing service."

    #@45
    invoke-direct {v4, v5, p1}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    #@48
    invoke-direct {p0, v4}, Lcom/pairip/licensecheck/LicenseClient;->handleError(Lcom/pairip/licensecheck/LicenseCheckException;)V

    #@4b
    goto :goto_57

    #@4c
    :catch_4c
    move-exception p1

    #@4d
    .line 479
    new-instance v4, Lcom/pairip/licensecheck/LicenseCheckException;

    #@4f
    const-string v5, "Licensing service process died."

    #@51
    invoke-direct {v4, v5, p1}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    #@54
    invoke-direct {p0, v4}, Lcom/pairip/licensecheck/LicenseClient;->retryOrThrow(Lcom/pairip/licensecheck/LicenseCheckException;)V
    :try_end_57
    .catchall {:try_start_41 .. :try_end_57} :catchall_61

    #@57
    .line 483
    :cond_57
    :goto_57
    invoke-virtual {v1}, Landroid/os/Parcel;->recycle()V

    #@5a
    .line 484
    invoke-virtual {v3}, Landroid/os/Parcel;->recycle()V

    #@5d
    .line 485
    invoke-static {v2, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    #@60
    :goto_60
    return-void

    #@61
    :catchall_61
    move-exception p1

    #@62
    .line 483
    invoke-virtual {v1}, Landroid/os/Parcel;->recycle()V

    #@65
    .line 484
    invoke-virtual {v3}, Landroid/os/Parcel;->recycle()V

    #@68
    .line 485
    invoke-static {v2, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    #@6b
    .line 486
    throw p1

    #@6c
    .line 463
    :cond_6c
    new-instance p1, Lcom/pairip/licensecheck/LicenseCheckException;

    #@6e
    const-string v0, "Background licensing service does not support full license check."

    #@70
    invoke-direct {p1, v0}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;)V

    #@73
    throw p1
.end method

.method static checkTrialStatus()Lcom/pairip/licensecheck/TrialStatus;
    .registers 2

    #@0
    .line 204
    invoke-static {}, Lcom/pairip/licensecheck/LicenseClient;->isIsolatedProcess()Z

    #@3
    move-result v0

    #@4
    if-eqz v0, :cond_10

    #@6
    .line 205
    const-string v0, "LicenseClient"

    #@8
    const-string v1, "Skipping trial status check in isolated process."

    #@a
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    #@d
    .line 206
    sget-object v0, Lcom/pairip/licensecheck/TrialStatus;->UNKNOWN:Lcom/pairip/licensecheck/TrialStatus;

    #@f
    goto :goto_33

    #@10
    .line 208
    :cond_10
    sget-object v0, Lcom/pairip/licensecheck/LicenseClient;->licenseCheckState:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@12
    invoke-virtual {v0}, Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;->ordinal()I

    #@15
    move-result v0

    #@16
    if-eqz v0, :cond_31

    #@18
    const/4 v1, 0x1

    #@19
    if-eq v0, v1, :cond_2e

    #@1b
    const/4 v1, 0x2

    #@1c
    if-eq v0, v1, :cond_2e

    #@1e
    const/4 v1, 0x3

    #@1f
    if-eq v0, v1, :cond_2e

    #@21
    const/4 v1, 0x4

    #@22
    if-ne v0, v1, :cond_27

    #@24
    .line 209
    sget-object v0, Lcom/pairip/licensecheck/TrialStatus;->UNDER_TRIAL:Lcom/pairip/licensecheck/TrialStatus;

    #@26
    goto :goto_33

    #@27
    .line 208
    :cond_27
    new-instance v0, Ljava/lang/RuntimeException;

    #@29
    const/4 v1, 0x0

    #@2a
    invoke-direct {v0, v1, v1}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    #@2d
    throw v0

    #@2e
    .line 210
    :cond_2e
    sget-object v0, Lcom/pairip/licensecheck/TrialStatus;->NOT_UNDER_TRIAL:Lcom/pairip/licensecheck/TrialStatus;

    #@30
    goto :goto_33

    #@31
    .line 211
    :cond_31
    sget-object v0, Lcom/pairip/licensecheck/TrialStatus;->UNKNOWN:Lcom/pairip/licensecheck/TrialStatus;

    #@33
    :goto_33
    return-object v0
.end method

.method private createCloseAppIntentOrExitIfAppInBackground()Landroid/content/Intent;
    .registers 4

    #@0
    .line 743
    invoke-direct {p0}, Lcom/pairip/licensecheck/LicenseClient;->isForeground()Z

    #@3
    move-result v0

    #@4
    if-nez v0, :cond_b

    #@6
    .line 744
    sget-object v0, Lcom/pairip/licensecheck/LicenseClient;->exitAction:Ljava/lang/Runnable;

    #@8
    invoke-interface {v0}, Ljava/lang/Runnable;->run()V

    #@b
    .line 746
    :cond_b
    new-instance v0, Landroid/content/Intent;

    #@d
    iget-object v1, p0, Lcom/pairip/licensecheck/LicenseClient;->context:Landroid/content/Context;

    #@f
    const-class v2, Lcom/pairip/licensecheck/LicenseActivity;

    #@11
    invoke-direct {v0, v1, v2}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    #@14
    .line 747
    sget-boolean v1, Lcom/pairip/licensecheck/LicenseClient;->gracefulShutdownEnabled:Z

    #@16
    if-eqz v1, :cond_1e

    #@18
    const/high16 v1, 0x10000

    #@1a
    .line 748
    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    #@1d
    goto :goto_29

    #@1e
    :cond_1e
    const/high16 v1, 0x4000000

    #@20
    .line 750
    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    #@23
    const v1, 0x8000

    #@26
    .line 751
    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    #@29
    :goto_29
    const/high16 v1, 0x10000000

    #@2b
    .line 753
    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;

    #@2e
    return-object v0
.end method

.method private static createResultListener(Lcom/pairip/licensecheck/LicenseClient;)Lcom/pairip/licensecheck/ILicenseV2ResultListener;
    .registers 2
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "client"
        }
    .end annotation

    #@0
    .line 572
    new-instance v0, Lcom/pairip/licensecheck/LicenseClient$2;

    #@2
    invoke-direct {v0, p0}, Lcom/pairip/licensecheck/LicenseClient$2;-><init>(Lcom/pairip/licensecheck/LicenseClient;)V

    #@5
    return-object v0
.end method

.method private static declared-synchronized getInstance(Landroid/content/Context;)Lcom/pairip/licensecheck/LicenseClient;
    .registers 3
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "context"
        }
    .end annotation

    #@0
    const-class v0, Lcom/pairip/licensecheck/LicenseClient;

    #@2
    monitor-enter v0

    #@3
    .line 164
    :try_start_3
    sget-object v1, Lcom/pairip/licensecheck/LicenseClient;->instance:Lcom/pairip/licensecheck/LicenseClient;

    #@5
    if-nez v1, :cond_e

    #@7
    .line 165
    new-instance v1, Lcom/pairip/licensecheck/LicenseClient;

    #@9
    invoke-direct {v1, p0}, Lcom/pairip/licensecheck/LicenseClient;-><init>(Landroid/content/Context;)V

    #@c
    sput-object v1, Lcom/pairip/licensecheck/LicenseClient;->instance:Lcom/pairip/licensecheck/LicenseClient;
    :try_end_e
    .catchall {:try_start_3 .. :try_end_e} :catchall_12

    #@e
    .line 167
    :cond_e
    monitor-exit v0

    #@f
    return-object v1

    #@10
    :goto_10
    :try_start_10
    monitor-exit v0
    :try_end_11
    .catchall {:try_start_10 .. :try_end_11} :catchall_12

    #@11
    throw p0

    #@12
    :catchall_12
    move-exception p0

    #@13
    goto :goto_10
.end method

.method public static getLicensePubKey()Ljava/lang/String;
    .registers 1

    #@0
    .line 259
    sget-object v0, Lcom/pairip/licensecheck/LicenseClient;->licensePubKey:Ljava/lang/String;

    #@2
    return-object v0
.end method

.method private handleError(Lcom/pairip/licensecheck/LicenseCheckException;)V
    .registers 4
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "ex"
        }
    .end annotation

    #@0
    .line 713
    sget-object v0, Lcom/pairip/licensecheck/LicenseClient;->mainThreadRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;

    #@2
    new-instance v1, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda4;

    #@4
    invoke-direct {v1, p0, p1}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda4;-><init>(Lcom/pairip/licensecheck/LicenseClient;Lcom/pairip/licensecheck/LicenseCheckException;)V

    #@7
    invoke-interface {v0, v1}, Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;->run(Ljava/lang/Runnable;)V

    #@a
    return-void
.end method

.method private initiateFreshLicensingServiceConnection(Z)V
    .registers 3
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "useBackgroundService"
        }
    .end annotation

    #@0
    const/4 v0, 0x0

    #@1
    .line 351
    iput v0, p0, Lcom/pairip/licensecheck/LicenseClient;->retryNum:I

    #@3
    .line 352
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseClient;->bindToLicensingService(Z)V

    #@6
    return-void
.end method

.method private isForeground()Z
    .registers 3

    #@0
    .line 758
    new-instance v0, Landroid/app/ActivityManager$RunningAppProcessInfo;

    #@2
    invoke-direct {v0}, Landroid/app/ActivityManager$RunningAppProcessInfo;-><init>()V

    #@5
    .line 760
    invoke-static {v0}, Landroid/app/ActivityManager;->getMyMemoryState(Landroid/app/ActivityManager$RunningAppProcessInfo;)V

    #@8
    .line 761
    iget v0, v0, Landroid/app/ActivityManager$RunningAppProcessInfo;->importance:I

    #@a
    const/16 v1, 0x64

    #@c
    if-gt v0, v1, :cond_10

    #@e
    const/4 v0, 0x1

    #@f
    goto :goto_11

    #@10
    :cond_10
    const/4 v0, 0x0

    #@11
    :goto_11
    return v0
.end method

.method private static isIsolatedProcess()Z
    .registers 2

    #@0
    .line 244
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    #@2
    const/16 v1, 0x1c

    #@4
    if-lt v0, v1, :cond_b

    #@6
    .line 245
    invoke-static {}, Landroid/os/Process;->isIsolated()Z

    #@9
    move-result v0

    #@a
    goto :goto_20

    #@b
    .line 253
    :cond_b
    invoke-static {}, Landroid/os/Process;->myUid()I

    #@e
    move-result v0

    #@f
    const v1, 0x186a0

    #@12
    .line 254
    rem-int/2addr v0, v1

    #@13
    const v1, 0x182b8

    #@16
    if-lt v0, v1, :cond_1f

    #@18
    const v1, 0x1869f

    #@1b
    if-gt v0, v1, :cond_1f

    #@1d
    const/4 v0, 0x1

    #@1e
    goto :goto_20

    #@1f
    :cond_1f
    const/4 v0, 0x0

    #@20
    :goto_20
    return v0
.end method

.method private static isLocalCheckPassed()Z
    .registers 2

    #@0
    .line 706
    sget-object v0, Lcom/pairip/licensecheck/LicenseClient;->licenseCheckState:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@2
    sget-object v1, Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;->LOCAL_CHECK_OK:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@4
    invoke-virtual {v0, v1}, Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;->equals(Ljava/lang/Object;)Z

    #@7
    move-result v0

    #@8
    if-nez v0, :cond_16

    #@a
    sget-object v0, Lcom/pairip/licensecheck/LicenseClient;->licenseCheckState:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@c
    sget-object v1, Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;->LOCAL_CHECK_REPORTED:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@e
    .line 707
    invoke-virtual {v0, v1}, Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;->equals(Ljava/lang/Object;)Z

    #@11
    move-result v0

    #@12
    if-nez v0, :cond_16

    #@14
    const/4 v0, 0x0

    #@15
    goto :goto_17

    #@16
    :cond_16
    const/4 v0, 0x1

    #@17
    :goto_17
    return v0
.end method

.method static synthetic lambda$checkLicense$0(Landroid/content/Context;)V
    .registers 1

    #@0
    .line 183
    invoke-static {p0}, Lcom/pairip/licensecheck/LicenseClient;->getInstance(Landroid/content/Context;)Lcom/pairip/licensecheck/LicenseClient;

    #@3
    move-result-object p0

    #@4
    invoke-virtual {p0}, Lcom/pairip/licensecheck/LicenseClient;->initializeLicenseCheck()V

    #@7
    return-void
.end method

.method private synthetic lambda$handleError$0(Lcom/pairip/licensecheck/LicenseCheckException;)V
    .registers 4

    #@0
    .line 715
    invoke-static {p1}, Landroid/util/Log;->getStackTraceString(Ljava/lang/Throwable;)Ljava/lang/String;

    #@3
    move-result-object p1

    #@4
    new-instance v0, Ljava/lang/StringBuilder;

    #@6
    const-string v1, "Error while checking license: "

    #@8
    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    #@b
    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@e
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    #@11
    move-result-object p1

    #@12
    const-string v0, "LicenseClient"

    #@14
    invoke-static {v0, p1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    #@17
    .line 716
    invoke-virtual {p0}, Lcom/pairip/licensecheck/LicenseClient;->unbindFromLicensingService()V

    #@1a
    .line 717
    sget-object p1, Lcom/pairip/licensecheck/LicenseClient;->licenseCheckState:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@1c
    sget-object v0, Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;->FULL_CHECK_OK:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@1e
    invoke-virtual {p1, v0}, Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;->equals(Ljava/lang/Object;)Z

    #@21
    move-result p1

    #@22
    if-nez p1, :cond_2d

    #@24
    invoke-static {}, Lcom/pairip/licensecheck/LicenseClient;->isLocalCheckPassed()Z

    #@27
    move-result p1

    #@28
    if-nez p1, :cond_2d

    #@2a
    .line 722
    invoke-direct {p0}, Lcom/pairip/licensecheck/LicenseClient;->startErrorDialogActivity()V

    #@2d
    :cond_2d
    return-void
.end method

.method private synthetic lambda$initializeLicenseCheck$0()V
    .registers 4

    #@0
    .line 274
    invoke-direct {p0}, Lcom/pairip/licensecheck/LicenseClient;->performLocalInstallerCheck()Z

    #@3
    move-result v0

    #@4
    .line 277
    sget-object v1, Lcom/pairip/licensecheck/LicenseClient;->mainThreadRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;

    #@6
    new-instance v2, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda1;

    #@8
    invoke-direct {v2, p0, v0}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda1;-><init>(Lcom/pairip/licensecheck/LicenseClient;Z)V

    #@b
    invoke-interface {v1, v2}, Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;->run(Ljava/lang/Runnable;)V

    #@e
    return-void
.end method

.method private synthetic lambda$initializeLicenseCheck$1(Z)V
    .registers 2

    #@0
    if-eqz p1, :cond_c

    #@2
    .line 280
    sget-object p1, Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;->LOCAL_CHECK_OK:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@4
    sput-object p1, Lcom/pairip/licensecheck/LicenseClient;->licenseCheckState:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@6
    .line 284
    sget-boolean p1, Lcom/pairip/licensecheck/LicenseClient;->backgroundLicensingServiceEnabled:Z

    #@8
    if-eqz p1, :cond_c

    #@a
    const/4 p1, 0x1

    #@b
    goto :goto_d

    #@c
    :cond_c
    const/4 p1, 0x0

    #@d
    .line 286
    :goto_d
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseClient;->initiateFreshLicensingServiceConnection(Z)V

    #@10
    return-void
.end method

.method private synthetic lambda$onServiceConnected$0(Landroid/os/IBinder;)V
    .registers 4

    #@0
    .line 408
    :try_start_0
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseClient;->checkLicenseInternal(Landroid/os/IBinder;)V
    :try_end_3
    .catch Lcom/pairip/licensecheck/LicenseCheckException; {:try_start_0 .. :try_end_3} :catch_10
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_3} :catch_4

    #@3
    goto :goto_14

    #@4
    :catch_4
    move-exception p1

    #@5
    .line 412
    new-instance v0, Lcom/pairip/licensecheck/LicenseCheckException;

    #@7
    const-string v1, "Error when getting interface descriptor."

    #@9
    invoke-direct {v0, v1, p1}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    #@c
    invoke-direct {p0, v0}, Lcom/pairip/licensecheck/LicenseClient;->handleError(Lcom/pairip/licensecheck/LicenseCheckException;)V

    #@f
    goto :goto_14

    #@10
    :catch_10
    move-exception p1

    #@11
    .line 410
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseClient;->handleError(Lcom/pairip/licensecheck/LicenseCheckException;)V

    #@14
    :goto_14
    return-void
.end method

.method private synthetic lambda$onServiceConnected$1(Landroid/os/IBinder;)V
    .registers 4

    #@0
    .line 422
    :try_start_0
    invoke-virtual {p0, p1}, Lcom/pairip/licensecheck/LicenseClient;->reportSuccessfulLicenseCheck(Landroid/os/IBinder;)V
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_3} :catch_4

    #@3
    goto :goto_26

    #@4
    :catch_4
    move-exception p1

    #@5
    .line 424
    invoke-static {p1}, Landroid/util/Log;->getStackTraceString(Ljava/lang/Throwable;)Ljava/lang/String;

    #@8
    move-result-object p1

    #@9
    new-instance v0, Ljava/lang/StringBuilder;

    #@b
    const-string v1, "Error while reporting license check: "

    #@d
    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    #@10
    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@13
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    #@16
    move-result-object p1

    #@17
    const-string v0, "LicenseClient"

    #@19
    invoke-static {v0, p1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    #@1c
    .line 425
    sget-object p1, Lcom/pairip/licensecheck/LicenseClient;->mainThreadRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;

    #@1e
    new-instance v0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda0;

    #@20
    invoke-direct {v0, p0}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda0;-><init>(Lcom/pairip/licensecheck/LicenseClient;)V

    #@23
    invoke-interface {p1, v0}, Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;->run(Ljava/lang/Runnable;)V

    #@26
    :goto_26
    return-void
.end method

.method private synthetic lambda$processResponse$0(Lcom/pairip/licensecheck/RepeatedCheckMetadata;Landroid/os/Bundle;)V
    .registers 5

    #@0
    if-eqz p1, :cond_10

    #@2
    .line 630
    sget-object v0, Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;->REPEATED_CHECK_REQUIRED:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@4
    sput-object v0, Lcom/pairip/licensecheck/LicenseClient;->licenseCheckState:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@6
    .line 631
    invoke-virtual {p0}, Lcom/pairip/licensecheck/LicenseClient;->getElapsedRealtimeMillis()J

    #@9
    move-result-wide v0

    #@a
    iput-wide v0, p0, Lcom/pairip/licensecheck/LicenseClient;->repeatedCheckStartElapsedRealtime:J

    #@c
    .line 632
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseClient;->scheduleRepeatedLicenseCheck(Lcom/pairip/licensecheck/RepeatedCheckMetadata;)V

    #@f
    goto :goto_14

    #@10
    .line 634
    :cond_10
    sget-object p1, Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;->FULL_CHECK_OK:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@12
    sput-object p1, Lcom/pairip/licensecheck/LicenseClient;->licenseCheckState:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@14
    .line 636
    :goto_14
    sput-object p2, Lcom/pairip/licensecheck/LicenseClient;->responsePayload:Landroid/os/Bundle;

    #@16
    return-void
.end method

.method static synthetic lambda$reportSuccessfulLicenseCheck$0()V
    .registers 1

    #@0
    .line 515
    sget-object v0, Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;->LOCAL_CHECK_REPORTED:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@2
    sput-object v0, Lcom/pairip/licensecheck/LicenseClient;->licenseCheckState:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@4
    return-void
.end method

.method private synthetic lambda$retryOrThrow$0(ZLcom/pairip/licensecheck/LicenseCheckException;Z)V
    .registers 10

    #@0
    .line 595
    invoke-virtual {p0}, Lcom/pairip/licensecheck/LicenseClient;->unbindFromLicensingService()V

    #@3
    .line 596
    iget v0, p0, Lcom/pairip/licensecheck/LicenseClient;->retryNum:I

    #@5
    const-string v1, "LicenseClient"

    #@7
    const/4 v2, 0x3

    #@8
    if-ge v0, v2, :cond_43

    #@a
    const/4 p3, 0x1

    #@b
    add-int/2addr v0, p3

    #@c
    .line 597
    iput v0, p0, Lcom/pairip/licensecheck/LicenseClient;->retryNum:I

    #@e
    .line 599
    iget-object v0, p0, Lcom/pairip/licensecheck/LicenseClient;->delayedTaskExecutor:Lcom/pairip/licensecheck/LicenseClient$DelayedTaskExecutor;

    #@10
    new-instance v3, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda13;

    #@12
    invoke-direct {v3, p0, p1}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda13;-><init>(Lcom/pairip/licensecheck/LicenseClient;Z)V

    #@15
    const-wide/16 v4, 0x7d0

    #@17
    invoke-interface {v0, v3, v4, v5}, Lcom/pairip/licensecheck/LicenseClient$DelayedTaskExecutor;->schedule(Ljava/lang/Runnable;J)V

    #@1a
    .line 600
    iget p1, p0, Lcom/pairip/licensecheck/LicenseClient;->retryNum:I

    #@1c
    .line 604
    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    #@1f
    move-result-object p1

    #@20
    if-nez p2, :cond_25

    #@22
    const-string p2, "null"

    #@24
    goto :goto_29

    #@25
    :cond_25
    invoke-virtual {p2}, Lcom/pairip/licensecheck/LicenseCheckException;->getMessage()Ljava/lang/String;

    #@28
    move-result-object p2

    #@29
    :goto_29
    const-wide/16 v3, 0x2

    #@2b
    invoke-static {v3, v4}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    #@2e
    move-result-object v0

    #@2f
    new-array v2, v2, [Ljava/lang/Object;

    #@31
    const/4 v3, 0x0

    #@32
    aput-object p1, v2, v3

    #@34
    aput-object p2, v2, p3

    #@36
    const/4 p1, 0x2

    #@37
    aput-object v0, v2, p1

    #@39
    .line 602
    const-string p1, "Retry #%d. License check failed with error \'%s\'. Next try in %ds..."

    #@3b
    invoke-static {p1, v2}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    #@3e
    move-result-object p1

    #@3f
    .line 600
    invoke-static {v1, p1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    #@42
    goto :goto_5e

    #@43
    :cond_43
    if-eqz p3, :cond_5b

    #@45
    .line 607
    invoke-static {p2}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    #@48
    move-result-object p1

    #@49
    new-instance p2, Ljava/lang/StringBuilder;

    #@4b
    const-string p3, "Retry limit reached for: "

    #@4d
    invoke-direct {p2, p3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    #@50
    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@53
    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    #@56
    move-result-object p1

    #@57
    invoke-static {v1, p1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    #@5a
    goto :goto_5e

    #@5b
    .line 609
    :cond_5b
    invoke-direct {p0, p2}, Lcom/pairip/licensecheck/LicenseClient;->handleError(Lcom/pairip/licensecheck/LicenseCheckException;)V

    #@5e
    :goto_5e
    return-void
.end method

.method private synthetic lambda$retryOrThrow$1(Z)V
    .registers 2

    #@0
    .line 599
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseClient;->bindToLicensingService(Z)V

    #@3
    return-void
.end method

.method private synthetic lambda$scheduleRepeatedLicenseCheck$0(Lcom/pairip/licensecheck/RepeatedCheckMetadata;)V
    .registers 9

    #@0
    .line 665
    invoke-virtual {p0}, Lcom/pairip/licensecheck/LicenseClient;->getElapsedRealtimeMillis()J

    #@3
    move-result-wide v0

    #@4
    .line 666
    iget-wide v2, p0, Lcom/pairip/licensecheck/LicenseClient;->repeatedCheckStartElapsedRealtime:J

    #@6
    sub-long/2addr v0, v2

    #@7
    .line 668
    invoke-virtual {p0}, Lcom/pairip/licensecheck/LicenseClient;->getCurrentTimeMillis()J

    #@a
    move-result-wide v2

    #@b
    .line 669
    invoke-virtual {p1}, Lcom/pairip/licensecheck/RepeatedCheckMetadata;->getTimeToRetryMillis()J

    #@e
    move-result-wide v4

    #@f
    cmp-long v6, v2, v4

    #@11
    if-gez v6, :cond_26

    #@13
    .line 670
    invoke-virtual {p1}, Lcom/pairip/licensecheck/RepeatedCheckMetadata;->getDurationToRetryMillis()J

    #@16
    move-result-wide v2

    #@17
    cmp-long v4, v0, v2

    #@19
    if-gez v4, :cond_26

    #@1b
    .line 674
    const-string v0, "LicenseClient"

    #@1d
    const-string v1, "Repeated license check is rescheduled."

    #@1f
    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    #@22
    .line 675
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseClient;->scheduleRepeatedLicenseCheck(Lcom/pairip/licensecheck/RepeatedCheckMetadata;)V

    #@25
    goto :goto_2c

    #@26
    :cond_26
    const/4 p1, 0x0

    #@27
    .line 671
    iput-boolean p1, p0, Lcom/pairip/licensecheck/LicenseClient;->waitingForRepeatedCheck:Z

    #@29
    .line 672
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseClient;->initiateFreshLicensingServiceConnection(Z)V

    #@2c
    :goto_2c
    return-void
.end method

.method static synthetic lambda$static$0(Ljava/lang/Runnable;)V
    .registers 2

    #@0
    .line 121
    new-instance v0, Ljava/lang/Thread;

    #@2
    invoke-direct {v0, p0}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;)V

    #@5
    invoke-virtual {v0}, Ljava/lang/Thread;->start()V

    #@8
    return-void
.end method

.method static synthetic lambda$stopTrial$0(Landroid/content/Context;)V
    .registers 1

    #@0
    .line 196
    invoke-static {p0}, Lcom/pairip/licensecheck/LicenseClient;->getInstance(Landroid/content/Context;)Lcom/pairip/licensecheck/LicenseClient;

    #@3
    move-result-object p0

    #@4
    invoke-virtual {p0}, Lcom/pairip/licensecheck/LicenseClient;->handleTrialEnd()V

    #@7
    return-void
.end method

.method private performLocalInstallerCheck()Z
    .registers 7

    #@0
    .line 312
    const-string v0, "LicenseClient"

    #@2
    const/4 v1, 0x0

    #@3
    :try_start_3
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I

    #@5
    const/16 v3, 0x1e

    #@7
    if-ge v2, v3, :cond_f

    #@9
    .line 313
    const-string v2, "Local install check bypassed due to old SDK version."

    #@b
    invoke-static {v0, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    #@e
    goto :goto_6a

    #@f
    .line 316
    :cond_f
    iget-object v2, p0, Lcom/pairip/licensecheck/LicenseClient;->context:Landroid/content/Context;

    #@11
    invoke-virtual {v2}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    #@14
    move-result-object v2

    #@15
    if-nez v2, :cond_1d

    #@17
    .line 318
    const-string v2, "Local install check bypassed due to package manager not found."

    #@19
    invoke-static {v0, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    #@1c
    goto :goto_6a

    #@1d
    .line 321
    :cond_1d
    sget-object v3, Lcom/pairip/licensecheck/LicenseClient;->packageName:Ljava/lang/String;

    #@1f
    invoke-virtual {v2, v3, v1}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;

    #@22
    move-result-object v3

    #@23
    if-eqz v3, :cond_5e

    #@25
    .line 322
    iget-object v4, v3, Landroid/content/pm/PackageInfo;->applicationInfo:Landroid/content/pm/ApplicationInfo;

    #@27
    if-eqz v4, :cond_5e

    #@29
    .line 326
    iget-object v3, v3, Landroid/content/pm/PackageInfo;->applicationInfo:Landroid/content/pm/ApplicationInfo;

    #@2b
    iget v3, v3, Landroid/content/pm/ApplicationInfo;->flags:I

    #@2d
    and-int/lit8 v4, v3, 0x1

    #@2f
    if-nez v4, :cond_57

    #@31
    and-int/lit16 v3, v3, 0x80

    #@33
    if-nez v3, :cond_57

    #@35
    .line 332
    sget-object v3, Lcom/pairip/licensecheck/LicenseClient;->packageName:Ljava/lang/String;

    #@37
    invoke-virtual {v2, v3}, Landroid/content/pm/PackageManager;->getInstallSourceInfo(Ljava/lang/String;)Landroid/content/pm/InstallSourceInfo;

    #@3a
    move-result-object v2

    #@3b
    if-nez v2, :cond_43

    #@3d
    .line 334
    const-string v2, "Local install check bypassed due to install source info not found."

    #@3f
    invoke-static {v0, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    #@42
    goto :goto_6a

    #@43
    .line 337
    :cond_43
    invoke-virtual {v2}, Landroid/content/pm/InstallSourceInfo;->getInstallingPackageName()Ljava/lang/String;

    #@46
    move-result-object v2

    #@47
    if-eqz v2, :cond_51

    #@49
    .line 338
    const-string v3, "com.android.vending"

    #@4b
    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    #@4e
    move-result v2

    #@4f
    if-nez v2, :cond_5c

    #@51
    .line 339
    :cond_51
    const-string v2, "Local install check failed due to wrong installer."

    #@53
    invoke-static {v0, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    #@56
    goto :goto_6a

    #@57
    .line 329
    :cond_57
    const-string v2, "Local install check passed due to system app."

    #@59
    invoke-static {v0, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    #@5c
    :cond_5c
    const/4 v1, 0x1

    #@5d
    goto :goto_6a

    #@5e
    .line 323
    :cond_5e
    const-string v2, "Local install check bypassed due to app package info not found."

    #@60
    invoke-static {v0, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_63
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_63} :catch_64

    #@63
    goto :goto_6a

    #@64
    :catch_64
    move-exception v2

    #@65
    .line 344
    const-string v3, "Could not obtain package info for local installer check."

    #@67
    invoke-static {v0, v3, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    #@6a
    :goto_6a
    return v1
.end method

.method private populateInputDataForLicenseCheckV2(Landroid/os/Parcel;Landroid/os/IBinder;)V
    .registers 6
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0
        }
        names = {
            "inputData",
            "licensingService"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/RemoteException;
        }
    .end annotation

    #@0
    .line 540
    invoke-interface {p2}, Landroid/os/IBinder;->getInterfaceDescriptor()Ljava/lang/String;

    #@3
    move-result-object p2

    #@4
    invoke-virtual {p1, p2}, Landroid/os/Parcel;->writeInterfaceToken(Ljava/lang/String;)V

    #@7
    .line 541
    sget-object p2, Lcom/pairip/licensecheck/LicenseClient;->packageName:Ljava/lang/String;

    #@9
    invoke-virtual {p1, p2}, Landroid/os/Parcel;->writeString(Ljava/lang/String;)V

    #@c
    .line 542
    invoke-static {p0}, Lcom/pairip/licensecheck/LicenseClient;->createResultListener(Lcom/pairip/licensecheck/LicenseClient;)Lcom/pairip/licensecheck/ILicenseV2ResultListener;

    #@f
    move-result-object p2

    #@10
    invoke-interface {p2}, Lcom/pairip/licensecheck/ILicenseV2ResultListener;->asBinder()Landroid/os/IBinder;

    #@13
    move-result-object p2

    #@14
    invoke-virtual {p1, p2}, Landroid/os/Parcel;->writeStrongBinder(Landroid/os/IBinder;)V

    #@17
    .line 544
    new-instance p2, Landroid/os/Bundle;

    #@19
    invoke-direct {p2}, Landroid/os/Bundle;-><init>()V

    #@1c
    .line 545
    sget-boolean v0, Lcom/pairip/licensecheck/LicenseClient;->customTrialEndTriggered:Z

    #@1e
    const/4 v1, 0x1

    #@1f
    if-eqz v0, :cond_26

    #@21
    .line 546
    const-string v0, "end_custom_trial"

    #@23
    invoke-virtual {p2, v0, v1}, Landroid/os/Bundle;->putBoolean(Ljava/lang/String;Z)V

    #@26
    .line 548
    :cond_26
    invoke-virtual {p2}, Landroid/os/Bundle;->isEmpty()Z

    #@29
    move-result v0

    #@2a
    const/4 v2, 0x0

    #@2b
    if-nez v0, :cond_34

    #@2d
    .line 550
    invoke-virtual {p1, v1}, Landroid/os/Parcel;->writeInt(I)V

    #@30
    .line 551
    invoke-virtual {p2, p1, v2}, Landroid/os/Bundle;->writeToParcel(Landroid/os/Parcel;I)V

    #@33
    goto :goto_37

    #@34
    .line 554
    :cond_34
    invoke-virtual {p1, v2}, Landroid/os/Parcel;->writeInt(I)V

    #@37
    :goto_37
    return-void
.end method

.method private populateInputDataForReportAutoVerifiedLicense(Landroid/os/Parcel;Landroid/os/IBinder;)V
    .registers 3
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0
        }
        names = {
            "inputData",
            "licensingService"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/RemoteException;
        }
    .end annotation

    #@0
    .line 565
    invoke-interface {p2}, Landroid/os/IBinder;->getInterfaceDescriptor()Ljava/lang/String;

    #@3
    move-result-object p2

    #@4
    invoke-virtual {p1, p2}, Landroid/os/Parcel;->writeInterfaceToken(Ljava/lang/String;)V

    #@7
    .line 566
    sget-object p2, Lcom/pairip/licensecheck/LicenseClient;->packageName:Ljava/lang/String;

    #@9
    invoke-virtual {p1, p2}, Landroid/os/Parcel;->writeString(Ljava/lang/String;)V

    #@c
    const/4 p2, 0x0

    #@d
    .line 568
    invoke-virtual {p1, p2}, Landroid/os/Parcel;->writeInt(I)V

    #@10
    return-void
.end method

.method private processResponse(ILandroid/os/Bundle;)V
    .registers 6
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0
        }
        names = {
            "responseCode",
            "responsePayload"
        }
    .end annotation

    #@0
    const/4 v0, 0x3

    #@1
    if-eq p1, v0, :cond_52

    #@3
    if-nez p1, :cond_26

    #@5
    .line 621
    :try_start_5
    sget-object p1, Lcom/pairip/licensecheck/LicenseClient;->packageName:Ljava/lang/String;

    #@7
    invoke-static {p2, p1}, Lcom/pairip/licensecheck/LicenseResponseHelper;->validateResponse(Landroid/os/Bundle;Ljava/lang/String;)V

    #@a
    .line 622
    const-string p1, "LicenseClient"

    #@c
    const-string v0, "License check succeeded."

    #@e
    invoke-static {p1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    #@11
    .line 624
    sget-boolean p1, Lcom/pairip/licensecheck/LicenseClient;->repeatedCheckEnabled:Z

    #@13
    if-eqz p1, :cond_1a

    #@15
    .line 625
    invoke-static {p2}, Lcom/pairip/licensecheck/LicenseResponseHelper;->getRepeatedCheckMetadata(Landroid/os/Bundle;)Lcom/pairip/licensecheck/RepeatedCheckMetadata;

    #@18
    move-result-object p1

    #@19
    goto :goto_1b

    #@1a
    :cond_1a
    const/4 p1, 0x0

    #@1b
    .line 627
    :goto_1b
    sget-object v0, Lcom/pairip/licensecheck/LicenseClient;->mainThreadRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;

    #@1d
    new-instance v1, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda11;

    #@1f
    invoke-direct {v1, p0, p1, p2}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda11;-><init>(Lcom/pairip/licensecheck/LicenseClient;Lcom/pairip/licensecheck/RepeatedCheckMetadata;Landroid/os/Bundle;)V

    #@22
    invoke-interface {v0, v1}, Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;->run(Ljava/lang/Runnable;)V

    #@25
    goto :goto_34

    #@26
    :cond_26
    const/4 v0, 0x2

    #@27
    if-ne p1, v0, :cond_3c

    #@29
    .line 639
    const-string p1, "PAYWALL_INTENT"

    #@2b
    invoke-virtual {p2, p1}, Landroid/os/Bundle;->getParcelable(Ljava/lang/String;)Landroid/os/Parcelable;

    #@2e
    move-result-object p1

    #@2f
    check-cast p1, Landroid/app/PendingIntent;

    #@31
    .line 640
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseClient;->startPaywallActivity(Landroid/app/PendingIntent;)V
    :try_end_34
    .catch Lcom/pairip/licensecheck/LicenseCheckException; {:try_start_5 .. :try_end_34} :catch_5a
    .catchall {:try_start_5 .. :try_end_34} :catchall_69

    #@34
    .line 648
    :goto_34
    sget-object p1, Lcom/pairip/licensecheck/LicenseClient;->mainThreadRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;

    #@36
    new-instance p2, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda0;

    #@38
    invoke-direct {p2, p0}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda0;-><init>(Lcom/pairip/licensecheck/LicenseClient;)V

    #@3b
    goto :goto_65

    #@3c
    .line 642
    :cond_3c
    :try_start_3c
    new-instance p2, Lcom/pairip/licensecheck/LicenseCheckException;

    #@3e
    const-string v0, "Unexpected response code %d received."

    #@40
    .line 643
    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    #@43
    move-result-object p1

    #@44
    const/4 v1, 0x1

    #@45
    new-array v1, v1, [Ljava/lang/Object;

    #@47
    const/4 v2, 0x0

    #@48
    aput-object p1, v1, v2

    #@4a
    invoke-static {v0, v1}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    #@4d
    move-result-object p1

    #@4e
    invoke-direct {p2, p1}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;)V

    #@51
    throw p2

    #@52
    .line 619
    :cond_52
    new-instance p1, Lcom/pairip/licensecheck/LicenseCheckException;

    #@54
    const-string p2, "Request package name invalid."

    #@56
    invoke-direct {p1, p2}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;)V

    #@59
    throw p1
    :try_end_5a
    .catch Lcom/pairip/licensecheck/LicenseCheckException; {:try_start_3c .. :try_end_5a} :catch_5a
    .catchall {:try_start_3c .. :try_end_5a} :catchall_69

    #@5a
    :catch_5a
    move-exception p1

    #@5b
    .line 646
    :try_start_5b
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseClient;->handleError(Lcom/pairip/licensecheck/LicenseCheckException;)V
    :try_end_5e
    .catchall {:try_start_5b .. :try_end_5e} :catchall_69

    #@5e
    .line 648
    sget-object p1, Lcom/pairip/licensecheck/LicenseClient;->mainThreadRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;

    #@60
    new-instance p2, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda0;

    #@62
    invoke-direct {p2, p0}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda0;-><init>(Lcom/pairip/licensecheck/LicenseClient;)V

    #@65
    :goto_65
    invoke-interface {p1, p2}, Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;->run(Ljava/lang/Runnable;)V

    #@68
    return-void

    #@69
    :catchall_69
    move-exception p1

    #@6a
    sget-object p2, Lcom/pairip/licensecheck/LicenseClient;->mainThreadRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;

    #@6c
    new-instance v0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda0;

    #@6e
    invoke-direct {v0, p0}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda0;-><init>(Lcom/pairip/licensecheck/LicenseClient;)V

    #@71
    invoke-interface {p2, v0}, Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;->run(Ljava/lang/Runnable;)V

    #@74
    .line 649
    throw p1
.end method

.method private retryOrThrow(Lcom/pairip/licensecheck/LicenseCheckException;)V
    .registers 3
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "error"
        }
    .end annotation

    #@0
    const/4 v0, 0x0

    #@1
    .line 581
    invoke-direct {p0, p1, v0, v0}, Lcom/pairip/licensecheck/LicenseClient;->retryOrThrow(Lcom/pairip/licensecheck/LicenseCheckException;ZZ)V

    #@4
    return-void
.end method

.method private retryOrThrow(Lcom/pairip/licensecheck/LicenseCheckException;ZZ)V
    .registers 6
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0,
            0x0
        }
        names = {
            "error",
            "ignoreErrorOnFinalFailure",
            "useBackgroundService"
        }
    .end annotation

    #@0
    .line 593
    sget-object v0, Lcom/pairip/licensecheck/LicenseClient;->mainThreadRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;

    #@2
    new-instance v1, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda2;

    #@4
    invoke-direct {v1, p0, p3, p1, p2}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda2;-><init>(Lcom/pairip/licensecheck/LicenseClient;ZLcom/pairip/licensecheck/LicenseCheckException;Z)V

    #@7
    invoke-interface {v0, v1}, Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;->run(Ljava/lang/Runnable;)V

    #@a
    return-void
.end method

.method private scheduleAppShutdown()V
    .registers 5

    #@0
    .line 775
    sget-boolean v0, Lcom/pairip/licensecheck/LicenseClient;->eventualShutdownEnabled:Z

    #@2
    if-eqz v0, :cond_d

    #@4
    .line 776
    iget-object v0, p0, Lcom/pairip/licensecheck/LicenseClient;->delayedTaskExecutor:Lcom/pairip/licensecheck/LicenseClient$DelayedTaskExecutor;

    #@6
    sget-object v1, Lcom/pairip/licensecheck/LicenseClient;->exitAction:Ljava/lang/Runnable;

    #@8
    const-wide/16 v2, 0x7530

    #@a
    invoke-interface {v0, v1, v2, v3}, Lcom/pairip/licensecheck/LicenseClient$DelayedTaskExecutor;->schedule(Ljava/lang/Runnable;J)V

    #@d
    :cond_d
    return-void
.end method

.method private scheduleRepeatedLicenseCheck(Lcom/pairip/licensecheck/RepeatedCheckMetadata;)V
    .registers 8
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "repeatedCheckMetadata"
        }
    .end annotation

    #@0
    .line 653
    invoke-virtual {p0}, Lcom/pairip/licensecheck/LicenseClient;->getCurrentTimeMillis()J

    #@3
    move-result-wide v0

    #@4
    .line 657
    invoke-virtual {p1}, Lcom/pairip/licensecheck/RepeatedCheckMetadata;->getDurationToRetryMillis()J

    #@7
    move-result-wide v2

    #@8
    .line 658
    invoke-virtual {p1}, Lcom/pairip/licensecheck/RepeatedCheckMetadata;->getTimeToRetryMillis()J

    #@b
    move-result-wide v4

    #@c
    sub-long/2addr v4, v0

    #@d
    const-wide/16 v0, 0x0

    #@f
    invoke-static {v0, v1, v4, v5}, Ljava/lang/Math;->max(JJ)J

    #@12
    move-result-wide v0

    #@13
    .line 656
    invoke-static {v2, v3, v0, v1}, Ljava/lang/Math;->min(JJ)J

    #@16
    move-result-wide v0

    #@17
    const-wide/32 v2, 0x493e0

    #@1a
    .line 655
    invoke-static {v0, v1, v2, v3}, Ljava/lang/Math;->min(JJ)J

    #@1d
    move-result-wide v0

    #@1e
    .line 660
    iget-boolean v2, p0, Lcom/pairip/licensecheck/LicenseClient;->waitingForRepeatedCheck:Z

    #@20
    const/4 v3, 0x1

    #@21
    if-nez v2, :cond_25

    #@23
    .line 661
    iput-boolean v3, p0, Lcom/pairip/licensecheck/LicenseClient;->waitingForRepeatedCheck:Z

    #@25
    .line 663
    :cond_25
    iget-object v2, p0, Lcom/pairip/licensecheck/LicenseClient;->delayedTaskExecutor:Lcom/pairip/licensecheck/LicenseClient$DelayedTaskExecutor;

    #@27
    new-instance v4, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda14;

    #@29
    invoke-direct {v4, p0, p1}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda14;-><init>(Lcom/pairip/licensecheck/LicenseClient;Lcom/pairip/licensecheck/RepeatedCheckMetadata;)V

    #@2c
    invoke-interface {v2, v4, v0, v1}, Lcom/pairip/licensecheck/LicenseClient$DelayedTaskExecutor;->schedule(Ljava/lang/Runnable;J)V

    #@2f
    .line 679
    invoke-static {v0, v1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    #@32
    move-result-object p1

    #@33
    new-array v0, v3, [Ljava/lang/Object;

    #@35
    const/4 v1, 0x0

    #@36
    aput-object p1, v0, v1

    #@38
    const-string p1, "Repeated license check is scheduled in %d ms..."

    #@3a
    invoke-static {p1, v0}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    #@3d
    move-result-object p1

    #@3e
    const-string v0, "LicenseClient"

    #@40
    invoke-static {v0, p1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    #@43
    return-void
.end method

.method private startErrorDialogActivity()V
    .registers 4

    #@0
    .line 735
    invoke-direct {p0}, Lcom/pairip/licensecheck/LicenseClient;->createCloseAppIntentOrExitIfAppInBackground()Landroid/content/Intent;

    #@3
    move-result-object v0

    #@4
    .line 736
    const-string v1, "activitytype"

    #@6
    sget-object v2, Lcom/pairip/licensecheck/LicenseActivity$ActivityType;->ERROR_DIALOG:Lcom/pairip/licensecheck/LicenseActivity$ActivityType;

    #@8
    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/io/Serializable;)Landroid/content/Intent;

    #@b
    .line 738
    invoke-direct {p0}, Lcom/pairip/licensecheck/LicenseClient;->scheduleAppShutdown()V

    #@e
    .line 739
    iget-object v1, p0, Lcom/pairip/licensecheck/LicenseClient;->context:Landroid/content/Context;

    #@10
    invoke-virtual {v1, v0}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    #@13
    return-void
.end method

.method private startPaywallActivity(Landroid/app/PendingIntent;)V
    .registers 4
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "paywallIntent"
        }
    .end annotation

    #@0
    .line 727
    invoke-direct {p0}, Lcom/pairip/licensecheck/LicenseClient;->createCloseAppIntentOrExitIfAppInBackground()Landroid/content/Intent;

    #@3
    move-result-object v0

    #@4
    .line 728
    const-string v1, "paywallintent"

    #@6
    invoke-virtual {v0, v1, p1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Landroid/os/Parcelable;)Landroid/content/Intent;

    #@9
    .line 729
    const-string p1, "activitytype"

    #@b
    sget-object v1, Lcom/pairip/licensecheck/LicenseActivity$ActivityType;->PAYWALL:Lcom/pairip/licensecheck/LicenseActivity$ActivityType;

    #@d
    invoke-virtual {v0, p1, v1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/io/Serializable;)Landroid/content/Intent;

    #@10
    .line 730
    invoke-direct {p0}, Lcom/pairip/licensecheck/LicenseClient;->scheduleAppShutdown()V

    #@13
    .line 731
    iget-object p1, p0, Lcom/pairip/licensecheck/LicenseClient;->context:Landroid/content/Context;

    #@15
    invoke-virtual {p1, v0}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    #@18
    return-void
.end method

.method static stopTrial(Landroid/content/Context;)V
    .registers 3
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "context"
        }
    .end annotation

    #@0
    .line 188
    const-string v0, "LicenseClient"

    #@2
    if-nez p0, :cond_a

    #@4
    .line 189
    const-string p0, "Cannot trigger trial end with null context."

    #@6
    invoke-static {v0, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    #@9
    goto :goto_20

    #@a
    .line 192
    :cond_a
    invoke-static {}, Lcom/pairip/licensecheck/LicenseClient;->isIsolatedProcess()Z

    #@d
    move-result v1

    #@e
    if-eqz v1, :cond_16

    #@10
    .line 193
    const-string p0, "Skipping trial end in isolated process."

    #@12
    invoke-static {v0, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    #@15
    goto :goto_20

    #@16
    .line 196
    :cond_16
    sget-object v0, Lcom/pairip/licensecheck/LicenseClient;->mainThreadRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;

    #@18
    new-instance v1, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda3;

    #@1a
    invoke-direct {v1, p0}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda3;-><init>(Landroid/content/Context;)V

    #@1d
    invoke-interface {v0, v1}, Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;->run(Ljava/lang/Runnable;)V

    #@20
    :goto_20
    return-void
.end method


# virtual methods
.method protected getCurrentTimeMillis()J
    .registers 3

    #@0
    .line 766
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    #@3
    move-result-wide v0

    #@4
    return-wide v0
.end method

.method protected getElapsedRealtimeMillis()J
    .registers 3

    #@0
    .line 771
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    #@3
    move-result-wide v0

    #@4
    return-wide v0
.end method

.method protected handleTrialEnd()V
    .registers 13

    #@0
    .line 221
    invoke-virtual {p0}, Lcom/pairip/licensecheck/LicenseClient;->getElapsedRealtimeMillis()J

    #@3
    move-result-wide v0

    #@4
    .line 222
    sget-wide v2, Lcom/pairip/licensecheck/LicenseClient;->lastTrialEndElapsedRealtimeMillis:J

    #@6
    sub-long v4, v0, v2

    #@8
    const-wide/16 v6, 0x0

    #@a
    const/4 v8, 0x1

    #@b
    .line 223
    const-string v9, "LicenseClient"

    #@d
    const/4 v10, 0x0

    #@e
    cmp-long v11, v2, v6

    #@10
    if-lez v11, :cond_2a

    #@12
    const-wide/16 v2, 0xbb8

    #@14
    cmp-long v6, v4, v2

    #@16
    if-gez v6, :cond_2a

    #@18
    .line 230
    invoke-static {v4, v5}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    #@1b
    move-result-object v0

    #@1c
    new-array v1, v8, [Ljava/lang/Object;

    #@1e
    aput-object v0, v1, v10

    #@20
    .line 229
    const-string v0, "Trial end trigger throttled. Ignoring request (sent %d ms ago)."

    #@22
    invoke-static {v0, v1}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    #@25
    move-result-object v0

    #@26
    .line 227
    invoke-static {v9, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    #@29
    goto :goto_3c

    #@2a
    .line 234
    :cond_2a
    const-string v2, "Trial end event triggered; initiating full license check."

    #@2c
    invoke-static {v9, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    #@2f
    .line 235
    sput-wide v0, Lcom/pairip/licensecheck/LicenseClient;->lastTrialEndElapsedRealtimeMillis:J

    #@31
    .line 236
    sput-boolean v8, Lcom/pairip/licensecheck/LicenseClient;->customTrialEndTriggered:Z

    #@33
    .line 237
    sget-object v0, Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;->CHECK_REQUIRED:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@35
    sput-object v0, Lcom/pairip/licensecheck/LicenseClient;->licenseCheckState:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@37
    .line 238
    iput-boolean v10, p0, Lcom/pairip/licensecheck/LicenseClient;->waitingForRepeatedCheck:Z

    #@39
    .line 240
    invoke-direct {p0, v10}, Lcom/pairip/licensecheck/LicenseClient;->initiateFreshLicensingServiceConnection(Z)V

    #@3c
    :goto_3c
    return-void
.end method

.method public initializeLicenseCheck()V
    .registers 4

    #@0
    .line 268
    sget-object v0, Lcom/pairip/licensecheck/LicenseClient;->licenseCheckState:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@2
    invoke-virtual {v0}, Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;->ordinal()I

    #@5
    move-result v0

    #@6
    const/4 v1, 0x0

    #@7
    if-eqz v0, :cond_20

    #@9
    const/4 v2, 0x1

    #@a
    if-eq v0, v2, :cond_13

    #@c
    const/4 v2, 0x4

    #@d
    if-ne v0, v2, :cond_36

    #@f
    .line 304
    invoke-direct {p0, v1}, Lcom/pairip/licensecheck/LicenseClient;->initiateFreshLicensingServiceConnection(Z)V

    #@12
    goto :goto_36

    #@13
    .line 295
    :cond_13
    :try_start_13
    sget-object v0, Lcom/pairip/licensecheck/LicenseClient;->responsePayload:Landroid/os/Bundle;

    #@15
    sget-object v1, Lcom/pairip/licensecheck/LicenseClient;->packageName:Ljava/lang/String;

    #@17
    invoke-static {v0, v1}, Lcom/pairip/licensecheck/LicenseResponseHelper;->validateResponse(Landroid/os/Bundle;Ljava/lang/String;)V
    :try_end_1a
    .catch Lcom/pairip/licensecheck/LicenseCheckException; {:try_start_13 .. :try_end_1a} :catch_1b

    #@1a
    goto :goto_36

    #@1b
    :catch_1b
    move-exception v0

    #@1c
    .line 297
    invoke-direct {p0, v0}, Lcom/pairip/licensecheck/LicenseClient;->handleError(Lcom/pairip/licensecheck/LicenseCheckException;)V

    #@1f
    goto :goto_36

    #@20
    .line 270
    :cond_20
    sget-boolean v0, Lcom/pairip/licensecheck/LicenseClient;->localCheckEnabled:Z

    #@22
    if-eqz v0, :cond_33

    #@24
    sget-boolean v0, Lcom/pairip/licensecheck/LicenseClient;->customTrialEndTriggered:Z

    #@26
    if-nez v0, :cond_33

    #@28
    .line 272
    sget-object v0, Lcom/pairip/licensecheck/LicenseClient;->backgroundRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;

    #@2a
    new-instance v1, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda8;

    #@2c
    invoke-direct {v1, p0}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda8;-><init>(Lcom/pairip/licensecheck/LicenseClient;)V

    #@2f
    invoke-interface {v0, v1}, Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;->run(Ljava/lang/Runnable;)V

    #@32
    goto :goto_36

    #@33
    .line 290
    :cond_33
    invoke-direct {p0, v1}, Lcom/pairip/licensecheck/LicenseClient;->initiateFreshLicensingServiceConnection(Z)V

    #@36
    :cond_36
    :goto_36
    return-void
.end method

.method public onServiceConnected(Landroid/content/ComponentName;Landroid/os/IBinder;)V
    .registers 4
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0
        }
        names = {
            "componentName",
            "licensingServiceBinder"
        }
    .end annotation

    #@0
    .line 396
    const-string p1, "LicenseClient"

    #@2
    const-string v0, "Connected to the licensing service."

    #@4
    invoke-static {p1, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    #@7
    .line 397
    sget-object p1, Lcom/pairip/licensecheck/LicenseClient;->licenseCheckState:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@9
    invoke-virtual {p1}, Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;->ordinal()I

    #@c
    move-result p1

    #@d
    if-eqz p1, :cond_2b

    #@f
    const/4 v0, 0x1

    #@10
    if-eq p1, v0, :cond_27

    #@12
    const/4 v0, 0x2

    #@13
    if-eq p1, v0, :cond_1c

    #@15
    const/4 v0, 0x3

    #@16
    if-eq p1, v0, :cond_27

    #@18
    const/4 v0, 0x4

    #@19
    if-eq p1, v0, :cond_2b

    #@1b
    goto :goto_35

    #@1c
    .line 419
    :cond_1c
    sget-object p1, Lcom/pairip/licensecheck/LicenseClient;->backgroundRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;

    #@1e
    new-instance v0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda10;

    #@20
    invoke-direct {v0, p0, p2}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda10;-><init>(Lcom/pairip/licensecheck/LicenseClient;Landroid/os/IBinder;)V

    #@23
    invoke-interface {p1, v0}, Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;->run(Ljava/lang/Runnable;)V

    #@26
    goto :goto_35

    #@27
    .line 400
    :cond_27
    invoke-virtual {p0}, Lcom/pairip/licensecheck/LicenseClient;->unbindFromLicensingService()V

    #@2a
    goto :goto_35

    #@2b
    .line 405
    :cond_2b
    sget-object p1, Lcom/pairip/licensecheck/LicenseClient;->backgroundRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;

    #@2d
    new-instance v0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda9;

    #@2f
    invoke-direct {v0, p0, p2}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda9;-><init>(Lcom/pairip/licensecheck/LicenseClient;Landroid/os/IBinder;)V

    #@32
    invoke-interface {p1, v0}, Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;->run(Ljava/lang/Runnable;)V

    #@35
    :goto_35
    return-void
.end method

.method public onServiceDisconnected(Landroid/content/ComponentName;)V
    .registers 5
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "componentName"
        }
    .end annotation

    #@0
    const/4 p1, 0x0

    #@1
    .line 434
    iput-boolean p1, p0, Lcom/pairip/licensecheck/LicenseClient;->isBound:Z

    #@3
    .line 435
    sget-object v0, Lcom/pairip/licensecheck/LicenseClient;->licenseCheckState:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@5
    sget-object v1, Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;->REPEATED_CHECK_REQUIRED:Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;

    #@7
    invoke-virtual {v0, v1}, Lcom/pairip/licensecheck/LicenseClient$LicenseCheckState;->equals(Ljava/lang/Object;)Z

    #@a
    move-result v0

    #@b
    const-string v1, "LicenseClient"

    #@d
    if-eqz v0, :cond_19

    #@f
    iget-boolean v0, p0, Lcom/pairip/licensecheck/LicenseClient;->waitingForRepeatedCheck:Z

    #@11
    if-eqz v0, :cond_19

    #@13
    .line 437
    const-string p1, "Ignoring service disconnection in REPEATED_CHECK_REQUIRED state."

    #@15
    invoke-static {v1, p1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    #@18
    goto :goto_33

    #@19
    .line 440
    :cond_19
    const-string v0, "Unexpectedly disconnected from the licensing service."

    #@1b
    invoke-static {v1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    #@1e
    .line 441
    invoke-static {}, Lcom/pairip/licensecheck/LicenseClient;->isLocalCheckPassed()Z

    #@21
    move-result v0

    #@22
    if-eqz v0, :cond_29

    #@24
    .line 442
    sget-boolean v1, Lcom/pairip/licensecheck/LicenseClient;->backgroundLicensingServiceEnabled:Z

    #@26
    if-eqz v1, :cond_29

    #@28
    const/4 p1, 0x1

    #@29
    .line 444
    :cond_29
    new-instance v1, Lcom/pairip/licensecheck/LicenseCheckException;

    #@2b
    const-string v2, "Licensing service unexpectedly disconnected."

    #@2d
    invoke-direct {v1, v2}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;)V

    #@30
    invoke-direct {p0, v1, v0, p1}, Lcom/pairip/licensecheck/LicenseClient;->retryOrThrow(Lcom/pairip/licensecheck/LicenseCheckException;ZZ)V

    #@33
    :goto_33
    return-void
.end method

.method public reportSuccessfulLicenseCheck(Landroid/os/IBinder;)V
    .registers 10
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "licensingServiceBinder"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/pairip/licensecheck/LicenseCheckException;
        }
    .end annotation

    #@0
    .line 493
    const-string v0, "Request to licensing reporting service sent."

    #@2
    .line 0
    const-string v1, "Error when calling licensing service."

    #@4
    const/4 v2, 0x1

    #@5
    if-nez p1, :cond_14

    #@7
    .line 494
    new-instance p1, Lcom/pairip/licensecheck/LicenseCheckException;

    #@9
    const-string v0, "Received a null binder."

    #@b
    invoke-direct {p1, v0}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;)V

    #@e
    sget-boolean v0, Lcom/pairip/licensecheck/LicenseClient;->backgroundLicensingServiceEnabled:Z

    #@10
    invoke-direct {p0, p1, v2, v0}, Lcom/pairip/licensecheck/LicenseClient;->retryOrThrow(Lcom/pairip/licensecheck/LicenseCheckException;ZZ)V

    #@13
    goto :goto_8e

    #@14
    .line 501
    :cond_14
    const-string v3, "Sending request to license reporting service..."

    #@16
    const-string v4, "LicenseClient"

    #@18
    invoke-static {v4, v3}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    #@1b
    .line 502
    invoke-static {}, Landroid/os/Parcel;->obtain()Landroid/os/Parcel;

    #@1e
    move-result-object v3

    #@1f
    .line 503
    invoke-static {}, Landroid/os/Parcel;->obtain()Landroid/os/Parcel;

    #@22
    move-result-object v5

    #@23
    .line 505
    :try_start_23
    invoke-direct {p0, v3, p1}, Lcom/pairip/licensecheck/LicenseClient;->populateInputDataForReportAutoVerifiedLicense(Landroid/os/Parcel;Landroid/os/IBinder;)V

    #@26
    const/4 v6, 0x3

    #@27
    const/4 v7, 0x0

    #@28
    .line 507
    invoke-interface {p1, v6, v3, v5, v7}, Landroid/os/IBinder;->transact(ILandroid/os/Parcel;Landroid/os/Parcel;I)Z

    #@2b
    move-result p1

    #@2c
    if-nez p1, :cond_34

    #@2e
    .line 510
    const-string p1, "Error sending request to license reporting service."

    #@30
    invoke-static {v4, p1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    #@33
    goto :goto_3e

    #@34
    .line 513
    :cond_34
    sget-object p1, Lcom/pairip/licensecheck/LicenseClient;->mainThreadRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;

    #@36
    new-instance v6, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda12;

    #@38
    invoke-direct {v6}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda12;-><init>()V

    #@3b
    invoke-interface {p1, v6}, Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;->run(Ljava/lang/Runnable;)V
    :try_end_3e
    .catch Landroid/os/DeadObjectException; {:try_start_23 .. :try_end_3e} :catch_6e
    .catch Landroid/os/RemoteException; {:try_start_23 .. :try_end_3e} :catch_4c
    .catchall {:try_start_23 .. :try_end_3e} :catchall_8f

    #@3e
    .line 526
    :goto_3e
    invoke-virtual {v3}, Landroid/os/Parcel;->recycle()V

    #@41
    .line 527
    invoke-virtual {v5}, Landroid/os/Parcel;->recycle()V

    #@44
    .line 528
    sget-object p1, Lcom/pairip/licensecheck/LicenseClient;->mainThreadRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;

    #@46
    new-instance v1, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda0;

    #@48
    invoke-direct {v1, p0}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda0;-><init>(Lcom/pairip/licensecheck/LicenseClient;)V

    #@4b
    goto :goto_88

    #@4c
    :catch_4c
    move-exception p1

    #@4d
    .line 524
    :try_start_4d
    invoke-static {p1}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    #@50
    move-result-object p1

    #@51
    new-instance v2, Ljava/lang/StringBuilder;

    #@53
    invoke-direct {v2, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    #@56
    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@59
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    #@5c
    move-result-object p1

    #@5d
    invoke-static {v4, p1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_60
    .catchall {:try_start_4d .. :try_end_60} :catchall_8f

    #@60
    .line 526
    invoke-virtual {v3}, Landroid/os/Parcel;->recycle()V

    #@63
    .line 527
    invoke-virtual {v5}, Landroid/os/Parcel;->recycle()V

    #@66
    .line 528
    sget-object p1, Lcom/pairip/licensecheck/LicenseClient;->mainThreadRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;

    #@68
    new-instance v1, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda0;

    #@6a
    invoke-direct {v1, p0}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda0;-><init>(Lcom/pairip/licensecheck/LicenseClient;)V

    #@6d
    goto :goto_88

    #@6e
    :catch_6e
    move-exception p1

    #@6f
    .line 519
    :try_start_6f
    new-instance v1, Lcom/pairip/licensecheck/LicenseCheckException;

    #@71
    const-string v6, "Licensing service process died."

    #@73
    invoke-direct {v1, v6, p1}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    #@76
    sget-boolean p1, Lcom/pairip/licensecheck/LicenseClient;->backgroundLicensingServiceEnabled:Z

    #@78
    invoke-direct {p0, v1, v2, p1}, Lcom/pairip/licensecheck/LicenseClient;->retryOrThrow(Lcom/pairip/licensecheck/LicenseCheckException;ZZ)V
    :try_end_7b
    .catchall {:try_start_6f .. :try_end_7b} :catchall_8f

    #@7b
    .line 526
    invoke-virtual {v3}, Landroid/os/Parcel;->recycle()V

    #@7e
    .line 527
    invoke-virtual {v5}, Landroid/os/Parcel;->recycle()V

    #@81
    .line 528
    sget-object p1, Lcom/pairip/licensecheck/LicenseClient;->mainThreadRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;

    #@83
    new-instance v1, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda0;

    #@85
    invoke-direct {v1, p0}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda0;-><init>(Lcom/pairip/licensecheck/LicenseClient;)V

    #@88
    :goto_88
    invoke-interface {p1, v1}, Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;->run(Ljava/lang/Runnable;)V

    #@8b
    .line 529
    invoke-static {v4, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    #@8e
    :goto_8e
    return-void

    #@8f
    :catchall_8f
    move-exception p1

    #@90
    .line 526
    invoke-virtual {v3}, Landroid/os/Parcel;->recycle()V

    #@93
    .line 527
    invoke-virtual {v5}, Landroid/os/Parcel;->recycle()V

    #@96
    .line 528
    sget-object v1, Lcom/pairip/licensecheck/LicenseClient;->mainThreadRunner:Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;

    #@98
    new-instance v2, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda0;

    #@9a
    invoke-direct {v2, p0}, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda0;-><init>(Lcom/pairip/licensecheck/LicenseClient;)V

    #@9d
    invoke-interface {v1, v2}, Lcom/pairip/licensecheck/LicenseClient$ImmediateTaskExecutor;->run(Ljava/lang/Runnable;)V

    #@a0
    .line 529
    invoke-static {v4, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    #@a3
    .line 530
    throw p1
.end method

.method protected unbindFromLicensingService()V
    .registers 4

    #@0
    .line 688
    iget-boolean v0, p0, Lcom/pairip/licensecheck/LicenseClient;->isBound:Z

    #@2
    if-eqz v0, :cond_15

    #@4
    const/4 v0, 0x0

    #@5
    .line 691
    iput-boolean v0, p0, Lcom/pairip/licensecheck/LicenseClient;->isBound:Z

    #@7
    .line 693
    :try_start_7
    iget-object v0, p0, Lcom/pairip/licensecheck/LicenseClient;->context:Landroid/content/Context;

    #@9
    invoke-virtual {v0, p0}, Landroid/content/Context;->unbindService(Landroid/content/ServiceConnection;)V
    :try_end_c
    .catch Ljava/lang/RuntimeException; {:try_start_7 .. :try_end_c} :catch_d

    #@c
    goto :goto_15

    #@d
    :catch_d
    move-exception v0

    #@e
    .line 695
    const-string v1, "LicenseClient"

    #@10
    const-string v2, "Failed to unbind from licensing service."

    #@12
    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    #@15
    :cond_15
    :goto_15
    return-void
.end method
