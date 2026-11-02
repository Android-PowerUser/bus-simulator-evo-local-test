.class public final synthetic Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda11;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic f$0:Lcom/pairip/licensecheck/LicenseClient;

.field public final synthetic f$1:Lcom/pairip/licensecheck/RepeatedCheckMetadata;

.field public final synthetic f$2:Landroid/os/Bundle;


# direct methods
.method public synthetic constructor <init>(Lcom/pairip/licensecheck/LicenseClient;Lcom/pairip/licensecheck/RepeatedCheckMetadata;Landroid/os/Bundle;)V
    .registers 4

    #@0
    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    #@3
    iput-object p1, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda11;->f$0:Lcom/pairip/licensecheck/LicenseClient;

    #@5
    iput-object p2, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda11;->f$1:Lcom/pairip/licensecheck/RepeatedCheckMetadata;

    #@7
    iput-object p3, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda11;->f$2:Landroid/os/Bundle;

    #@9
    return-void
.end method


# virtual methods
.method public final run()V
    .registers 4

    #@0
    .line 0
    iget-object v0, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda11;->f$0:Lcom/pairip/licensecheck/LicenseClient;

    #@2
    iget-object v1, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda11;->f$1:Lcom/pairip/licensecheck/RepeatedCheckMetadata;

    #@4
    iget-object v2, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda11;->f$2:Landroid/os/Bundle;

    #@6
    invoke-static {v0, v1, v2}, Lcom/pairip/licensecheck/LicenseClient;->$r8$lambda$ot_XkRbEJeEFG1Hy-d3H6N4DX_I(Lcom/pairip/licensecheck/LicenseClient;Lcom/pairip/licensecheck/RepeatedCheckMetadata;Landroid/os/Bundle;)V

    #@9
    return-void
.end method
