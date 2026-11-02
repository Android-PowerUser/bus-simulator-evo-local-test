.class public final synthetic Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda2;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic f$0:Lcom/pairip/licensecheck/LicenseClient;

.field public final synthetic f$1:Z

.field public final synthetic f$2:Lcom/pairip/licensecheck/LicenseCheckException;

.field public final synthetic f$3:Z


# direct methods
.method public synthetic constructor <init>(Lcom/pairip/licensecheck/LicenseClient;ZLcom/pairip/licensecheck/LicenseCheckException;Z)V
    .registers 5

    #@0
    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    #@3
    iput-object p1, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda2;->f$0:Lcom/pairip/licensecheck/LicenseClient;

    #@5
    iput-boolean p2, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda2;->f$1:Z

    #@7
    iput-object p3, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda2;->f$2:Lcom/pairip/licensecheck/LicenseCheckException;

    #@9
    iput-boolean p4, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda2;->f$3:Z

    #@b
    return-void
.end method


# virtual methods
.method public final run()V
    .registers 5

    #@0
    .line 0
    iget-object v0, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda2;->f$0:Lcom/pairip/licensecheck/LicenseClient;

    #@2
    iget-boolean v1, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda2;->f$1:Z

    #@4
    iget-object v2, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda2;->f$2:Lcom/pairip/licensecheck/LicenseCheckException;

    #@6
    iget-boolean v3, p0, Lcom/pairip/licensecheck/LicenseClient$$ExternalSyntheticLambda2;->f$3:Z

    #@8
    invoke-static {v0, v1, v2, v3}, Lcom/pairip/licensecheck/LicenseClient;->$r8$lambda$tB8S6FJPE8_x6-ohvmHs84x5lek(Lcom/pairip/licensecheck/LicenseClient;ZLcom/pairip/licensecheck/LicenseCheckException;Z)V

    #@b
    return-void
.end method
