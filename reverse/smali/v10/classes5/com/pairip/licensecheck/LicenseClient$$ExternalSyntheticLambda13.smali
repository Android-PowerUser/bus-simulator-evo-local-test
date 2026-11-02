.class public final synthetic Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda13;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic f$0:Lcom/pairip/licensecheck/LicenseClient;

.field public final synthetic f$1:Z


# direct methods
.method public synthetic constructor <init>(Lcom/pairip/licensecheck/LicenseClient;Z)V
    .registers 3

    #@0
    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    #@3
    iput-object p1, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda13;->f$0:Lcom/pairip/licensecheck/LicenseClient;

    #@5
    iput-boolean p2, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda13;->f$1:Z

    #@7
    return-void
.end method


# virtual methods
.method public final run()V
    .registers 3

    #@0
    .line 0
    iget-object v0, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda13;->f$0:Lcom/pairip/licensecheck/LicenseClient;

    #@2
    iget-boolean v1, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda13;->f$1:Z

    #@4
    invoke-static {v0, v1}, Lcom/pairip/licensecheck/LicenseClient;->$r8$lambda$x_INbtAE1cLJhbPOU3l3uRiKDN8(Lcom/pairip/licensecheck/LicenseClient;Z)V

    #@7
    return-void
.end method
