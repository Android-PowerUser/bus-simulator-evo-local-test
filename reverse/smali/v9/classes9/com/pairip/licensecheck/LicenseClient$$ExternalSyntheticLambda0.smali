.class public final synthetic Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda0;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic f$0:Lcom/pairip/licensecheck/LicenseClient;


# direct methods
.method public synthetic constructor <init>(Lcom/pairip/licensecheck/LicenseClient;)V
    .registers 2

    #@0
    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    #@3
    iput-object p1, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda0;->f$0:Lcom/pairip/licensecheck/LicenseClient;

    #@5
    return-void
.end method


# virtual methods
.method public final run()V
    .registers 2

    #@0
    .line 0
    iget-object v0, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda0;->f$0:Lcom/pairip/licensecheck/LicenseClient;

    #@2
    invoke-virtual {v0}, Lcom/pairip/licensecheck/LicenseClient;->unbindFromLicensingService()V

    #@5
    return-void
.end method
