.class public Lcom/pairip/licensecheck/LicenseActivity;
.super Landroid/app/Activity;
.source "LicenseActivity.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/pairip/licensecheck/LicenseActivity$ActivityType;
    }
.end annotation


# static fields
.field public static final ACTIVITY_TYPE_ARG_NAME:Ljava/lang/String; = "activitytype"

.field public static final PAYWALL_INTENT_ARG_NAME:Ljava/lang/String; = "paywallintent"

.field private static final TAG:Ljava/lang/String; = "LicenseActivity"


# direct methods
.method public static synthetic $r8$lambda$N5_Pzpb-eSKmOONXn3Kn0QvMbys(Lcom/pairip/licensecheck/LicenseActivity;)V
    .registers 1

    #@0
    invoke-direct {p0}, Lcom/pairip/licensecheck/LicenseActivity;->lambda$showErrorDialog$0()V

    #@3
    return-void
.end method

.method public static synthetic $r8$lambda$fE_XZ7S0hhHsxQNTfy8mxeJ7kEU(Lcom/pairip/licensecheck/LicenseActivity;Landroid/content/DialogInterface;I)V
    .registers 3

    #@0
    invoke-direct {p0, p1, p2}, Lcom/pairip/licensecheck/LicenseActivity;->lambda$showErrorDialog$1(Landroid/content/DialogInterface;I)V

    #@3
    return-void
.end method

.method public static synthetic $r8$lambda$x-JmBIDmuVzGN23Wk7Dd1TBpzO0(Lcom/pairip/licensecheck/LicenseActivity;Landroid/app/PendingIntent;)V
    .registers 2

    #@0
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseActivity;->lambda$showPaywallAndCloseApp$0(Landroid/app/PendingIntent;)V

    #@3
    return-void
.end method

.method public constructor <init>()V
    .registers 1

    #@0
    .line 19
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V

    #@3
    return-void
.end method

.method private closeApp()V
    .registers 2

    #@0
    .line 113
    sget-boolean v0, Lcom/pairip/licensecheck/LicenseClient;->gracefulShutdownEnabled:Z

    #@2
    if-eqz v0, :cond_8

    #@4
    .line 114
    invoke-virtual {p0}, Lcom/pairip/licensecheck/LicenseActivity;->closeAllTasks()V

    #@7
    goto :goto_b

    #@8
    .line 116
    :cond_8
    invoke-virtual {p0}, Lcom/pairip/licensecheck/LicenseActivity;->exitApp()V

    #@b
    :goto_b
    return-void
.end method

