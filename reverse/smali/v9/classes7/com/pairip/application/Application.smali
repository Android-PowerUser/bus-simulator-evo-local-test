.class public Lcom/pairip/application/Application;
.super Lcom/safedk/android/SafeDKApplication;


# direct methods
.method public constructor <init>()V
    .registers 1

    #@0
    invoke-direct {p0}, Lcom/safedk/android/SafeDKApplication;-><init>()V

    #@3
    return-void
.end method


# virtual methods
.method protected attachBaseContext(Landroid/content/Context;)V
    .registers 2

    #@0
    invoke-static {p1}, Lcom/pairip/VMRunner;->setContext(Landroid/content/Context;)V

    #@3
    invoke-static {p1}, Lcom/pairip/SignatureCheck;->verifyIntegrity(Landroid/content/Context;)V

    #@6
    invoke-static {p1}, Lcom/pairip/licensecheck/LicenseClient;->checkLicense(Landroid/content/Context;)V

    #@9
    invoke-super {p0, p1}, Lcom/pairip/application/Application;->attachBaseContext(Landroid/content/Context;)V

    #@c
    return-void
.end method
