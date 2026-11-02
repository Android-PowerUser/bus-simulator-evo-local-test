.class public Lcom/pairip/licensecheck/LicenseResponseHelper;
.super Ljava/lang/Object;
.source "LicenseResponseHelper.java"


# static fields
.field private static final KEY_FACTORY_ALGORITHM:Ljava/lang/String; = "RSA"

.field private static final PAYLOAD_LICENSE_DATA:Ljava/lang/String; = "LICENSE_DATA"

.field private static final PAYLOAD_PACKAGE_NAME:Ljava/lang/String; = "packageName"

.field private static final PAYLOAD_REPEATED_CHECK_DURATION_TO_RETRY_MILLIS:Ljava/lang/String; = "repeatedCheckDurationToRetryMillis"

.field private static final PAYLOAD_REPEATED_CHECK_TIME_TO_RETRY_MILLIS:Ljava/lang/String; = "repeatedCheckTimeToRetryMillis"

.field private static final SIGNATURE_ALGORITHM:Ljava/lang/String; = "SHA256withRSA"

.field private static final UTF_8:Ljava/nio/charset/Charset;


# direct methods
.method static constructor <clinit>()V
    .registers 1

    #@0
    .line 20
    const-string v0, "UTF-8"

    #@2
    invoke-static {v0}, Ljava/nio/charset/Charset;->forName(Ljava/lang/String;)Ljava/nio/charset/Charset;

    #@5
    move-result-object v0

    #@6
    sput-object v0, Lcom/pairip/licensecheck/LicenseResponseHelper;->UTF_8:Ljava/nio/charset/Charset;

    #@8
    return-void
.end method

.method private constructor <init>()V
    .registers 1

    #@0
    .line 155
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    #@3
    return-void
.end method

