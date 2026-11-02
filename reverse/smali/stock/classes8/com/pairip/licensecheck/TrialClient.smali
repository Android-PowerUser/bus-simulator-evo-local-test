.class public final Lcom/pairip/licensecheck/TrialClient;
.super Ljava/lang/Object;
.source "TrialClient.java"


# direct methods
.method private constructor <init>()V
    .registers 1

    #@0
    .line 41
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    #@3
    return-void
.end method

.method public static checkTrialStatus(Landroid/content/Context;)I
    .registers 2
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "context"
        }
    .end annotation

    #@0
    .line 37
    const-string v0, "Context must not be null."

    #@2
    invoke-static {p0, v0}, Ljava/util/Objects;->requireNonNull(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    #@5
    .line 38
    invoke-static {}, Lcom/pairip/licensecheck/LicenseClient;->checkTrialStatus()Lcom/pairip/licensecheck/TrialStatus;

    #@8
    move-result-object p0

    #@9
    invoke-virtual {p0}, Lcom/pairip/licensecheck/TrialStatus;->getStatusCode()I

    #@c
    move-result p0

    #@d
    return p0
.end method

.method public static stopTrial(Landroid/content/Context;)V
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
    .line 23
    invoke-static {p0}, Lcom/pairip/licensecheck/LicenseClient;->stopTrial(Landroid/content/Context;)V

    #@3
    return-void
.end method
