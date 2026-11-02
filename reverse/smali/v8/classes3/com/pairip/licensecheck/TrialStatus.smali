.class public final enum Lcom/pairip/licensecheck/TrialStatus;
.super Ljava/lang/Enum;
.source "TrialStatus.java"


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Enum<",
        "Lcom/pairip/licensecheck/TrialStatus;",
        ">;"
    }
.end annotation


# static fields
.field private static final synthetic $VALUES:[Lcom/pairip/licensecheck/TrialStatus;

.field public static final enum NOT_UNDER_TRIAL:Lcom/pairip/licensecheck/TrialStatus;

.field public static final enum UNDER_TRIAL:Lcom/pairip/licensecheck/TrialStatus;

.field public static final enum UNKNOWN:Lcom/pairip/licensecheck/TrialStatus;


# instance fields
.field private final statusCode:I


# direct methods
.method private static synthetic $values()[Lcom/pairip/licensecheck/TrialStatus;
    .registers 3

    #@0
    const/4 v0, 0x3

    #@1
    .line 4
    new-array v0, v0, [Lcom/pairip/licensecheck/TrialStatus;

    #@3
    sget-object v1, Lcom/pairip/licensecheck/TrialStatus;->UNKNOWN:Lcom/pairip/licensecheck/TrialStatus;

    #@5
    const/4 v2, 0x0

    #@6
    aput-object v1, v0, v2

    #@8
    sget-object v1, Lcom/pairip/licensecheck/TrialStatus;->UNDER_TRIAL:Lcom/pairip/licensecheck/TrialStatus;

    #@a
    const/4 v2, 0x1

    #@b
    aput-object v1, v0, v2

    #@d
    sget-object v1, Lcom/pairip/licensecheck/TrialStatus;->NOT_UNDER_TRIAL:Lcom/pairip/licensecheck/TrialStatus;

    #@f
    const/4 v2, 0x2

    #@10
    aput-object v1, v0, v2

    #@12
    return-object v0
.end method

.method static constructor <clinit>()V
    .registers 3

    #@0
    .line 6
    new-instance v0, Lcom/pairip/licensecheck/TrialStatus;

    #@2
    const-string v1, "UNKNOWN"

    #@4
    const/4 v2, 0x0

    #@5
    invoke-direct {v0, v1, v2, v2}, Lcom/pairip/licensecheck/TrialStatus;-><init>(Ljava/lang/String;II)V

    #@8
    sput-object v0, Lcom/pairip/licensecheck/TrialStatus;->UNKNOWN:Lcom/pairip/licensecheck/TrialStatus;

    #@a
    .line 8
    new-instance v0, Lcom/pairip/licensecheck/TrialStatus;

    #@c
    const-string v1, "UNDER_TRIAL"

    #@e
    const/4 v2, 0x1

    #@f
    invoke-direct {v0, v1, v2, v2}, Lcom/pairip/licensecheck/TrialStatus;-><init>(Ljava/lang/String;II)V

    #@12
    sput-object v0, Lcom/pairip/licensecheck/TrialStatus;->UNDER_TRIAL:Lcom/pairip/licensecheck/TrialStatus;

    #@14
    .line 10
    new-instance v0, Lcom/pairip/licensecheck/TrialStatus;

    #@16
    const-string v1, "NOT_UNDER_TRIAL"

    #@18
    const/4 v2, 0x2

    #@19
    invoke-direct {v0, v1, v2, v2}, Lcom/pairip/licensecheck/TrialStatus;-><init>(Ljava/lang/String;II)V

    #@1c
    sput-object v0, Lcom/pairip/licensecheck/TrialStatus;->NOT_UNDER_TRIAL:Lcom/pairip/licensecheck/TrialStatus;

    #@1e
    .line 4
    invoke-static {}, Lcom/pairip/licensecheck/TrialStatus;->$values()[Lcom/pairip/licensecheck/TrialStatus;

    #@21
    move-result-object v0

    #@22
    sput-object v0, Lcom/pairip/licensecheck/TrialStatus;->$VALUES:[Lcom/pairip/licensecheck/TrialStatus;

    #@24
    return-void
.end method

.method private constructor <init>(Ljava/lang/String;II)V
    .registers 4
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x1000,
            0x1000,
            0x0
        }
        names = {
            "$enum$name",
            "$enum$ordinal",
            "statusCode"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I)V"
        }
    .end annotation

    #@0
    .line 14
    invoke-direct {p0, p1, p2}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    #@3
    .line 15
    iput p3, p0, Lcom/pairip/licensecheck/TrialStatus;->statusCode:I

    #@5
    return-void
.end method

.method public static valueOf(Ljava/lang/String;)Lcom/pairip/licensecheck/TrialStatus;
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
    .line 4
    const-class v0, Lcom/pairip/licensecheck/TrialStatus;

    #@2
    invoke-static {v0, p0}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    #@5
    move-result-object p0

    #@6
    check-cast p0, Lcom/pairip/licensecheck/TrialStatus;

    #@8
    return-object p0
.end method

.method public static values()[Lcom/pairip/licensecheck/TrialStatus;
    .registers 1

    #@0
    .line 4
    sget-object v0, Lcom/pairip/licensecheck/TrialStatus;->$VALUES:[Lcom/pairip/licensecheck/TrialStatus;

    #@2
    invoke-virtual {v0}, [Lcom/pairip/licensecheck/TrialStatus;->clone()Ljava/lang/Object;

    #@5
    move-result-object v0

    #@6
    check-cast v0, [Lcom/pairip/licensecheck/TrialStatus;

    #@8
    return-object v0
.end method


# virtual methods
.method public getStatusCode()I
    .registers 2

    #@0
    .line 19
    iget v0, p0, Lcom/pairip/licensecheck/TrialStatus;->statusCode:I

    #@2
    return v0
.end method
