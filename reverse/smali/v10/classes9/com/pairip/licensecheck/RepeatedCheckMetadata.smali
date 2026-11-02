.class public Lcom/pairip/licensecheck/RepeatedCheckMetadata;
.super Ljava/lang/Object;
.source "RepeatedCheckMetadata.java"


# instance fields
.field private final durationToRetryMillis:J

.field private final timeToRetryMillis:J


# direct methods
.method public constructor <init>(JJ)V
    .registers 8
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x0,
            0x0
        }
        names = {
            "durationToRetryMillis",
            "timeToRetryMillis"
        }
    .end annotation

    #@0
    .line 8
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    #@3
    const-wide/16 v0, 0x0

    #@5
    cmp-long v2, p1, v0

    #@7
    if-lez v2, :cond_1a

    #@9
    cmp-long v2, p3, v0

    #@b
    if-lez v2, :cond_12

    #@d
    .line 15
    iput-wide p1, p0, Lcom/pairip/licensecheck/RepeatedCheckMetadata;->durationToRetryMillis:J

    #@f
    .line 16
    iput-wide p3, p0, Lcom/pairip/licensecheck/RepeatedCheckMetadata;->timeToRetryMillis:J

    #@11
    return-void

    #@12
    .line 13
    :cond_12
    new-instance p1, Ljava/lang/IllegalArgumentException;

    #@14
    const-string p2, "Time to retry must be positive."

    #@16
    invoke-direct {p1, p2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    #@19
    throw p1

    #@1a
    .line 10
    :cond_1a
    new-instance p1, Ljava/lang/IllegalArgumentException;

    #@1c
    const-string p2, "Duration to retry must be positive."

    #@1e
    invoke-direct {p1, p2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    #@21
    throw p1
.end method


# virtual methods
.method public getDurationToRetryMillis()J
    .registers 3

    #@0
    .line 21
    iget-wide v0, p0, Lcom/pairip/licensecheck/RepeatedCheckMetadata;->durationToRetryMillis:J

    #@2
    return-wide v0
.end method

.method public getTimeToRetryMillis()J
    .registers 3

    #@0
    .line 26
    iget-wide v0, p0, Lcom/pairip/licensecheck/RepeatedCheckMetadata;->timeToRetryMillis:J

    #@2
    return-wide v0
.end method
