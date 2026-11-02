.class public Lcom/pairip/SignatureCheck;
.super Ljava/lang/Object;
.source "SignatureCheck.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/pairip/SignatureCheck$SignatureTamperedException;
    }
.end annotation


# static fields
.field private static final ALLOWLISTED_SIG:Ljava/lang/String; = "Vn3kj4pUblROi2S+QfRRL9nhsaO2uoHQg6+dpEtxdTE="

.field private static final TAG:Ljava/lang/String; = "SignatureCheck"

.field private static expectedLegacyUpgradedSignature:Ljava/lang/String; = "XPaH1Vbxz0QBM97ZNgoAm7VL5Pz5QkyzDguMzcDa+gg="

.field private static expectedSignature:Ljava/lang/String; = "XPaH1Vbxz0QBM97ZNgoAm7VL5Pz5QkyzDguMzcDa+gg="

.field private static expectedTestSignature:Ljava/lang/String; = "XPaH1Vbxz0QBM97ZNgoAm7VL5Pz5QkyzDguMzcDa+gg="


# direct methods
.method private constructor <init>()V
    .registers 1

    #@0
    .line 77
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    #@3
    return-void
.end method

.method public static verifyIntegrity(Landroid/content/Context;)V
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
    .line 42
    :try_start_0
    invoke-virtual {p0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    #@3
    move-result-object v0

    #@4
    .line 43
    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    #@7
    move-result-object p0

    #@8
    const/16 v1, 0x40

    #@a
    invoke-virtual {v0, p0, v1}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;

    #@d
    move-result-object p0

    #@e
    .line 44
    const-string v0, "SHA-256"

    #@10
    .line 46
    invoke-static {v0}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    #@13
    move-result-object v0

    #@14
    iget-object p0, p0, Landroid/content/pm/PackageInfo;->signatures:[Landroid/content/pm/Signature;

    #@16
    const/4 v1, 0x0

    #@17
    aget-object p0, p0, v1

    #@19
    invoke-virtual {p0}, Landroid/content/pm/Signature;->toByteArray()[B

    #@1c
    move-result-object p0

    #@1d
    invoke-virtual {v0, p0}, Ljava/security/MessageDigest;->digest([B)[B

    #@20
    move-result-object p0

    #@21
    const/4 v0, 0x2

    #@22
    .line 45
    invoke-static {p0, v0}, Landroid/util/Base64;->encodeToString([BI)Ljava/lang/String;

    #@25
    move-result-object p0
    :try_end_26
    .catch Ljava/security/NoSuchAlgorithmException; {:try_start_0 .. :try_end_26} :catch_27
    .catch Landroid/content/pm/PackageManager$NameNotFoundException; {:try_start_0 .. :try_end_26} :catch_27

    #@26
    goto :goto_28

    #@27
    :catch_27
    const/4 p0, 0x0

    #@28
    .line 54
    :goto_28
    invoke-static {p0}, Lcom/pairip/SignatureCheck;->verifySignatureMatches(Ljava/lang/String;)Z

    #@2b
    move-result v0

    #@2c
    if-nez v0, :cond_46

    #@2e
    sget-object v0, Lcom/pairip/SignatureCheck;->expectedTestSignature:Ljava/lang/String;

    #@30
    .line 55
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    #@33
    move-result v0

    #@34
    if-nez v0, :cond_46

    #@36
    const-string v0, "Vn3kj4pUblROi2S+QfRRL9nhsaO2uoHQg6+dpEtxdTE="

    #@38
    .line 56
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    #@3b
    move-result p0

    #@3c
    if-nez p0, :cond_46

    #@3e
    .line 57
    new-instance p0, Lcom/pairip/SignatureCheck$SignatureTamperedException;

    #@40
    const-string v0, "Apk signature is invalid."

    #@42
    invoke-direct {p0, v0}, Lcom/pairip/SignatureCheck$SignatureTamperedException;-><init>(Ljava/lang/String;)V

    #@45
    throw p0

    #@46
    .line 59
    :cond_46
    const-string p0, "SignatureCheck"

    #@48
    const-string v0, "Signature check ok"

    #@4a
    invoke-static {p0, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    #@4d
    return-void
.end method

.method public static verifySignatureMatches(Ljava/lang/String;)Z
    .registers 2
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "signature"
        }
    .end annotation

    #@0
    .line 74
    sget-object v0, Lcom/pairip/SignatureCheck;->expectedSignature:Ljava/lang/String;

    #@2
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    #@5
    move-result v0

    #@6
    if-nez v0, :cond_12

    #@8
    sget-object v0, Lcom/pairip/SignatureCheck;->expectedLegacyUpgradedSignature:Ljava/lang/String;

    #@a
    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    #@d
    move-result p0

    #@e
    if-nez p0, :cond_12

    #@10
    const/4 p0, 0x0

    #@11
    goto :goto_13

    #@12
    :cond_12
    const/4 p0, 0x1

    #@13
    :goto_13
    return p0
.end method