.method private synthetic lambda$showErrorDialog$0()V
    .registers 4

    #@0
    .line 92
    :try_start_0
    new-instance v0, Landroid/app/AlertDialog$Builder;

    #@2
    invoke-direct {v0, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    #@5
    const-string v1, "Something went wrong"

    #@7
    .line 93
    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    #@a
    move-result-object v0

    #@b
    const-string v1, "Check that Google Play is enabled on your device and that you\'re using an up-to-date version before opening the app. If the problem persists try reinstalling the app."

    #@d
    .line 94
    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    #@10
    move-result-object v0

    #@11
    const-string v1, "Close"

    #@13
    new-instance v2, Lcom/pairip/licensecheck/LicenseActivity$$ExternalSyntheticLambda2;

    #@15
    invoke-direct {v2, p0}, Lcom/pairip/licensecheck/LicenseActivity$$ExternalSyntheticLambda2;-><init>(Lcom/pairip/licensecheck/LicenseActivity;)V

    #@18
    .line 98
    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    #@1b
    move-result-object v0

    #@1c
    const/4 v1, 0x0

    #@1d
    .line 99
    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setCancelable(Z)Landroid/app/AlertDialog$Builder;

    #@20
    move-result-object v0

    #@21
    .line 100
    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;
    :try_end_24
    .catch Ljava/lang/RuntimeException; {:try_start_0 .. :try_end_24} :catch_25

    #@24
    goto :goto_3d

    #@25
    :catch_25
    move-exception v0

    #@26
    .line 107
    invoke-static {v0}, Landroid/util/Log;->getStackTraceString(Ljava/lang/Throwable;)Ljava/lang/String;

    #@29
    move-result-object v0

    #@2a
    new-instance v1, Ljava/lang/StringBuilder;

    #@2c
    const-string v2, "Couldn\'t show the error dialog. "

    #@2e
    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    #@31
    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@34
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    #@37
    move-result-object v0

    #@38
    const-string v1, "LicenseActivity"

    #@3a
    invoke-static {v1, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    #@3d
    :goto_3d
    return-void
.end method

.method private synthetic lambda$showErrorDialog$1(Landroid/content/DialogInterface;I)V
    .registers 3

    #@0
    .line 98
    invoke-direct {p0}, Lcom/pairip/licensecheck/LicenseActivity;->closeApp()V

    #@3
    return-void
.end method

.method private synthetic lambda$showPaywallAndCloseApp$0(Landroid/app/PendingIntent;)V
    .registers 4

    #@0
    .line 60
    :try_start_0
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    #@2
    const/16 v1, 0x22

    #@4
    if-lt v0, v1, :cond_17

    #@6
    .line 62
    invoke-static {}, Landroid/app/ActivityOptions;->makeBasic()Landroid/app/ActivityOptions;

    #@9
    move-result-object v0

    #@a
    const/4 v1, 0x1

    #@b
    .line 63
    invoke-virtual {v0, v1}, Landroid/app/ActivityOptions;->setPendingIntentBackgroundActivityStartMode(I)Landroid/app/ActivityOptions;

    #@e
    move-result-object v0

    #@f
    .line 65
    invoke-virtual {v0}, Landroid/app/ActivityOptions;->toBundle()Landroid/os/Bundle;

    #@12
    move-result-object v0

    #@13
    .line 66
    invoke-virtual {p1, v0}, Landroid/app/PendingIntent;->send(Landroid/os/Bundle;)V

    #@16
    goto :goto_1a

    #@17
    .line 68
    :cond_17
    invoke-virtual {p1}, Landroid/app/PendingIntent;->send()V

    #@1a
    .line 70
    :goto_1a
    invoke-direct {p0}, Lcom/pairip/licensecheck/LicenseActivity;->closeApp()V
    :try_end_1d
    .catch Landroid/app/PendingIntent$CanceledException; {:try_start_0 .. :try_end_1d} :catch_1e

    #@1d
    goto :goto_24

    #@1e
    :catch_1e
    move-exception p1

    #@1f
    .line 73
    const-string v0, "Paywall intent unexpectedly cancelled."

    #@21
    invoke-direct {p0, v0, p1}, Lcom/pairip/licensecheck/LicenseActivity;->logAndShowErrorDialog(Ljava/lang/String;Ljava/lang/Exception;)V

    #@24
    :goto_24
    return-void
.end method

.method private logAndShowErrorDialog(Ljava/lang/String;)V
    .registers 3
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "message"
        }
    .end annotation

    #@0
    .line 83
    const-string v0, "LicenseActivity"

    #@2
    invoke-static {v0, p1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    #@5
    .line 84
    invoke-direct {p0}, Lcom/pairip/licensecheck/LicenseActivity;->showErrorDialog()V

    #@8
    return-void
.end method

.method private logAndShowErrorDialog(Ljava/lang/String;Ljava/lang/Exception;)V
    .registers 4
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0
        }
        names = {
            "message",
            "ex"
        }
    .end annotation

    #@0
    .line 79
    invoke-static {p2}, Landroid/util/Log;->getStackTraceString(Ljava/lang/Throwable;)Ljava/lang/String;

    #@3
    move-result-object p2

    #@4
    new-instance v0, Ljava/lang/StringBuilder;

    #@6
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    #@9
    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@c
    const-string p1, " "

    #@e
    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@11
    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@14
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    #@17
    move-result-object p1

    #@18
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseActivity;->logAndShowErrorDialog(Ljava/lang/String;)V

    #@1b
    return-void
.end method

.method private showErrorDialog()V
    .registers 2

    #@0
    .line 88
    new-instance v0, Lcom/pairip/licensecheck/LicenseActivity$$ExternalSyntheticLambda1;

    #@2
    invoke-direct {v0, p0}, Lcom/pairip/licensecheck/LicenseActivity$$ExternalSyntheticLambda1;-><init>(Lcom/pairip/licensecheck/LicenseActivity;)V

    #@5
    invoke-virtual {p0, v0}, Lcom/pairip/licensecheck/LicenseActivity;->runOnUiThread(Ljava/lang/Runnable;)V

    #@8
    return-void
.end method

.method private showPaywallAndCloseApp()V
    .registers 3

    #@0
    .line 51
    invoke-virtual {p0}, Lcom/pairip/licensecheck/LicenseActivity;->getIntent()Landroid/content/Intent;

    #@3
    move-result-object v0

    #@4
    const-string v1, "paywallintent"

    #@6
    invoke-virtual {v0, v1}, Landroid/content/Intent;->getParcelableExtra(Ljava/lang/String;)Landroid/os/Parcelable;

    #@9
    move-result-object v0

    #@a
    check-cast v0, Landroid/app/PendingIntent;

    #@c
    if-nez v0, :cond_14

    #@e
    .line 53
    const-string v0, "Paywall intent is not provided."

    #@10
    invoke-direct {p0, v0}, Lcom/pairip/licensecheck/LicenseActivity;->logAndShowErrorDialog(Ljava/lang/String;)V

    #@13
    goto :goto_1c

    #@14
    .line 57
    :cond_14
    new-instance v1, Lcom/pairip/licensecheck/LicenseActivity$$ExternalSyntheticLambda0;

    #@16
    invoke-direct {v1, p0, v0}, Lcom/pairip/licensecheck/LicenseActivity$$ExternalSyntheticLambda0;-><init>(Lcom/pairip/licensecheck/LicenseActivity;Landroid/app/PendingIntent;)V

    #@19
    invoke-virtual {p0, v1}, Lcom/pairip/licensecheck/LicenseActivity;->runOnUiThread(Ljava/lang/Runnable;)V

    #@1c
    :goto_1c
    return-void
.end method


# virtual methods
.method protected closeAllTasks()V
    .registers 6

    #@0
    .line 128
    const-string v0, "activity"

    #@2
    invoke-virtual {p0, v0}, Lcom/pairip/licensecheck/LicenseActivity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    #@5
    move-result-object v0

    #@6
    check-cast v0, Landroid/app/ActivityManager;

    #@8
    if-eqz v0, :cond_3d

    #@a
    .line 130
    invoke-virtual {v0}, Landroid/app/ActivityManager;->getAppTasks()Ljava/util/List;

    #@d
    move-result-object v0

    #@e
    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    #@11
    move-result-object v0

    #@12
    :goto_12
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    #@15
    move-result v1

    #@16
    if-eqz v1, :cond_3d

    #@18
    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    #@1b
    move-result-object v1

    #@1c
    check-cast v1, Landroid/app/ActivityManager$AppTask;

    #@1e
    .line 132
    :try_start_1e
    invoke-virtual {v1}, Landroid/app/ActivityManager$AppTask;->finishAndRemoveTask()V
    :try_end_21
    .catch Ljava/lang/RuntimeException; {:try_start_1e .. :try_end_21} :catch_22

    #@21
    goto :goto_12

    #@22
    :catch_22
    move-exception v2

    #@23
    .line 134
    invoke-virtual {v1}, Landroid/app/ActivityManager$AppTask;->getTaskInfo()Landroid/app/ActivityManager$RecentTaskInfo;

    #@26
    move-result-object v1

    #@27
    iget v1, v1, Landroid/app/ActivityManager$RecentTaskInfo;->id:I

    #@29
    new-instance v3, Ljava/lang/StringBuilder;

    #@2b
    const-string v4, "Failed to gracefully clear task="

    #@2d
    invoke-direct {v3, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    #@30
    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    #@33
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    #@36
    move-result-object v1

    #@37
    const-string v3, "LicenseActivity"

    #@39
    invoke-static {v3, v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    #@3c
    goto :goto_12

    #@3d
    .line 138
    :cond_3d
    invoke-virtual {p0}, Lcom/pairip/licensecheck/LicenseActivity;->exitApp()V

    #@40
    return-void
.end method

.method protected exitApp()V
    .registers 2

    #@0
    .line 122
    invoke-virtual {p0}, Lcom/pairip/licensecheck/LicenseActivity;->finishAndRemoveTask()V

    #@3
    const/4 v0, 0x0

    #@4
    .line 123
    invoke-static {v0}, Ljava/lang/System;->exit(I)V

    #@7
    return-void
.end method

.method public onStart()V
    .registers 3

    #@0
    .line 33
    invoke-super {p0}, Landroid/app/Activity;->onStart()V

    #@3
    .line 36
    :try_start_3
    invoke-virtual {p0}, Lcom/pairip/licensecheck/LicenseActivity;->getIntent()Landroid/content/Intent;

    #@6
    move-result-object v0

    #@7
    const-string v1, "activitytype"

    #@9
    invoke-virtual {v0, v1}, Landroid/content/Intent;->getSerializableExtra(Ljava/lang/String;)Ljava/io/Serializable;

    #@c
    move-result-object v0

    #@d
    check-cast v0, Lcom/pairip/licensecheck/LicenseActivity$ActivityType;

    #@f
    .line 37
    invoke-virtual {v0}, Lcom/pairip/licensecheck/LicenseActivity$ActivityType;->ordinal()I

    #@12
    move-result v0

    #@13
    if-eqz v0, :cond_1c

    #@15
    const/4 v1, 0x1

    #@16
    if-ne v0, v1, :cond_26

    #@18
    .line 42
    invoke-direct {p0}, Lcom/pairip/licensecheck/LicenseActivity;->showErrorDialog()V

    #@1b
    goto :goto_26

    #@1c
    .line 39
    :cond_1c
    invoke-direct {p0}, Lcom/pairip/licensecheck/LicenseActivity;->showPaywallAndCloseApp()V
    :try_end_1f
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_1f} :catch_20

    #@1f
    goto :goto_26

    #@20
    :catch_20
    move-exception v0

    #@21
    .line 46
    const-string v1, "Couldn\'t process license activity correctly."

    #@23
    invoke-direct {p0, v1, v0}, Lcom/pairip/licensecheck/LicenseActivity;->logAndShowErrorDialog(Ljava/lang/String;Ljava/lang/Exception;)V

    #@26
    :cond_26
    :goto_26
    return-void
.end method
