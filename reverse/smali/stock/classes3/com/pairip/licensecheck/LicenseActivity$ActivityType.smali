.class public final enum Lcom/pairip/licensecheck/LicenseActivity$ActivityType;
.super Ljava/lang/Enum;
.source "LicenseActivity.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/pairip/licensecheck/LicenseActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x4019
    name = "ActivityType"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Enum<",
        "Lcom/pairip/licensecheck/LicenseActivity$ActivityType;",
        ">;"
    }
.end annotation


# static fields
.field private static final synthetic $VALUES:[Lcom/pairip/licensecheck/LicenseActivity$ActivityType;

.field public static final enum ERROR_DIALOG:Lcom/pairip/licensecheck/LicenseActivity$ActivityType;

.field public static final enum PAYWALL:Lcom/pairip/licensecheck/LicenseActivity$ActivityType;


# direct methods
.method private static synthetic $values()[Lcom/pairip/licensecheck/LicenseActivity$ActivityType;
    .registers 3

    #@0
    const/4 v0, 0x2

    #@1
    .line 26
    new-array v0, v0, [Lcom/pairip/licensecheck/LicenseActivity$ActivityType;

    #@3
    sget-object v1, Lcom/pairip/licensecheck/LicenseActivity$ActivityType;->PAYWALL:Lcom/pairip/licensecheck/LicenseActivity$ActivityType;

    #@5
    const/4 v2, 0x0

    #@6
    aput-object v1, v0, v2

    #@8
    sget-object v1, Lcom/pairip/licensecheck/LicenseActivity$ActivityType;->ERROR_DIALOG:Lcom/pairip/licensecheck/LicenseActivity$ActivityType;

    #@a
    const/4 v2, 0x1

    #@b
    aput-object v1, v0, v2

    #@d
    return-object v0
.end method

.method static constructor <clinit>()V
    .registers 3

    #@0
    .line 27
    new-instance v0, Lcom/pairip/licensecheck/LicenseActivity$ActivityType;

    #@2
    const-string v1, "PAYWALL"

    #@4
    const/4 v2, 0x0

    #@5
    invoke-direct {v0, v1, v2}, Lcom/pairip/licensecheck/LicenseActivity$ActivityType;-><init>(Ljava/lang/String;I)V

    #@8
    sput-object v0, Lcom/pairip/licensecheck/LicenseActivity$ActivityType;->PAYWALL:Lcom/pairip/licensecheck/LicenseActivity$ActivityType;

    #@a
    .line 28
    new-instance v0, Lcom/pairip/licensecheck/LicenseActivity$ActivityType;

    #@c
    const-string v1, "ERROR_DIALOG"

    #@e
    const/4 v2, 0x1

    #@f
    invoke-direct {v0, v1, v2}, Lcom/pairip/licensecheck/LicenseActivity$ActivityType;-><init>(Ljava/lang/String;I)V

    #@12
    sput-object v0, Lcom/pairip/licensecheck/LicenseActivity$ActivityType;->ERROR_DIALOG:Lcom/pairip/licensecheck/LicenseActivity$ActivityType;

    #@14
    .line 26
    invoke-static {}, Lcom/pairip/licensecheck/LicenseActivity$ActivityType;->$values()[Lcom/pairip/licensecheck/LicenseActivity$ActivityType;

    #@17
    move-result-object v0

    #@18
    sput-object v0, Lcom/pairip/licensecheck/LicenseActivity$ActivityType;->$VALUES:[Lcom/pairip/licensecheck/LicenseActivity$ActivityType;

    #@1a
    return-void
.end method

.method private constructor <init>(Ljava/lang/String;I)V
    .registers 3
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x1000,
            0x1000
        }
        names = {
            "$enum$name",
            "$enum$ordinal"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    #@0
    .line 26
    invoke-direct {p0, p1, p2}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    #@3
    return-void
.end method

.method public static valueOf(Ljava/lang/String;)Lcom/pairip/licensecheck/LicenseActivity$ActivityType;
    .registers 2
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8000
        }
        names = {
            "name"
        }
    .end annotation

    #@0
    .line 26
    const-class v0, Lcom/pairip/licensecheck/LicenseActivity$ActivityType;

    #@2
    invoke-static {v0, p0}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    #@5
    move-result-object p0

    #@6
    check-cast p0, Lcom/pairip/licensecheck/LicenseActivity$ActivityType;

    #@8
    return-object p0
.end method

.method public static values()[Lcom/pairip/licensecheck/LicenseActivity$ActivityType;
    .registers 1

    #@0
    .line 26
    sget-object v0, Lcom/pairip/licensecheck/LicenseActivity$ActivityType;->$VALUES:[Lcom/pairip/licensecheck/LicenseActivity$ActivityType;

    #@2
    invoke-virtual {v0}, [Lcom/pairip/licensecheck/LicenseActivity$ActivityType;->clone()Ljava/lang/Object;

    #@5
    move-result-object v0

    #@6
    check-cast v0, [Lcom/pairip/licensecheck/LicenseActivity$ActivityType;

    #@8
    return-object v0
.end method
