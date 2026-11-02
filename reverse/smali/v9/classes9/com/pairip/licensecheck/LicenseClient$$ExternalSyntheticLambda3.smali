.class public final synthetic Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda3;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic f$0:Landroid/content/Context;


# direct methods
.method public synthetic constructor <init>(Landroid/content/Context;)V
    .registers 2

    #@0
    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    #@3
    iput-object p1, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda3;->f$0:Landroid/content/Context;

    #@5
    return-void
.end method


# virtual methods
.method public final run()V
    .registers 2

    #@0
    .line 0
    iget-object v0, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda3;->f$0:Landroid/content/Context;

    #@2
    invoke-static {v0}, Lcom/pairip/licensecheck/LicenseClient;->lambda$stopTrial$0(Landroid/content/Context;)V

    #@5
    return-void
.end method