.method private static base64ToJson(Ljava/lang/String;)Lorg/json/JSONObject;
    .registers 3
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "input"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/pairip/licensecheck/LicenseCheckException;
        }
    .end annotation

    #@0
    const/16 v0, 0x8

    #@2
    .line 109
    :try_start_2
    invoke-static {p0, v0}, Landroid/util/Base64;->decode(Ljava/lang/String;I)[B

    #@5
    move-result-object p0

    #@6
    .line 110
    new-instance v0, Ljava/lang/String;

    #@8
    sget-object v1, Lcom/pairip/licensecheck/LicenseResponseHelper;->UTF_8:Ljava/nio/charset/Charset;

    #@a
    invoke-direct {v0, p0, v1}, Ljava/lang/String;-><init>([BLjava/nio/charset/Charset;)V

    #@d
    .line 111
    new-instance p0, Lorg/json/JSONObject;

    #@f
    invoke-direct {p0, v0}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V
    :try_end_12
    .catch Ljava/lang/IllegalArgumentException; {:try_start_2 .. :try_end_12} :catch_15
    .catch Lorg/json/JSONException; {:try_start_2 .. :try_end_12} :catch_13

    #@12
    return-object p0

    #@13
    :catch_13
    move-exception p0

    #@14
    goto :goto_16

    #@15
    :catch_15
    move-exception p0

    #@16
    .line 113
    :goto_16
    new-instance v0, Lcom/pairip/licensecheck/LicenseCheckException;

    #@18
    const-string v1, "Invalid response"

    #@1a
    invoke-direct {v0, v1, p0}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    #@1d
    throw v0
.end method

.method private static getJwsPartsForLicenseData(Landroid/os/Bundle;)[Ljava/lang/String;
    .registers 4
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "responsePayload"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/pairip/licensecheck/LicenseCheckException;
        }
    .end annotation

    #@0
    .line 95
    const-string v0, "LICENSE_DATA"

    #@2
    invoke-virtual {p0, v0}, Landroid/os/Bundle;->getString(Ljava/lang/String;)Ljava/lang/String;

    #@5
    move-result-object p0

    #@6
    .line 96
    const-string v0, "Invalid response"

    #@8
    if-eqz p0, :cond_1c

    #@a
    .line 99
    const-string v1, "\\."

    #@c
    const/4 v2, -0x1

    #@d
    invoke-virtual {p0, v1, v2}, Ljava/lang/String;->split(Ljava/lang/String;I)[Ljava/lang/String;

    #@10
    move-result-object p0

    #@11
    .line 100
    array-length v1, p0

    #@12
    const/4 v2, 0x3

    #@13
    if-ne v1, v2, :cond_16

    #@15
    return-object p0

    #@16
    .line 101
    :cond_16
    new-instance p0, Lcom/pairip/licensecheck/LicenseCheckException;

    #@18
    invoke-direct {p0, v0}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;)V

    #@1b
    throw p0

    #@1c
    .line 97
    :cond_1c
    new-instance p0, Lcom/pairip/licensecheck/LicenseCheckException;

    #@1e
    invoke-direct {p0, v0}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;)V

    #@21
    throw p0
.end method

.method private static getPublicKey()Ljava/security/PublicKey;
    .registers 5
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/pairip/licensecheck/LicenseCheckException;
        }
    .end annotation

    #@0
    .line 142
    const-string v0, "RSA"

    #@2
    const/4 v1, 0x0

    #@3
    :try_start_3
    invoke-static {}, Lcom/pairip/licensecheck/LicenseClient;->getLicensePubKey()Ljava/lang/String;

    #@6
    move-result-object v2

    #@7
    invoke-static {v2, v1}, Landroid/util/Base64;->decode(Ljava/lang/String;I)[B

    #@a
    move-result-object v2

    #@b
    .line 143
    invoke-static {v0}, Ljava/security/KeyFactory;->getInstance(Ljava/lang/String;)Ljava/security/KeyFactory;

    #@e
    move-result-object v3

    #@f
    .line 144
    new-instance v4, Ljava/security/spec/X509EncodedKeySpec;

    #@11
    invoke-direct {v4, v2}, Ljava/security/spec/X509EncodedKeySpec;-><init>([B)V

    #@14
    invoke-virtual {v3, v4}, Ljava/security/KeyFactory;->generatePublic(Ljava/security/spec/KeySpec;)Ljava/security/PublicKey;

    #@17
    move-result-object v0
    :try_end_18
    .catch Ljava/security/NoSuchAlgorithmException; {:try_start_3 .. :try_end_18} :catch_2b
    .catch Ljava/lang/IllegalArgumentException; {:try_start_3 .. :try_end_18} :catch_22
    .catch Ljava/security/spec/InvalidKeySpecException; {:try_start_3 .. :try_end_18} :catch_19

    #@18
    return-object v0

    #@19
    :catch_19
    move-exception v0

    #@1a
    .line 151
    new-instance v1, Lcom/pairip/licensecheck/LicenseCheckException;

    #@1c
    const-string v2, "Could not create key specification from the public key"

    #@1e
    invoke-direct {v1, v2, v0}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    #@21
    throw v1

    #@22
    :catch_22
    move-exception v0

    #@23
    .line 149
    new-instance v1, Lcom/pairip/licensecheck/LicenseCheckException;

    #@25
    const-string v2, "Could not decode public key"

    #@27
    invoke-direct {v1, v2, v0}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    #@2a
    throw v1

    #@2b
    :catch_2b
    move-exception v2

    #@2c
    .line 146
    new-instance v3, Lcom/pairip/licensecheck/LicenseCheckException;

    #@2e
    const/4 v4, 0x1

    #@2f
    new-array v4, v4, [Ljava/lang/Object;

    #@31
    aput-object v0, v4, v1

    #@33
    .line 147
    const-string v0, "%s algorithm not found on device"

    #@35
    invoke-static {v0, v4}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    #@38
    move-result-object v0

    #@39
    invoke-direct {v3, v0, v2}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    #@3c
    throw v3
.end method

.method public static getRepeatedCheckMetadata(Landroid/os/Bundle;)Lcom/pairip/licensecheck/RepeatedCheckMetadata;
    .registers 6
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0
        }
        names = {
            "responsePayload"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/pairip/licensecheck/LicenseCheckException;
        }
    .end annotation

    #@0
    .line 75
    const-string v0, "repeatedCheckTimeToRetryMillis"

    #@2
    const-string v1, "repeatedCheckDurationToRetryMillis"

    #@4
    :try_start_4
    invoke-static {p0}, Lcom/pairip/licensecheck/LicenseResponseHelper;->getJwsPartsForLicenseData(Landroid/os/Bundle;)[Ljava/lang/String;

    #@7
    move-result-object p0

    #@8
    const/4 v2, 0x1

    #@9
    .line 76
    aget-object p0, p0, v2

    #@b
    invoke-static {p0}, Lcom/pairip/licensecheck/LicenseResponseHelper;->base64ToJson(Ljava/lang/String;)Lorg/json/JSONObject;

    #@e
    move-result-object p0

    #@f
    .line 78
    invoke-virtual {p0, v1}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    #@12
    move-result v2

    #@13
    if-eqz v2, :cond_29

    #@15
    .line 79
    invoke-virtual {p0, v0}, Lorg/json/JSONObject;->has(Ljava/lang/String;)Z

    #@18
    move-result v2

    #@19
    if-eqz v2, :cond_29

    #@1b
    .line 83
    invoke-virtual {p0, v1}, Lorg/json/JSONObject;->getLong(Ljava/lang/String;)J

    #@1e
    move-result-wide v1

    #@1f
    .line 84
    invoke-virtual {p0, v0}, Lorg/json/JSONObject;->getLong(Ljava/lang/String;)J

    #@22
    move-result-wide v3

    #@23
    .line 85
    new-instance p0, Lcom/pairip/licensecheck/RepeatedCheckMetadata;

    #@25
    invoke-direct {p0, v1, v2, v3, v4}, Lcom/pairip/licensecheck/RepeatedCheckMetadata;-><init>(JJ)V
    :try_end_28
    .catch Lorg/json/JSONException; {:try_start_4 .. :try_end_28} :catch_34
    .catch Ljava/lang/IllegalArgumentException; {:try_start_4 .. :try_end_28} :catch_2b

    #@28
    goto :goto_2a

    #@29
    :cond_29
    const/4 p0, 0x0

    #@2a
    :goto_2a
    return-object p0

    #@2b
    :catch_2b
    move-exception p0

    #@2c
    .line 89
    new-instance v0, Lcom/pairip/licensecheck/LicenseCheckException;

    #@2e
    const-string v1, "Invalid repeated check payload"

    #@30
    invoke-direct {v0, v1, p0}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    #@33
    throw v0

    #@34
    :catch_34
    move-exception p0

    #@35
    .line 87
    new-instance v0, Lcom/pairip/licensecheck/LicenseCheckException;

    #@37
    const-string v1, "Could not decode json"

    #@39
    invoke-direct {v0, v1, p0}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    #@3c
    throw v0
.end method

.method public static validateResponse(Landroid/os/Bundle;Ljava/lang/String;)V
    .registers 7
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0
        }
        names = {
            "responsePayload",
            "packageName"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/pairip/licensecheck/LicenseCheckException;
        }
    .end annotation

    #@0
    .line 43
    :try_start_0
    invoke-static {p0}, Lcom/pairip/licensecheck/LicenseResponseHelper;->getJwsPartsForLicenseData(Landroid/os/Bundle;)[Ljava/lang/String;

    #@3
    move-result-object p0

    #@4
    const/4 v0, 0x0

    #@5
    .line 44
    aget-object v1, p0, v0

    #@7
    invoke-static {v1}, Lcom/pairip/licensecheck/LicenseResponseHelper;->base64ToJson(Ljava/lang/String;)Lorg/json/JSONObject;

    #@a
    move-result-object v1

    #@b
    const/4 v2, 0x1

    #@c
    .line 45
    aget-object v3, p0, v2

    #@e
    invoke-static {v3}, Lcom/pairip/licensecheck/LicenseResponseHelper;->base64ToJson(Ljava/lang/String;)Lorg/json/JSONObject;

    #@11
    move-result-object v3

    #@12
    const/4 v4, 0x2

    #@13
    .line 46
    aget-object v4, p0, v4

    #@15
    .line 47
    aget-object v0, p0, v0

    #@17
    aget-object p0, p0, v2

    #@19
    new-instance v2, Ljava/lang/StringBuilder;

    #@1b
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    #@1e
    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@21
    const-string v0, "."

    #@23
    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@26
    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    #@29
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    #@2c
    move-result-object p0

    #@2d
    .line 50
    const-string v0, "alg"

    #@2f
    invoke-virtual {v1, v0}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    #@32
    move-result-object v0

    #@33
    const-string v1, "RS256"

    #@35
    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    #@38
    move-result v0

    #@39
    if-eqz v0, :cond_59

    #@3b
    .line 53
    const-string v0, "SHA256withRSA"

    #@3d
    invoke-static {}, Lcom/pairip/licensecheck/LicenseResponseHelper;->getPublicKey()Ljava/security/PublicKey;

    #@40
    move-result-object v1

    #@41
    invoke-static {p0, v4, v0, v1}, Lcom/pairip/licensecheck/LicenseResponseHelper;->verifySignature(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/security/PublicKey;)V

    #@44
    .line 56
    const-string p0, "packageName"

    #@46
    invoke-virtual {v3, p0}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    #@49
    move-result-object p0

    #@4a
    .line 57
    invoke-virtual {p0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    #@4d
    move-result p0

    #@4e
    if-eqz p0, :cond_51

    #@50
    return-void

    #@51
    .line 58
    :cond_51
    new-instance p0, Lcom/pairip/licensecheck/LicenseCheckException;

    #@53
    const-string p1, "Package name doesn\'t match."

    #@55
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;)V

    #@58
    throw p0

    #@59
    .line 51
    :cond_59
    new-instance p0, Lcom/pairip/licensecheck/LicenseCheckException;

    #@5b
    const-string p1, "Response must be signed with RS256 algorithm."

    #@5d
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;)V

    #@60
    throw p0
    :try_end_61
    .catch Lorg/json/JSONException; {:try_start_0 .. :try_end_61} :catch_61

    #@61
    :catch_61
    move-exception p0

    #@62
    .line 61
    new-instance p1, Lcom/pairip/licensecheck/LicenseCheckException;

    #@64
    const-string v0, "Could not decode json"

    #@66
    invoke-direct {p1, v0, p0}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    #@69
    throw p1
.end method

.method private static verifySignature(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/security/PublicKey;)V
    .registers 5
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0,
            0x0,
            0x0
        }
        names = {
            "signedData",
            "signature",
            "signatureAlgorithm",
            "publicKey"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/pairip/licensecheck/LicenseCheckException;
        }
    .end annotation

    #@0
    .line 122
    :try_start_0
    invoke-static {p2}, Ljava/security/Signature;->getInstance(Ljava/lang/String;)Ljava/security/Signature;

    #@3
    move-result-object v0

    #@4
    .line 123
    invoke-virtual {v0, p3}, Ljava/security/Signature;->initVerify(Ljava/security/PublicKey;)V

    #@7
    .line 124
    sget-object p3, Lcom/pairip/licensecheck/LicenseResponseHelper;->UTF_8:Ljava/nio/charset/Charset;

    #@9
    invoke-virtual {p0, p3}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    #@c
    move-result-object p0

    #@d
    invoke-virtual {v0, p0}, Ljava/security/Signature;->update([B)V

    #@10
    const/16 p0, 0x8

    #@12
    .line 125
    invoke-static {p1, p0}, Landroid/util/Base64;->decode(Ljava/lang/String;I)[B

    #@15
    move-result-object p0

    #@16
    invoke-virtual {v0, p0}, Ljava/security/Signature;->verify([B)Z

    #@19
    move-result p0

    #@1a
    if-eqz p0, :cond_1d

    #@1c
    return-void

    #@1d
    .line 126
    :cond_1d
    new-instance p0, Lcom/pairip/licensecheck/LicenseCheckException;

    #@1f
    const-string p1, "Signature verification failed."

    #@21
    invoke-direct {p0, p1}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;)V

    #@24
    throw p0
    :try_end_25
    .catch Ljava/security/NoSuchAlgorithmException; {:try_start_0 .. :try_end_25} :catch_40
    .catch Ljava/security/InvalidKeyException; {:try_start_0 .. :try_end_25} :catch_37
    .catch Ljava/security/SignatureException; {:try_start_0 .. :try_end_25} :catch_2e
    .catch Ljava/lang/IllegalArgumentException; {:try_start_0 .. :try_end_25} :catch_25

    #@25
    :catch_25
    move-exception p0

    #@26
    .line 136
    new-instance p1, Lcom/pairip/licensecheck/LicenseCheckException;

    #@28
    const-string p2, "Could not base64 decode returned signature"

    #@2a
    invoke-direct {p1, p2, p0}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    #@2d
    throw p1

    #@2e
    :catch_2e
    move-exception p0

    #@2f
    .line 134
    new-instance p1, Lcom/pairip/licensecheck/LicenseCheckException;

    #@31
    const-string p2, "Could not parse returned signature."

    #@33
    invoke-direct {p1, p2, p0}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    #@36
    throw p1

    #@37
    :catch_37
    move-exception p0

    #@38
    .line 132
    new-instance p1, Lcom/pairip/licensecheck/LicenseCheckException;

    #@3a
    const-string p2, "Could not sign data with the public key"

    #@3c
    invoke-direct {p1, p2, p0}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    #@3f
    throw p1

    #@40
    :catch_40
    move-exception p0

    #@41
    .line 129
    new-instance p1, Lcom/pairip/licensecheck/LicenseCheckException;

    #@43
    const/4 p3, 0x1

    #@44
    new-array p3, p3, [Ljava/lang/Object;

    #@46
    const/4 v0, 0x0

    #@47
    aput-object p2, p3, v0

    #@49
    .line 130
    const-string p2, "Could not find %s algorithm on the device"

    #@4b
    invoke-static {p2, p3}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    #@4e
    move-result-object p2

    #@4f
    invoke-direct {p1, p2, p0}, Lcom/pairip/licensecheck/LicenseCheckException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    #@52
    throw p1
.end method
